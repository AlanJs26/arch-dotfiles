#!/usr/bin/env nu

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

def cycle_sink [] {
  let next_sink = do {
    let running_sink = $sinks|find --columns [state] RUNNING
    if ($running_sink|is-empty) {
      return ($sinks|sort-by id|first)
    }

    let possible_next_sinks = $sinks|where id > $running_sink.0.id
    if ($possible_next_sinks|is-empty) {
      $sinks|sort-by id|first
    } else {
      $possible_next_sinks|first
    }
  }

  pactl set-default-sink $next_sink.name
  $sink_inputs|each {||
    pactl move-sink-input $in.id $next_sink.name
  }

  notify-send -a bspwm -i "/usr/share/icons/Tela-circle-dark/16/actions/audio-ready.svg" "Sound output switched to" $next_sink.name -u low
}

def cycle_port [] {
  let running_sinks = $sinks|find --columns [state] RUNNING

  $running_sinks|filter {|| $in|columns|find ports|is-not-empty}|collect {|| 
    if ($in | is-empty) or (($in | get ports.0 | length) <= 1) { return [] }
    let active_port = $in|get active_port.0
    let ports = $in|get ports.0
    let active_port_index = $ports|enumerate|find $active_port|get index.0

    let next_port = $ports|enumerate|roll up --by $active_port_index|skip|get item.0

    let sink_id = $in|get id.0
    let sink_name = $in|get name.0

    pactl set-default-sink $sink_name
    pactl set-sink-port $sink_id $next_port

    notify-send -a bspwm -i "/usr/share/icons/Tela-circle-dark/16/actions/audio-ready.svg" "Port switched to" $next_port -u low
  }
}

# Move all audio streams to next sink
def "main sink" [
  --active # Print active sink
] {
  if $active {
    let running_sinks = $sinks|find --columns [state] RUNNING
    if ($running_sinks|is-empty) {
      print "Nenhuma mídia tocando no momento"
      return
    } 
    print ($running_sinks|first|get name)
    return
  }

  cycle_sink
}

# Move all audio streams to next port on active sink
def "main port" [
  --active # Print active port
] {
  if $active {
    let running_sinks = $sinks|find --columns [state] RUNNING
    if ($running_sinks|is-empty) {
      print "Nenhuma mídia tocando no momento"
      return
    } 

    let active_port = $running_sinks|filter {|| $in|columns|find ports|is-not-empty}|get active_port.0

    print $active_port
    return
  }

  cycle_port
}

# Move all audio streams to next sink or port
def main [
  --active # Print active sink (that is playing sound)
] { 
  if $active {
    main sink --active
    return
  }
  main sink
}
