#!/usr/bin/env nu
use std assert

def main [
  --vault = "/mnt/DiscoExterno/ObsidianVaults/USP" # obsidian vault
  --subfolder = "7 Semestre" # subfolder to search
  --excluded = "Rascunhos, Mídia, Notebooks"
] {


  # CONSTANTS
  let DOWNLOADS_FOLDER = ([$env.HOME 'Downloads']|path join)
  let VAULT_PATH = $vault
  let semestre_atual = $subfolder
  let excluded_subfolders = ($excluded|split row ","|each {|| str trim})
  let priority = ['pdf' 'png' 'jpeg' 'jpg']
  # let excluded_subfolders = ['Rascunhos' 'Mídia' 'Notebooks']

  # Sort downloads
  let downloads_files = (ls $DOWNLOADS_FOLDER|where type == file)
  let priority_files = ($downloads_files | filter {|| ($in.name|path parse).extension in $priority} | sort-by modified -r)
  let not_priority_files = ($downloads_files | filter {|| not (($in.name|path parse).extension in $priority)}| sort-by modified -r)

  let target_files = ($priority_files ++ $not_priority_files| get name)

  # rofi select file
  let selected_file = $target_files
  |each {|f| $"($f|path basename)\u{0}icon\u{1f}($f|path parse|get extension)\u{1f}meta\u{1f}($f)"}
  |to text
  |rofi -dmenu -i

  assert ($selected_file != '') 'Empty selected_file'


  # rofi select folder (course)
  mut folders = [$VAULT_PATH $semestre_atual]|path join|ls $in| where type == dir|each {|| $in.name|path basename}|filter {|| not ($in in $excluded_subfolders)}

  mut selected_folder = ''
  if ($folders|length) > 1 {
    if 'Material' in $folders {
      $folders = ($folders|filter {|| $in != 'Material'} | prepend 'Material')
    }

    $selected_folder = ($folders|to text|rofi -dmenu -i -normalize-match)
  } else if ($folders|length) == 1 {
    $selected_folder = ($folders|first)
  }


  assert ($selected_folder != '') 'Empty selected_folder'

  # rofi select sub_folder
  mut subfolders = [$VAULT_PATH $semestre_atual $selected_folder]|path join|ls $in| where type == dir|each {|| $in.name|path basename}|filter {|| not ($in in $excluded_subfolders)}

  mut selected_subfolder = ''
  if ($subfolders|length) > 1 or $selected_folder == "Material" {
    if 'Material' in $subfolders {
      $subfolders = ($subfolders|filter {|| $in != 'Material'} | prepend 'Material')
    }
    if $selected_folder == "Material" {
      $subfolders = ($subfolders | prepend '.')
    }

    $selected_subfolder = ($subfolders|to text|rofi -dmenu -i -normalize-match)
  } else if ($subfolders|length) == 1 {
    $selected_subfolder = ($subfolders|first)
  }

  assert ($selected_subfolder != '') 'Empty selected_subfolder'

  if $selected_subfolder == '.' {
    $selected_subfolder = ''
  }

  # Move file
  let target_folder_path = [$VAULT_PATH $semestre_atual $selected_folder $selected_subfolder]|path join

  let selected_file_path = [$DOWNLOADS_FOLDER $selected_file]|path join
  let target_path = [$target_folder_path $selected_file]|path join

  if not ($target_path|path exists) {
    mv -n $selected_file_path $target_folder_path 
    notify-send $'Moved to "($selected_folder)/($selected_subfolder)"' $selected_file
  } else {

    let identical = (cmp $selected_file_path $target_path|is-empty)
    let actions = if $identical {
      ['cancel', 'delete', 'delete then open target']
    } else {
      ['cancel', 'delete', 'rename', 'overwrite']
    }

    let selected_action = $actions|to text|rofi -dmenu
    match $selected_action { 
    'delete' => {
      rm $selected_file_path
      notify-send 'Deleted' $selected_file
    }
    'rename' => {
      alias mv_native = /usr/bin/mv
      mv_native --backup=existing $selected_file_path $target_folder_path
      notify-send $'Moved with rename to "($selected_folder)/($selected_subfolder)"' $selected_file
    }
    'overwrite' => {
      mv $selected_file_path $target_folder_path 
      notify-send $'Ovewrited to "($selected_folder)/($selected_subfolder)"' $selected_file
    }
    'delete then open target' => {
      rm $selected_file_path
      notify-send 'Deleted' $selected_file
      xdg-open $target_path 
    }
    _ => {
      notify-send 'Move to Obsidian' 'aborted'
      exit
    }
  }
  }

  $"[[($selected_file)]]"|xclip -sel clipboard

}
