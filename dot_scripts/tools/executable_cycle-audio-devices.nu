#!/usr/bin/env nu

let cache_file = '/tmp/previous_sink.json'

let sink_inputs = pactl list sink-inputs short|lines|split column "\t"|rename id sink|select id sink|into value

let sink_info = pactl list sinks|split row --regex 'Sink #\d+'|str trim|filter {|| ($in|str length) > 1}

let sinks = $sink_info|each {|sink|
  mut output = {}
  let parsed = $sink|str replace -a -m -r "^\t" ''|str replace -a -r -m '^([a-zA-Z]+):$' '[[$1]]'
  let names = $parsed|rg '^\[\[.+\]\]'|str replace -r -a '\[\[(.+)\]\]' '$1'|lines
  let info = $parsed|split column -r '\[\[.+\]\]'|rename Content ...$names 

  let content = $info|get Content|each {||
    $in|lines|str replace : '==='|split column '==='|str trim|transpose -i|headers|into record
  }|into record

  let properties = ($info|get Properties|each {||
    $in|lines|parse '{key} = "{value}"'|str trim|transpose -i|headers|into record
  })|into record

  let state = $content|get State
  $output = ($output|insert state $state)

  let id = $properties|get 'object.id'|into int
  $output = ($output|insert id $id)

  let name = $properties|get 'node.name'
  $output = ($output|insert name $name)

  let description = $properties|get 'device.description'|str trim
  $output = ($output|insert description $description)

  if ($info|columns|find Ports|is-not-empty) { 
    let ports = ($info|get Ports|each {||
      $in|lines|parse "\t{name}:{2}"
    }).0.name
    $output = ($output|insert ports $ports)

    let active_port = ($info|get Ports|each {||
      $in|lines|parse '{name}:{value}'|transpose -i|headers|into record|get 'Active Port'|str trim
    }).0
    $output = ($output|insert active_port $active_port)
  }

  $output
}

def set_sink [sink, --hide_notifications] {
  pactl set-default-sink $sink.name
  $sink_inputs|each {||
    pactl move-sink-input $in.id $sink.name
  }

  $sink|save $cache_file --force

  if not $hide_notifications {
    notify-send -a bspwm -i "/usr/share/icons/Tela-circle-dark/16/actions/audio-ready.svg" "Sound output switched to" $sink.name -u low
  }
}

def set_port [sink, port, --hide_notifications] {
  let sink_id: int = ($sink|get id)
  let sink_name: string = ($sink|get name)

  pactl set-default-sink $sink_name
  pactl set-sink-port $sink_id $port

  if not $hide_notifications {
    notify-send -a bspwm -i "/usr/share/icons/Tela-circle-dark/16/actions/audio-ready.svg" "Port switched to" $port -u low
  }
}


def cycle_sink [] {
  let next_sink = do {
    let running_sink = $sinks|find --columns [state] RUNNING
    if ($running_sink|is-empty) {
      if ($cache_file|path exists) and ($sinks|length) > 1 {
        let sink = (open $cache_file)
        $sinks|enumerate|find $sink.name|if ($in|is-not-empty) {
          let sink_index = $in|get index.0
          return ($sinks|enumerate|roll up --by $sink_index|skip|get item.0)
        }
      }
      return ($sinks|sort-by id|first)
    }

    let possible_next_sinks = $sinks|where id > $running_sink.0.id
    if ($possible_next_sinks|is-empty) {
      $sinks|sort-by id|first
    } else {
      $possible_next_sinks|first
    }
  }


  return $next_sink
}

def cycle_port []: nothing -> record<sink: string, port: string> {
  let running_sinks = $sinks|find --columns [state] RUNNING

  $running_sinks|filter {|| $in|columns|find ports|is-not-empty}|collect {|sink| 
    if ($sink | is-empty) or (($sink | get ports.0 | length) <= 1) { return [] }
    let active_port = $sink|get active_port.0
    let ports = $sink|get ports.0
    let active_port_index = $ports|enumerate|find $active_port|get index.0

    let next_port: string = ($ports|enumerate|roll up --by $active_port_index|skip|get item.0)

    return {
      sink: ($sink|into record)
      port: $next_port
    }
  }
}

# Move all audio streams to next sink
def "main sink" [
  --active # Print active sink
  --format: string # format active sink [id|name|description]
] {
  if $active {
    let running_sinks = $sinks|find --columns [state] RUNNING
    if ($running_sinks|is-empty) {
      if not ($cache_file|path exists) {
        print "Nenhuma mídia tocando no momento"
        return
      }

      return (open $cache_file)
    } 

    if $format == "description" {
      print ($running_sinks|first|get description)
    } else if $format == "id" {
      print ($running_sinks|first|get id)
    } else {
      print ($running_sinks|first|get name)
    }
    return
  }

  let next_sink = cycle_sink
  set_sink $next_sink
}

# Move all audio streams to next port on active sink
def "main port" [
  --active # Print active port
] {
  if $active {
    let running_sinks = $sinks|find --columns [state] RUNNING
    if ($running_sinks|is-empty) {
      if not ($cache_file|path exists) {
        print "Nenhuma mídia tocando no momento"
        return
      }

      let sink = (open $cache_file)

      if ($sink | is-empty) or ($sink | columns| find active_port| is-empty) {
        print "Nenhuma mídia tocando no momento"
        return
      }

      let active_port = $sink|get active_port
      return $active_port
    }

    let active_port = $running_sinks|filter {|| $in|columns|find ports|is-not-empty}|get active_port.0

    return $active_port
  }

  let next_port = cycle_port
  set_port $next_port.sink $next_port.port
}

# Move all audio streams to next sink or port
def main [
  --active # Print active sink (that is playing sound)
  --refresh
  --debug
] { 
  if $debug {
    return $sinks
  }

  if $refresh and ($cache_file|path exists) {
    let sink = (open $cache_file)
    set_sink $sink --hide_notifications
    if ($sink|columns|find active_port|is-not-empty) {
      set_port $sink $sink.active_port --hide_notifications
    }
    return
  }

  if $active {
    return (main sink --active)
  }
  main sink
}
