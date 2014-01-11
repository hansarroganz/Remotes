-- TODO:
-- * Add support for send text
-- * Add support for library browsing (http://.../library)

-- REFERENCE:
-- * I couldn't find any official documentation...
-- * https://forums.plex.tv/index.php/topic/15850-plex-9-remote-api/

events.create = function ()
	
end

events.focus = function ()
	update_server();
	update_players();
end

local server = "";
local player = "";
local players = {};
local playersList = {};

function update_server()
	server = properties.server;
	print(server);
	if (server == "") then
		-- Try to find a server...
		libs.device.toast("Looking for Plex servers...");
		
		local res = libs.http.discover({ port = 32400 });
		if (#res == 0) then
			server = "localhost";
			libs.device.toast("No servers find...");
			libs.device.toast("Using localhost for now...");
		else
			server = res[1];
			properties.server = server;
			libs.device.toast("Found server: " .. server);
		end
	else
		libs.device.toast("Saved server: " .. server);
	end
end

function update_players()
	local xml = libs.http.get("http://" .. server .. ":32400/clients");
	local MediaContainer = libs.data.fromxml(xml);
	
	player = "localhost";
	players = {};
	playersList = {};
	
	local savedPlayer = properties.player;
	for i,v in ipairs(MediaContainer.children) do
		if (v.name == "Server") then
			local playerName = v.attributes.name;
			local playerHost = v.attributes.host;
			
			if (i == 1) then
				player = playerName;
			end
			if (playerName == savedPlayer) then
				player = savedPlayer;
			end
			
			table.insert(players, playerName);
			local checked = (playerName == player);
			local text = playerName .. "\n" .. playerHost;
			table.insert(playersList, { type = "item", checked = checked, text = text });
		end
	end
	
	libs.server.update({ id = "players", children = playersList });
end

function url(controller, action)
	local url = "http://" .. server .. ":32400";
	url = url .. "/system/players/" .. player;
	url = url .. "/" .. controller;
	url = url .. "/" .. action;
	return url;
end

function send(controller, action)
	local _url = url(controller, action);
	libs.http.get(_url);
end

-------------------------------------------
-- Misc
-------------------------------------------

text = "";

actions.text_changed = function (s)
	text = s;
	print(text);
end

actions.send_text = function ()
	-- The API call does not seem to work...
	local _url = url("application", "sendString");
	_url = _url .. "?text=" .. text;
	libs.http.get(_url);
end

actions.select_player = function (i)
	properties.player = players[i + 1];
	update_players();
end

-------------------------------------------
-- Navigation
-------------------------------------------

actions.up = function ()
	send("navigation", "moveUp");
end

actions.down = function ()
	send("navigation", "moveDown");
end

actions.left = function ()
	send("navigation", "moveLeft");
end

actions.right = function ()
	send("navigation", "moveRight");
end

actions.page_up = function ()
	send("navigation", "pageUp");
end

actions.page_down = function ()
	send("navigation", "pageDown");
end

actions.next_letter = function ()
	send("navigation", "nextLetter");
end

actions.previous_letter = function ()
	send("navigation", "previousLetter");
end

actions.select = function ()
	send("navigation", "select");
end

actions.back = function ()
	send("navigation", "back");
end

actions.menu = function ()
	send("navigation", "contextMenu");
end

actions.osd = function ()
	send("navigation", "toggleOSD");
end

-------------------------------------------
-- Playback
-------------------------------------------

actions.play = function ()
	send("playback", "play");
end

actions.pause = function ()
	send("playback", "pause");
end

actions.play_pause = function ()
	send("playback", "play");
end

actions.stop = function ()
	send("playback", "stop");
end

actions.rewind = function ()
	send("playback", "rewind");
end

actions.forward = function ()
	send("playback", "fastForward");
end

actions.step_forward = function ()
	send("playback", "stepForward");
end

actions.big_step_forward = function ()
	send("playback", "bigStepForward");
end

actions.step_back = function ()
	send("playback", "stepBack");
end

actions.bigStepBack = function ()
	send("playback", "bigStepBack");
end

actions.next = function ()
	send("playback", "skipNext");
end

actions.previous = function ()
	send("playback", "skipPrevious");
end