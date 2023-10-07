
function string:split( inSplitPattern, outResults )
  if not outResults then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end

local keyboard = libs.keyboard;
local tid = -1

function refreshpos()
	local cmd = "echo '{ \"command\": [\"get_property\", \"percent-pos\"] }' | socat - /tmp/mpv-socket | \"/home/alan/miniconda3/bin/python\" \"/home/alan/Documentos/Codes/lua/jsontest/convert.py\""
	local out = "";

	local handle = io.popen(cmd) 
	out = handle:read("*a")
	handle:close()

	if type(tonumber(out)) == "number" then
		libs.server.update({ id = "pos", progress = math.floor(tonumber(out)+0.5)  })
		actions.refreshlist()
	end
	tid = libs.timer.timeout(refreshpos, 500)
end

actions.closempv = function()
	keyboard.stroke("shift", "q")
end

actions.volume_up_mpv = function()
	keyboard.stroke("up")
end

actions.volume_down_mpv = function()
	keyboard.stroke("down")
end

actions.seek = function(pos)
	local cmd = "echo '{ \"command\": [\"set_property\", \"percent-pos\", ".. pos .."] }' | socat - /tmp/mpv-socket"

	libs.script.shell(cmd)
end


--@help Lower volume
actions.volume_down = function()
	keyboard.stroke("volumedown");
end

--@help Raise volume
actions.volume_up = function()
	keyboard.stroke("volumeup");
end

--@help Skip to the next silent segment
actions.skip_segment = function()
	keyboard.stroke("tab");
end

--@help MPV Lower volume
actions.mpvvolume_down = function()
	keyboard.stroke("down");
end

--@help MPV Raise volume
actions.mpvvolume_up = function()
	keyboard.stroke("up");
end

--@help Mute volume
actions.volume_mute = function()
	keyboard.stroke("M");
end

--@help Forward 10 seconds
actions.right = function()
	keyboard.stroke("right");
end

--@help Forward 1 second
actions.rightBit = function()
	keyboard.stroke("shift", "right");
end

--@help Toggle play pause state
actions.play_pause = function()
	-- keyboard.stroke("mediaplaypause");
	keyboard.stroke("space");
end

--@help Rewind 10 seconds
actions.left = function()
	keyboard.stroke("left");
end

--@help Rewind 1 second
actions.leftBit = function()
	keyboard.stroke("shift", "left");
end

--@help Toggle fullscreen
actions.fullscreen = function()
	keyboard.stroke("F");
end

--@help Previous
actions.prevEp = function()
	keyboard.stroke("mediaprevious");
end

--@help Next
actions.nextEp = function()
	keyboard.stroke("medianext");
end

--@help Go to scratchpad
actions.hide = function()
	keyboard.stroke("win", "ctrl", "m");
end

--@help Go out scratchpad
actions.show = function()
	keyboard.stroke("win", "ctrl", "a");
end


actions.refreshtitle = function()
	local cmd = "echo '{ \"command\": [\"get_property\", \"media-title\"] }' | socat - /tmp/mpv-socket | \"/home/alan/miniconda3/bin/python\" \"/home/alan/Documentos/Codes/lua/jsontest/convert.py\""
	local out = "";

	local handle = io.popen(cmd) 
	out = handle:read("*a")
	handle:close()

	if out then
		layout.title.text = out
	end
end

actions.refreshlist = function()
	local cmd = "echo '{ \"command\": [\"get_property\", \"playlist\"] }' | socat - /tmp/mpv-socket | \"/home/alan/miniconda3/bin/python\" \"/home/alan/Documentos/Codes/lua/jsontest/convert.py\""
	local out = "";

	local handle = io.popen(cmd) 
	out = handle:read("*a")
	handle:close()

	if out then
		local outlist = {}
		local rawlist = out:split("====")
		for i=1, #rawlist do
			if rawlist[i]:find("&&") then
				table.insert(outlist, {type="item", text = rawlist[i]:sub(0, -3), icon = "pause"})
			else
				table.insert(outlist, {type="item", text = rawlist[i], icon = "play"})
			end
		end
		--layout.output.text = out:split("====")[1]
		libs.server.update({id = "list", children = outlist})
	end
	actions.refreshtitle()
