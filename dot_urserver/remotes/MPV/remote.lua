function string:startswith(start)
    return self:sub(1, #start) == start
end

function table:find_by_key(query)
    for k,v in pairs(self) do
        if k == query then
            return v
        end
    end
    return nil
end

function split_by_type(list)
		type_table = {}

		if type(list) == 'table' then
			if list == nil or #list == 0 then
				return nil
			end
		else
			type_table[type(list)] = {list}
			return type_table
		end
    
    for _,value in ipairs(list) do
        if table.find_by_key(type_table, type(value)) == nil then
            type_table[type(value)] = {value}
        else
            table.insert(type_table[type(value)], value)
        end
    end
    
    return type_table
end

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

function shell(command)
	libs.script.shell(command)
end
function seticon(id, icon)
	libs.server.update({id = id, icon = icon})
end
function settext(id, text)
	libs.server.update({id = id, text = text})
end
function toggleicon(id, boolean, icon_a, icon_b)
	iconname = icon_b
	if boolean == true then
		iconname = icon_a
	end

	seticon(id, iconname)
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


actions.seek = function(pos)
	local cmd = "echo '{ \"command\": [\"set_property\", \"percent-pos\", ".. pos .."] }' | socat - /tmp/mpv-socket"

	shell(cmd)
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

	shell(cmd)
	actions.refreshlist()
end


 -- ---------------------

actions_table = {
	--@help show shutdown menu
	showpowermenu = {'win', 'shift', 'e'},


	sendtoavailableworkspace = {
		not_iswindowsfocusmode = {function()
				shell("bspc desktop -f any.local.!occupied");
		end},
		iswindowsfocusmode = {
			isholdingwindow = {function() 
				shell("bspc node -d any.local.!occupied");
			end},
			not_isholdingwindow = {function() 
				shell("bspc node -d any.local.!occupied --follow");
			end},
		},

	},

	focusnextscreen = {
		iswindowsfocusmode = {"win", "u"},
		not_iswindowsfocusmode = {"win", "ctrl", "shift", "l"},
	},

	windowmodetogglebutton = {
		toggle_state = 'iswindowsfocusmode',
		function(state_table)
			iswindowsfocusmode = table.find_by_key(state_table, 'iswindowsfocusmode')

			toggleicon("windowmodetogglebutton", iswindowsfocusmode, 'off', 'on')
		end,


		iswindowsfocusmode = {function()
			settext("windowtogglebutton", 'Enter')
			seticon("focusnextscreen", 'fullscreen')
			seticon("sendtoavailableworkspace", 'docswitch')
		end},
		not_iswindowsfocusmode = {function(state_table)
			isholdingwindow = table.find_by_key(state_table, 'isholdingwindow')

			toggleicon("windowtogglebutton", isholdingwindow, 'lock', 'unlock')
			seticon("focusnextscreen", 'shuffle')
			seticon("sendtoavailableworkspace", 'eject')
		end},

	},

	--@help toggles global state for holding (to move windows) or focusing windows
	windowtogglebutton = {
		iswindowsfocusmode = {'enter'},

		not_iswindowsfocusmode = {
			toggle_state = 'isholdingwindow',
			function(state_table)
				isholdingwindow = table.find_by_key(state_table, 'isholdingwindow')

				toggleicon("windowtogglebutton", isholdingwindow, 'unlock', 'lock')
			end,
		}
	},

	--@help focus window on up,left,right or down
	focuswintop = {
		iswindowsfocusmode = {'up'},
		not_iswindowsfocusmode = {
			isholdingwindow = {'win', 'shift', 'k'},
			not_isholdingwindow = {'win', 'k'},
		}
	},
	focuswinleft = {
		iswindowsfocusmode = {'left'},
		not_iswindowsfocusmode = {
			isholdingwindow = {'win', 'shift', 'h'},
			not_isholdingwindow = {'win', 'h'},
		}
	},
	focuswinright = {
		iswindowsfocusmode = {'right'},
		not_iswindowsfocusmode = {
			isholdingwindow = {'win', 'shift', 'l'},
			not_isholdingwindow = {'win', 'l'},
		}
	},
	focuswindown = {
		iswindowsfocusmode = {'down'},
		not_iswindowsfocusmode = {
			isholdingwindow = {'win', 'shift', 'j'},
			not_isholdingwindow = {'win', 'j'},
		}
	},

	--@help focus next workspace
	focusprevworkspace = {"win", "shift", "tab"},

	--@help focus previous workspace
	focusnextworkspace = {"win", "tab"},

	--@help close mpv natively
	closempv = {"shift", "q"},

	--@help raise volume in app
	volume_up_mpv = "up",

	--@help lower volume in app
	volume_down_mpv = "down",

	--@help show applications menu
	showrunmenu = {"win", "space"},

	--@help close focused windows
	closewin = {"win", "shift", "q"},

	--@help press escape
	esc = "esc",
	
	--@help Lower volume
	volume_down = "volumedown",

	--@help Raise volume
	volume_up = "volumeup",

	--@help Skip to the next silent segment
	skip_segment = "tab",

	--@help MPV Lower volume
	mpvvolume_down = "down",

	--@help MPV Raise volume
	mpvvolume_up = "up",

	--@help Mute volume
	volume_mute = "M",

	--@help Forward 10 seconds
	right = "right",

	--@help Forward 1 second
	rightBit = {"shift", "right"},

	--@help Toggle play pause state
	play_pause = "space",
	-- "play_pause" = "mediaplaypause",

	--@help Rewind 10 seconds
	left = "left",

	--@help Rewind 1 second
	leftBit = {"shift", "left"},

	--@help Toggle fullscreen
	fullscreen = "F",

	--@help Previous
	prevEp = "mediaprevious",

	--@help Next
	nextEp = "medianext",

	--@help Go to scratchpad
	hide = {"win", "alt", "a"},

	--@help Go out scratchpad
	show = {"win", "shift", "a"},

}



-- rule: {
-- *string,
-- [state] = rule,
-- not_[state] = rule,
-- set_state = string|{*string}, 
-- unset_state = string|{*string},  
-- toggle_state = string|{*string},  
-- }
--
-- state: {
-- 	[key] = boolean
-- }


function perform_rule(rule, state_table)
        
		keys_by_type = split_by_type(rule)

		if keys_by_type ~= nil then
			if table.find_by_key(keys_by_type, 'string') ~= nil then
				keyboard.stroke(unpack(keys_by_type['string']))
			end
			if table.find_by_key(keys_by_type, 'function') ~= nil then
				for _, f in ipairs(keys_by_type['function']) do
					new_state_table = f(state_table)

					if new_state_table ~= nil then
						state_table = new_state_table
					end
				end
			end
		end

    processed_states = {}

    for state, state_rule in pairs(rule) do
        value = state_rule

				if type(state) == 'number' then
				elseif state == 'set_state' or state == 'unset_state' then
						new_state = (state == 'set_state')

						if type(value) == 'string' then
								state_table[value] = new_state
						elseif type(value) == 'table' then
								for _,v in ipairs(value) do
										state_table[v] = new_state
								end
						end
				elseif state == 'toggle_state' then
						if table.find_by_key(state_table, value) == nil then
								state_table[value] = true
						else
								state_table[value] = not state_table[value]
						end
				elseif table.find_by_key(processed_states, state) == nil 
					 and (state:startswith('not_') == false and table.find_by_key(state_table, state) == true
						or  state:startswith('not_') == true  and table.find_by_key(state_table, state:sub(5, #state)) ~= true) then
						state_table = perform_rule(state_rule, state_table)
						table.insert(processed_states, state)                
				end



    end

    return state_table
end


 -- -----------------------
state_table = {}

for action_name, action_rule in pairs(actions_table) do

	if type(action_rule) == 'string' then
		actions[action_name] = function()
			keyboard.stroke(action_rule)
		end
	elseif type(action_rule) == 'function' then
		actions[action_name] = function()
			new_state_table = action_rule(state_table)

			if new_state_table ~= nil then
				state_table = new_state_table
			end
		end
	elseif type(action_rule) == 'table' then
		actions[action_name] = function()
			perform_rule(action_rule, state_table)
		end
	end

end


--@help Launch daemon
actions.launch = function()
	-- actions.refreshtitle()
	-- actions.refreshlist()
	refreshpos()
end


actions.launch()
