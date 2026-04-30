#!/usr/bin/nu

let clients = (hyprctl clients -j|from json)

def has [target, --by: string] {
  if ($by|is-not-empty) {
    any {||($in|get $by) == ($target|get $by)}
  } else {
    any {||$in == $target}
  }
}

def filter_clients [queries] {
  ($queries|where $it != "-and"|split list "-or"|each {|queries|
    $queries|each {|raw_query|
      let is_title = match ($raw_query|split row ":"|take 1) {
        ["class"] => false
        ["title"] => true
        _ => true
      }

      let query = ($raw_query|str replace -r '^(title|class):' '')

      let matches = if $is_title {
        ($clients|where title =~ $query)
      } else {
        ($clients|where class =~ $query)
      }
      # print ($matches|get title)
      $matches

    }|reduce --fold ($in|flatten|uniq-by address) {|next, acc|
      ($acc|where {|x|$next|has $x --by address})
    }
  })|flatten|uniq-by address|update focusHistoryID {into int}|sort-by focusHistoryID
}

# Cycles between matching apps
def --wrapped main [ ...args ] {
  if ($args|is-empty) {
    exit 1
  }

  let by_workspace = ($args|has "--by-workspace")
  let allow_special = ($args|has "--allow-special")
  let allow_floating = ($args|has "--allow-floating")
  let bring_window = ($args|has "--bring-window")

  let args_pair = match ($args
    |where $it != "--by-workspace"
    |where $it != "--bring-window"
    |where $it != "--allow-special"
    |where $it != "--allow-floating"
    |split list "--not") {
    [$a, $b] => [$a, $b]
    [$a] => [$a, []]
    _ => {
      print "You must provide a single --not or any"
      exit 1
    }
  }

  let yes_matches = (filter_clients $args_pair.0)
  let not_matches = (filter_clients $args_pair.1)

  let focused_client = (hyprctl activewindow -j|from json)

  let matches = ($yes_matches|where {|x|
    not ($not_matches|has $x --by address)
  }|if not $allow_special {
    $in|where workspace.id >= 0
  } else {
    $in
  }|if not $allow_floating {
    $in|where floating == false
  } else {
    $in
  })

  if ($matches|is-empty) {
    print "no matches"
    exit 1
  }

  let flatten_by_workspace = ($matches|group-by workspace.id|values|each {
    if ($in|has $focused_client --by address) {
      $in|where address == $focused_client.address
    } else {
      $in|select 0
    }
  }|flatten|sort-by focusHistoryID)

  if (
    $by_workspace and
    ($flatten_by_workspace|length) == 1 and
    ($focused_client|is-not-empty) and
    ($flatten_by_workspace.0.workspace.id == $focused_client.workspace.id)
  ) {
    print "Single match. Focusing previous workspace"
    hyprctl dispatch workspace previous
    exit
  }

  if $by_workspace and ($flatten_by_workspace|length) > 1 {
    print $"By Workspace - (ansi cyan)\(*\) = selected window(ansi default)"

    for client in $flatten_by_workspace {
      if ($focused_client|is-not-empty) and ($client.address == $focused_client.address) {
        print $"(ansi cyan)\(*\)(ansi default) ($client.workspace.id) - ($client.title)"
      } else {
        print $"    ($client.workspace.id) - ($client.title)"
      }
    }
    print ''

    let target_workspace = if ($focused_client|is-not-empty) {
      ($flatten_by_workspace|skip while {$in.focusHistoryID <= $focused_client.focusHistoryID}|take 1)
    } else {
      []
    }

    if ($target_workspace|is-empty) {
      print $"Focusing workspace ($flatten_by_workspace.0.workspace.id)"
      hyprctl dispatch workspace $flatten_by_workspace.0.workspace.id
    } else {
      print $"Focusing workspace ($target_workspace.0.workspace.id)"
      hyprctl dispatch workspace $target_workspace.0.workspace.id
    }

  } else if ($bring_window and ($matches|length) >= 1) {
    print $"Bring window - (ansi cyan)\(*\) = selected window(ansi default)"

    for client in $matches {
      if ($focused_client|is-not-empty) and ($client.address == $focused_client.address) {
        print $"(ansi cyan)\(*\)(ansi default) ($client.title)"
      } else {
        print $"    ($client.title)"
      }
    }
    print ''

    let target_client = ($matches|skip while {$in.address <= $focused_client.address}|take 1)
    if ($target_client|is-empty) {
      print $"Bringing window ($matches.0.title)"
      hyprctl dispatch movetoworkspace $"+0,address:($matches.0.address)"
    } else {
      print $"Bringing window ($target_client.0.title)"
      hyprctl dispatch movetoworkspace $"+0,address:($target_client.0.address)"
    }


  } else {
    if not $by_workspace and ($matches|length) == 1 {
      print "Single match. Focusing previous window"
      hyprctl dispatch focuscurrentorlast
      exit
    }

    print $"By Window - (ansi cyan)\(*\) = selected window(ansi default)"

    for client in $matches {
      if ($focused_client|is-not-empty) and ($client.address == $focused_client.address) {
        print $"(ansi cyan)\(*\)(ansi default) ($client.title)"
      } else {
        print $"    ($client.title)"
      }
    }
    print ''

    if ($focused_client|is-empty) {
      print $"Focusing window ($matches.0.title)"
      hyprctl dispatch focuswindow $"address:($matches.0.address)"
      exit
    }

    let target_client = ($matches|skip while {$in.address <= $focused_client.address}|take 1)
    if ($target_client|is-empty) {
      print $"Focusing window ($matches.0.title)"
      hyprctl dispatch focuswindow $"address:($matches.0.address)"
    } else {
      print $"Focusing window ($target_client.0.title)"
      hyprctl dispatch focuswindow $"address:($target_client.0.address)"
    }
  }
}