end

actions.listitem = function(index)
	local cmd = "echo '{ \"command\": [\"set_property\", \"playlist-pos\", ".. index .."] }' | socat - /tmp/mpv-socket"

	libs.script.shell(cmd)
	actions.refreshlist()
end

-- true = focus window
-- false = move window
local isholdingwindow = false

-- true = focus and move windows
-- false = arrow keys
local iswindowsfocusmode = false

 -- ---------------------
actions.sendtoavailableworkspace = function()
	if iswindowsfocusmode then
		keyboard.stroke("win", "r");
	else
		if isholdingwindow then
			libs.script.shell('i3-msg "move container to workspace next_on_output; workspace next_on_output"');
		else
			libs.script.shell("/usr/bin/i3-next-workspace --move-window");
		end
	end
end
actions.focusnextscreen = function()
	if iswindowsfocusmode then
		keyboard.stroke("win", "f");
	else
		keyboard.stroke("win", "ctrl", "l");
	end
end

actions.focusnextworkspace = function()
	keyboard.stroke("win", "shift", "tab");
end
actions.focusprevworkspace = function()
	keyboard.stroke("win", "tab");
end
actions.windowmodetogglebutton = function()
	iswindowsfocusmode = not iswindowsfocusmode

	local iconname = (iswindowsfocusmode and 'on') or 'off'

	libs.server.update({id = "windowmodetogglebutton", icon = iconname})

	if iswindowsfocusmode then
		libs.server.update({id = "windowtogglebutton", text = 'Enter'})
		libs.server.update({id = "focusnextscreen", icon = 'fullscreen'})
		libs.server.update({id = "sendtoavailableworkspace", icon = 'docswitch'})
	else
		libs.server.update({id = "windowtogglebutton", icon = (isholdingwindow and 'lock') or 'unlock'})
		libs.server.update({id = "focusnextscreen", icon = 'shuffle'})
		libs.server.update({id = "sendtoavailableworkspace", icon = 'eject'})
	end

	
end
actions.windowtogglebutton = function()

	if iswindowsfocusmode then
		keyboard.stroke("enter");

		return
	end


	isholdingwindow = not isholdingwindow

	local iconname = (isholdingwindow and 'lock') or 'unlock'

	libs.server.update({id = "windowtogglebutton", icon = iconname})
end
actions.focuswinup = function()
	if iswindowsfocusmode then
		keyboard.stroke("up");
		return
	end

	if isholdingwindow then
		keyboard.stroke("win", "shift", "up");
	else
		keyboard.stroke("win", "up");
	end
end
actions.focuswinleft = function()
	if iswindowsfocusmode then
		keyboard.stroke("left");
		return
	end

	if isholdingwindow then
		keyboard.stroke("win", "shift", "left");
	else
		keyboard.stroke("win", "left");
	end
end
actions.focuswinright = function()
	if iswindowsfocusmode then
		keyboard.stroke("right");
		return
	end

	if isholdingwindow then
		keyboard.stroke("win", "shift", "right");
	else
		keyboard.stroke("win", "right");
	end
end
actions.focuswindown = function()
	if iswindowsfocusmode then
		keyboard.stroke("down");
		return
	end

	if isholdingwindow then
		keyboard.stroke("win", "shift", "down");
	else
		keyboard.stroke("win", "down");
	end
end
actions.showrunmenu = function()
	keyboard.stroke("win", "space");
end
actions.closewin = function()
	keyboard.stroke("win", "shift", "q");
end
actions.showpowermenu = function()
	keyboard.stroke("win", "shift", "e");
end
actions.esc = function()
	keyboard.stroke("esc");
end
 -- -----------------------




--@help Launch Crunchroll
actions.launch = function()
	-- actions.refreshtitle()
	-- actions.refreshlist()
	refreshpos()
end


actions.launch()
