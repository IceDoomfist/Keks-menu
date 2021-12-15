-- Kek's menu version 0.4.5.1
-- Copyright © 2020-2021 Kektram
if __kek_menu_version then 
	menu.notify("Kek's menu is already loaded!", "Initialization cancelled.", 3, 211) 
	return
end

__kek_menu_version = "0.4.5.1"

do
	if utils.file_exists(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\kekMenuLibs\\Debugger.lua") then
		local file = io.open(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\keksettings.ini")
		if file then
			local str <const> = file:read("*a")
			file:close()
			if str:match("Debug mode=(%a%a%a%a)") == "true" then
				dofile(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\kekMenuLibs\\Debugger.lua")
			end
		end
	end
end

if not (package.path or ""):find(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\kekMenuLibs\\?.lua;", 1, true) then
	package.path = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\kekMenuLibs\\?.lua"..";"..(package.path or "")
end

collectgarbage("incremental", 110, 100, 10)
math.randomseed(math.floor(os.clock()) + os.time())

local o <const> = {}
local u <const> = {}
local paths <const> = {
	home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\",
	kek_menu_stuff = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\"
}

local player_feat_ids <const> = {}

do -- Makes sure each library is loaded once and that every time one is required, has the same environment as the others
	local original_require <const> = require
	require = function(...)
		local name <const> = ...
		local lib <const> = package.loaded[name] or original_require(name)
		if not lib then
			menu.notify("Failed to load "..name..". Fix it goddamnit...", "Error", 6, 112)
			error(debug.traceback("Failed to load "..name..". Fix it goddamnit...", 2))
		end
		if not package.loaded[name] then
			package.loaded[name] = lib
		end
		return package.loaded[name]
	end

	for name, version in pairs({
		["Language"] = "1.0.0",
		["Settings"] = "1.0.0",
		["Essentials"] = "1.3.6",
		["Enums"] = "1.0.0",
		["Vehicle mapper"] = "1.3.4", 
		["Ped mapper"] = "1.2.6",
		["Object mapper"] = "1.2.5", 
		["Globals"] = "1.2.7",
		["Weapon mapper"] = "1.0.4",
		["Location mapper"] = "1.0.1",
		["Keys and input"] = "1.0.7",
		["Drive style mapper"] = "1.0.4",
		["Menyoo spawner"] = "2.0.2",
		["Kek's entity functions"] = "1.1.8",
		["Kek's trolling entities"] = "1.0.7",
		["Custom upgrades"] = "1.0.1",
		["Admin mapper"] = "1.0.3",
		["Vehicle saver"] = "1.0.8"
	}) do
		if not utils.file_exists(paths.kek_menu_stuff.."kekMenuLibs\\"..name..".lua") then
			menu.notify(package.loaded["Language"].lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu. §"].."\n["..name.."]", "Kek's "..__kek_menu_version, 6, 112)
			error(package.loaded["Language"].lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu. §"])
		else
			require(name)
		end
		if package.loaded[name].version ~= version then
			menu.notify(package.loaded["Language"].lang["There's a library file which is the wrong version, please reinstall kek's menu. §"].." ["..name.."]", "Kek's "..__kek_menu_version, 6, 112)
			error(package.loaded["Language"].lang["There's a library file which is the wrong version, please reinstall kek's menu. §"])
		end
	end
	require = original_require
end

local language <const> = package.loaded["Language"]
local settings <const> = package.loaded["Settings"]
local lang <const> = language.lang
local essentials <const> = package.loaded["Essentials"]
local enums <const> = package.loaded["Enums"]
local weapon_mapper <const> = package.loaded["Weapon mapper"]
local location_mapper <const> = package.loaded["Location mapper"]
local keys_and_input <const> = package.loaded["Keys and input"]
local drive_style_mapper <const> = package.loaded["Drive style mapper"]
local globals <const> = package.loaded["Globals"]
local vehicle_mapper <const> = package.loaded["Vehicle mapper"]
local ped_mapper <const> = package.loaded["Ped mapper"]
local object_mapper <const> = package.loaded["Object mapper"]
local menyoo <const> = package.loaded["Menyoo spawner"]
local kek_entity <const> = package.loaded["Kek's entity functions"]
local troll_entity <const> = package.loaded["Kek's trolling entities"]
local custom_upgrades <const> = package.loaded["Custom upgrades"]
local admin_mapper <const> = package.loaded["Admin mapper"]
local vehicle_saver <const> = package.loaded["Vehicle saver"]

do -- Extra functionality to api functions
	local originals <const> = essentials.const_all({
		create_thread = menu.create_thread,
		create_vehicle = vehicle.create_vehicle,
		create_ped = ped.create_ped,
		clone_ped = ped.clone_ped,
		create_object = object.create_object,
		create_world_object = object.create_world_object,
		request_control_of_entity = network.request_control_of_entity,
		menu_newindex = getmetatable(menu).__newindex,
		vehicle_newindex = getmetatable(vehicle).__newindex,
		ped_newindex = getmetatable(ped).__newindex,
		object_newindex = getmetatable(object).__newindex,
		network_newindex = getmetatable(network).__newindex
	})
	getmetatable(menu).__newindex = nil
	getmetatable(vehicle).__newindex = nil
	getmetatable(ped).__newindex = nil
	getmetatable(object).__newindex = nil
	getmetatable(network).__newindex = nil

	vehicle.create_vehicle = function(...)
		local model <const>,
		pos <const>,
		heading <const>,
		networked <const>,
		alwaysFalse <const>,
		weight <const> = ...
		if kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
			local Entity <const> = originals.create_vehicle(model, pos, heading, networked, alwaysFalse)
			kek_entity.entity_manager[Entity] = tonumber(weight) or 1
			return Entity
		end
		return 0
	end

	ped.create_ped = function(...)
		local type <const>,
		model <const>,
		pos <const>,
		heading <const>,
		isNetworked <const>,
		unk1 <const>,
		weight <const> = ...
		if kek_entity.entity_manager:update().is_ped_limit_not_breached then
			local Entity <const> = originals.create_ped(type, model, pos, heading, isNetworked, unk1)
			kek_entity.entity_manager[Entity] = tonumber(weight) or 1.5
			return Entity
		end
		return 0
	end

	ped.clone_ped = function(Ped)
		if kek_entity.entity_manager:update().is_ped_limit_not_breached then
			local clone <const> = originals.clone_ped(Ped)
			if entity.is_an_entity(clone) then
				kek_entity.entity_manager[clone] = 1.5
			end
			return clone
		else
			return 0
		end
	end

	object.create_object = function(...)
		local weight <const> = select(5, ...)
		if kek_entity.entity_manager:update().is_object_limit_not_breached then
			local Entity <const> = originals.create_object(...)
			kek_entity.entity_manager[Entity] = tonumber(weight) or 1
			return Entity
		end
		return 0
	end

	object.create_world_object = function(...)
		local weight <const> = select(5, ...)
		if kek_entity.entity_manager:update().is_object_limit_not_breached then
			local Entity <const> = originals.create_world_object(...)
			kek_entity.entity_manager[Entity] = tonumber(weight) or 1
			return Entity
		end
		return 0
	end

	network.request_control_of_entity = function(...)
		local Entity <const>, no_condition <const> = ...
		if no_condition or kek_entity.entity_manager:update()[kek_entity.entity_manager.entity_type_to_return_type[entity.get_entity_type(Entity)]] then
			return originals.request_control_of_entity(Entity)
		else
			return false
		end
	end

	local threads = {}
	menu.create_thread = function(...)
		local func <const>, value <const> = ...
		local temp <const> = {}
		for i = 1, #threads do
			if menu.has_thread_finished(threads[i]) then
				menu.delete_thread(threads[i])
			else
				temp[#temp + 1] = threads[i]
			end
		end
		threads = temp
		while #threads > 800 do
			menu.delete_thread(threads[1])
			table.remove(threads, 1)
		end
		local thread <const> = originals.create_thread(function(value)
			func(value)
		end, value)
		threads[#threads + 1] = thread
		return thread
	end
	getmetatable(menu).__newindex = originals.menu_newindex
	getmetatable(vehicle).__newindex = originals.vehicle_newindex
	getmetatable(ped).__newindex = originals.ped_newindex
	getmetatable(object).__newindex = originals.object_newindex
	getmetatable(network).__newindex = originals.network_newindex
end

for _, folder_name in pairs({
	"", 
	"kekMenuData", 
	"profiles", 
	"kekMenuLogs", 
	"kekMenuLibs", 
	"Player history", 
	"kekMenuLibs\\Languages",
	"Chat judger profiles",
	"Chatbot profiles"
}) do
	if not utils.dir_exists(paths.kek_menu_stuff..folder_name) then
		utils.make_dir(paths.kek_menu_stuff..folder_name)
	end
end

for _, file_name in pairs({
	"kekMenuData\\custom_chat_judge_data.txt", 
	"kekMenuLogs\\Blacklist.log", 
	"kekMenuData\\Kek's chat bot.txt", 
	"kekMenuData\\Spam text.txt", 
	"kekMenuLogs\\All players.log"
}) do
	if not utils.file_exists(paths.kek_menu_stuff..file_name) then
		essentials.create_empty_file(paths.kek_menu_stuff..file_name)
	end
end

for _, file_name in pairs({
	"kekMenuLibs\\data\\Truck.xml"
}) do
	if not utils.file_exists(paths.kek_menu_stuff..file_name) then
		essentials.msg("["..file_name.."]: "..lang["Missing necessarry file. Please reinstall. Read the README that comes with the script for more information. §"], 6, true)
		error(lang["Missing necessarry file. Please reinstall. Read the README that comes with the script for more information. §"])
	end
end

if not utils.dir_exists(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\Vehicle names") then
	essentials.msg(lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu. §"], 6, true, 6)
	error(lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu. §"])
else
	for _, file_name in pairs({
		"Chinese",
		"English",
		"French",
		"German",
		"Korean",
		"Spanish"
	}) do
		if not utils.file_exists(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\Vehicle names\\"..file_name..".lua") then
			essentials.msg(lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu. §"], 6, true, 6)
			error(lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu. §"])
		end
	end
end

if essentials.get_file_string("scripts\\kek_menu_stuff\\keksettings.ini", "*a"):match("Script quick access=(%a%a%a%a)") == "true" then
	u.kekMenu, u.kekMenuP = 0, 0
else
	u.kekMenu = menu.add_feature(lang["Kek's menu §"], "parent", 0).id
	u.kekMenuP = menu.add_player_feature(lang["Kek's menu §"], "parent", 0).id
end
u.session_trolling = menu.add_feature(lang["Session trolling §"], "parent", u.kekMenu)
u.session_malicious = menu.add_feature(lang["Session malicious §"], "parent", u.kekMenu)
u.weapon_blacklist = menu.add_feature(lang["Weapon blacklist §"], "parent", u.session_malicious.id)
u.kek_utilities = menu.add_feature(lang["Kek's utilities §"], "parent", u.kekMenu)
u.self_options = menu.add_feature(lang["Self options §"], "parent", u.kekMenu)
u.weapons_self = menu.add_feature(lang["Weapons §"], "parent", u.self_options.id)
u.player_history = menu.add_feature(lang["Player history §"], "parent", u.kekMenu)
u.chat_stuff = menu.add_feature(lang["Chat §"], "parent", u.kekMenu)
menu.add_feature(lang["Send clipboard to chat §"], "action", u.chat_stuff.id, function()
	essentials.send_message(utils.from_clipboard())
end)

u.chat_spammer = menu.add_feature(lang["Chat spamming §"], "parent", u.chat_stuff.id)
u.custom_chat_judger = menu.add_feature(lang["Custom chat judger §"], "parent", u.chat_stuff.id)
u.chat_bot = menu.add_feature(lang["Chat bot §"], "parent", u.chat_stuff.id)
u.chat_commands = menu.add_feature(lang["Chat commands §"], "parent", u.chat_stuff.id)
u.gvehicle = menu.add_feature(lang["Vehicle §"], "parent", u.kekMenu)
u.vehicleSettings = menu.add_feature(lang["Vehicle settings §"], "parent", u.gvehicle.id)
u.settingsUI = menu.add_feature(lang["General settings §"], "parent", u.kekMenu)
u.profiles = menu.add_feature(lang["Settings §"], "parent", u.settingsUI.id)
u.script_loader = menu.add_feature(lang["Script loader §"], "parent", u.settingsUI.id)
u.hotkey_settings = menu.add_feature(lang["Hotkey settings §"], "parent", u.settingsUI.id)
u.language_config = menu.add_feature(lang["Language configuration §"], "parent", u.settingsUI.id)
u.ai_drive = menu.add_feature(lang["Ai driving §"], "parent", u.gvehicle.id)
u.drive_style_cfg = menu.add_feature(lang["Drive style §"], "parent", u.gvehicle.id)
u.protections = menu.add_feature(lang["Protections §"], "parent", u.self_options.id)
u.modder_detection = menu.add_feature(lang["Modder detection §"], "parent", u.kekMenu)
u.flagsTolog = menu.add_feature(lang["Modder logging settings §"], "parent", u.modder_detection.id)
u.flagsToKick = menu.add_feature(lang["Auto kick tag settings §"], "parent", u.modder_detection.id)
u.modder_detection_settings = menu.add_feature(lang["Which modder detections are on §"], "parent", u.modder_detection.id)
u.vehicle_friendly = menu.add_feature(lang["Vehicle peaceful §"], "parent", u.gvehicle.id)
u.vehicle_blacklist = menu.add_feature(lang["Vehicle blacklist §"], "parent", u.gvehicle.id)
u.debug = menu.add_feature("Debugging", "parent", u.settingsUI.id)

u.malicious_player_features = menu.add_player_feature(lang["Malicious §"], "parent", u.kekMenuP).id
u.player_trolling_features = menu.add_player_feature(lang["Trolling §"], "parent", u.kekMenuP).id
u.script_stuff = menu.add_player_feature(lang["Scripts §"], "parent", u.kekMenuP).id
u.pWeapons = menu.add_player_feature(lang["Weapons §"], "parent", u.kekMenuP).id
u.player_misc_features = menu.add_player_feature(lang["Misc §"], "parent", u.kekMenuP).id
u.player_vehicle_features = menu.add_player_feature(lang["Vehicle §"], "parent", u.kekMenuP).id

local keks_custom_modder_flags = 
	{
		["Has-Suspicious-Stats"] = 0,
		["Blacklist"] = 0,
		["Modded-Name"] = 0,
		["Godmode"] = 0
	}
	
o.modder_flag_setting_properties = 
	{
		{
			"Log people with ", 
			"log: ", 
			u.flagsTolog,
			lang["Log: §"].." "
		}, 
		{
			"Kick people with ", 
			"kick: ", 
			u.flagsToKick,
			lang["Kick: §"].." "
		}
	}

local modIdStuff = {1}
do
	local i = 1
	repeat
		local int <const> = 2^i
		if int < player.get_modder_flag_ends() then
			modIdStuff[#modIdStuff + 1] = int
		end
		i = i + 1
	until int == player.get_modder_flag_ends() or i > 63
	for flag_name, _ in pairs(keks_custom_modder_flags) do
		local ends <const> = player.get_modder_flag_ends()
		local flag_int <const> = player.add_modder_flag(flag_name)
		if flag_int == ends then
    		modIdStuff[#modIdStuff + 1] = flag_int
    	end
    	keks_custom_modder_flags[flag_name] = flag_int
    end
end

for _, properties in pairs({
	{
		setting_name = "Force host", 
		setting = false
	}, 
	{
		setting_name = "Automatically check player stats", 
		setting = false
	}, 
	{
		setting_name = "Auto kicker", 
		setting = false
	}, 
	{
		setting_name = "Log modders", 
		setting = true
	}, 
	{
		setting_name = "Blacklist", 
		setting = false
	},
	{
		setting_name = "Spawn #vehicle# maxed", 
		setting = true, 
		feature_name = lang["Spawn vehicles maxed §"]
	}, 
	{
		setting_name = "Delete old #vehicle#", 
		setting = true, 
		feature_name = lang["Delete old vehicle §"]
	}, 
	{
		setting_name = "Custom chat judger", 
		setting = false
	}, 
	{
		setting_name = "Chat judge reaction", 
		setting = 2
	}, 
	{
		setting_name = "Default vehicle", 
		setting = "krieger"
	},
	{
		setting_name = "Default ped",
		setting = "u_m_m_jesus_01"
	},
	{
		setting_name = "Default object",
		setting = "prop_asteroid_01"
	},
	{
		setting_name = "Exclude friends from attacks #malicious#", 
		setting = true, 
		feature_name = lang["Exclude friends from attacks §"]
	},
	{
		setting_name = "Exclude yourself from trolling", 
		setting = true
	},
	{
		setting_name = "Spawn inside of spawned #vehicle#", 
		setting = true, 
		feature_name = lang["Spawn inside of spawned vehicle §"]
	}, 
	{
		setting_name = "Always f1 wheels on #vehicle#", 
		setting = false, 
		feature_name = lang["Always spawn with f1 wheels §"]
	},
	{
		setting_name = "Auto kicker #notifications#", 
		setting = true, 
		feature_name = lang["Auto kicker notifications §"], 
		feature_parent = u.modder_detection
	}, 
	{
		setting_name = "Chat judge #notifications#", 
		setting = true, 
		feature_name = lang["Notifications §"], 
		feature_parent = u.custom_chat_judger
	},
	{
		setting_name = "Hotkeys #notifications#", 
		setting = true, 
		feature_name = lang["Notifications §"], 
		feature_parent = u.hotkey_settings
	},
	{
		setting_name = "Vehicle blacklist #notifications#", 
		setting = true, 
		feature_name = lang["Notifications §"], 
		feature_parent = u.vehicle_blacklist
	},
	{
		setting_name = "Blacklist notifications #notifications#", 
		setting = true, 
		feature_name = lang["Blacklist §"].." "..lang["Notifications §"], 
		feature_parent = u.modder_detection
	},
	{
		setting_name = "Weapon blacklist notifications #notifications#", 
		setting = true, 
		feature_name = lang["Weapon blacklist §"].." "..lang["Notifications §"], 
		feature_parent = u.weapon_blacklist
	},
	{
		setting_name = "Always ask what #vehicle#", 
		setting = false, 
		feature_name = lang["Always ask what vehicle §"]
	}, 
	{
		setting_name = "Air #vehicle# spawn mid-air", 
		setting = true, 
		feature_name = lang["Spawn air vehicle mid-air §"]
	}, 
	{
		setting_name = "Plate vehicle text", 
		setting = "Kektram"
	}, 
	{
		setting_name = "Vehicle fly speed",
		setting = 150
	}, 
	{
		setting_name = "Spawn #vehicle# in godmode", 
		setting = false, 
		feature_name = lang["Spawn vehicles in godmode §"]
	}, 
	{
		setting_name = "Vehicle blacklist",
		setting = false
	},
	{
		setting_name = "Spam text",
		setting = "Kektram"
	},
	{
		setting_name = "Echo chat",
		setting = false
	},
	{
		setting_name = "Kick any vote kickers",
		setting = false
	},
	{
		setting_name = "chat bot",
		setting = false
	},
	{
		setting_name = "chat bot delay",
		setting = 300
	},
	{
		setting_name = "Spam speed",
		setting = 100
	},
	{
		setting_name = "Echo delay",
		setting = 100
	},
	{
		setting_name = "Player history",
		setting = true
	},
	{
		setting_name = "Modded name detection",
		setting = true
	},
	{
		setting_name = "Random weapon camos",
		setting = false
	},
	{
		setting_name = "Max number of people to kick in force host",
		setting = 31
	},
	{
		setting_name = "Vehicle clear distance",
		setting = 500
	},
	{
		setting_name = "Ped clear distance",
		setting = 500
	},
	{
		setting_name = "Object clear distance",
		setting = 500
	},
	{
		setting_name = "Pickup clear distance",
		setting = 500
	},
	{
		setting_name = "Sort player history search from newest to oldest",
		setting = true
	},
	{
		setting_name = "Drive style",
		setting = 557
	},
	{
		setting_name = "Cops clear distance",
		setting = 500
	},
	{
		setting_name = "Chat logger",
		setting = false
	},
	{
		setting_name = "Script quick access",
		setting = false
	},
	{
		setting_name = "Chat commands",
		setting = false
	},
	{
		setting_name = "Only friends can use chat commands",
		setting = false
	},
	{
		setting_name = "Send command info",
		setting = false
	},
	{
		setting_name = "Kick #chat command#", 
		setting = false, 
		feature_name = lang["Kick §"]
	},
	{
		setting_name = "Crash #chat command#", 
		setting = false, 
		feature_name = lang["Crash §"]
	},
	{
		setting_name = "apartmentinvite #chat command#", 
		setting = false, 
		feature_name = lang["Apartment invites §"], 
		extra_command_display = " <Number>"
	},
	{
		setting_name = "Cage #chat command#", 
		setting = false, 
		feature_name = lang["Cage player §"]
	},
	{
		setting_name = "Kill #chat command#", 
		setting = false, 
		feature_name = lang["Kill player §"], 
		extra_command_display = " <Player>"
	},
	{
		setting_name = "clowns #chat command#", 
		setting = false, 
		feature_name = lang["Clown vans §"]
	},
	{
		setting_name = "chopper #chat command#", 
		setting = false, 
		feature_name = lang["Send attack chopper §"]
	},
	{
		setting_name = "neverwanted #chat command#", 
		setting = true, 
		feature_name = lang["Never wanted §"]
	},
	{
		setting_name = "otr #chat command#", 
		setting = true, 
		feature_name = lang["off the radar §"]
	},
	{
		setting_name = "Spawn #chat command#", 
		setting = true, 
		feature_name = lang["Spawn vehicle §"], 
		extra_command_display = " <Vehicle>"
	},
	{
		setting_name = "weapon #chat command#", 
		setting = true, 
		feature_name = lang["Give weapon §"], 
		extra_command_display = " <Weapon name/All>"
	},
	{
		setting_name = "removeweapon #chat command#", 
		setting = false, 
		feature_name = lang["Remove weapon §"], 
		extra_command_display = " <Weapon name/All>"
	},
	{
		setting_name = "teleport #chat command#", 
		setting = false, 
		feature_name = lang["Teleport to §"], 
		extra_command_display = " <Player/Location>", 
		alternative_command_info = "or !tp "
	},
	{
		setting_name = "Godmode detection",
		setting = false
	},
	{
		setting_name = "Horn boost speed",
		setting = 25
	},
	{
		setting_name = "Horn boost",
		setting = false
	},
	{
		setting_name = "Hotkeys",
		setting = true
	},
	{
		setting_name = "Hotkey mode",
		setting = 0
	},
	{
		setting_name = "Bounty amount",
		setting = 10000
	},
	{
		setting_name = "Friends can't be targeted by chat commands",
		setting = true
	},
	{
		setting_name = "You can't be targeted",
		setting = true
	},
	{
		setting_name = "Auto tp to waypoint",
		setting = false
	},
	{
		setting_name = "Random weapon camos speed",
		setting = 500
	},
	{
		setting_name = "Chance to reply",
		setting = 100
	},
	{
		setting_name = "Aim protection",
		setting = false
	},
	{
		setting_name = "Aim protection mode",
		setting = 1
	},
	{
		setting_name = "Revenge",
		setting = false
	},
	{
		setting_name = "Revenge mode",
		setting = 1
	},
	{
		setting_name = "Anti stuck measures",
		setting = true
	},
	{
		setting_name = "Time OSD",
		setting = false
	},
	{
		setting_name = "Clever bot",
		setting = false
	},
	{
		setting_name = "Tp to player while spectating",
		setting = false
	},
	{
		setting_name = "Display 2take1 notifications",
		setting = false
	},
	{
		setting_name = "Number of notifications to display",
		setting = 15
	},
	{
		setting_name = "Display notify filter",
		setting = false
	},
	{
		setting_name = "Log 2take1 notifications to console",
		setting = false
	},
	{
		setting_name = "Help interval",
		setting = 14
	},
	{
		setting_name = "Weapon blacklist",
		setting = false
	},
	{
		setting_name = "Show red sphere clear entities",
		setting = true
	},
	{
		setting_name = "Force field sphere",
		setting = true
	},
	{
		setting_name = "Anti chat spam",
		setting = false
	},
	{
		setting_name = "Anti chat spam reaction", 
		setting = 0
	},
	{
		setting_name = "Debug mode",
		setting = false
	}
}) do
	settings.add_setting(properties)
end

for _, properties in pairs(settings.general) do
	if properties.setting_name:find("#notifications#", 1, true) then
		settings.toggle[properties.setting_name] = menu.add_feature(properties.feature_name, "toggle", properties.feature_parent.id, function(f)
			settings.in_use[properties.setting_name] = f.on
		end)
	end
end

for _, properties in pairs(settings.general) do
	if properties.setting_name:find("#malicious#", 1, true) then
		settings.toggle[properties.setting_name] = menu.add_feature(properties.feature_name, "toggle", u.session_malicious.id, function(f)
			settings.in_use[properties.setting_name] = f.on
		end)
	end
end

for _, properties in pairs(settings.general) do
	if properties.setting_name:find("#vehicle#", 1, true) then
		settings.toggle[properties.setting_name] = menu.add_feature(properties.feature_name, "toggle", u.vehicleSettings.id)
	end
end

local function get_all_modder_flags(...)
	local pid <const>, type <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	local number_of_flags = 0
	local all_flags = ""
	if player.is_player_valid(pid) then
		for _, k in pairs(modIdStuff) do
			if player.is_player_modder(pid, k) then
				if settings.in_use[type..player.get_modder_flag_text(k)] then
					number_of_flags = number_of_flags + 1
				end
				all_flags = all_flags..player.get_modder_flag_text(k)..", "
			end
		end
		if all_flags ~= "" then
			all_flags = all_flags:sub(1, -3)
		end
	end
	return number_of_flags, all_flags
end

-- Mod tag related settings
for _, setting_property in pairs(o.modder_flag_setting_properties) do
	menu.add_feature(lang["Turn all on or off §"], "action", setting_property[3].id, function()
		local bool = not essentials.is_any_true(table.move(setting_property[3].children, 2, #setting_property[3].children, 1, {}), function(f) 
			return f.on 
		end)
		for i = 1, #modIdStuff do
			settings.toggle[setting_property[1]..player.get_modder_flag_text(modIdStuff[i])].on = bool
			settings.in_use[setting_property[1]..player.get_modder_flag_text(modIdStuff[i])] = bool
		end
	end)

	for i = 1, #modIdStuff do
		settings.add_setting({
			setting_name = setting_property[1]..player.get_modder_flag_text(modIdStuff[i]), 
			setting = false
		})
		settings.toggle[setting_property[1]..player.get_modder_flag_text(modIdStuff[i])] = menu.add_feature(setting_property[4]..player.get_modder_flag_text(modIdStuff[i]), "toggle", setting_property[3].id, function(f) 
			settings.in_use[setting_property[1]..player.get_modder_flag_text(modIdStuff[i])] = f.on
		end)
	end
end

menu.add_feature(lang["Set §"].." ".."English".." "..lang["as default language. §"], "action", u.language_config.id, function(f)
	local file <close> = io.open(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini", "w+")
	file:write("English.txt")
	file:flush()
	essentials.msg("English".." "..lang["was set as the default language. §"], 210, true)
	essentials.msg("Reset lua state for language change to apply.", 6, true, 10)
end)
for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."kekMenuLibs\\Languages", "txt")) do
	menu.add_feature(lang["Set §"].." "..file_name:gsub("%.txt$", "").." "..lang["as default language. §"], "action", u.language_config.id, function(f)
		local file <close> = io.open(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini", "w+")
		file:write(file_name)
		file:flush()
		essentials.msg(file_name:gsub("%.txt$", "").." "..lang["was set as the default language. §"], 210, true)
		essentials.msg("Reset lua state for language change to apply.", 6, true, 10)
	end)
end

do
	local function update_script_loader_toggle_name()
		local str <const> = essentials.get_file_string("scripts\\autoexec.lua", "*a")
		if utils.file_exists(paths.home.."\\scripts\\autoexec.lua") and str:find("sjhvnciuyu44khdjkhUSx", 1, true) and str:find("if false then return end", 1, true) then
			u.toggle_script_loader.name = lang["Turn off script loader §"]
		else
			u.toggle_script_loader.name = lang["Turn on script loader §"]
		end
	end

	local function update_autoexec(...)
		local bypass_requirement <const> = ...
		if bypass_requirement or utils.file_exists(paths.home.."scripts\\autoexec.lua") then
			local str <const> = essentials.get_file_string("scripts\\autoexec.lua", "*a")
			if (bypass_requirement and not str:find("sjhvnciuyu44khdjkhUSx", 1, true)) or (str:find("sjhvnciuyu44khdjkhUSx", 1, true) and str:match("%-%- Version ([%d%.]+)\n") ~= __kek_menu_version) then
				local file <close> = io.open(paths.home.."scripts\\autoexec.lua", "w+")
				file:write("if false then return end")
				file:write("\n-- Version "..__kek_menu_version)
				file:write("\n-- sjhvnciuyu44khdjkhUSx\n")
				file:write("local appdata_path = utils.get_appdata_path(\"PopstarDevs\", \"2Take1Menu\")..\"\\\\\"\n")
				file:write("local scripts = {}\n")
				file:write("for _, script_name in pairs(scripts) do\n")
				file:write("	if utils.file_exists(appdata_path..\"scripts\\\\\"..script_name) then\n")
				file:write("		if not require(script_name:gsub(\"%.lua$\", \"\")) then\n")
				file:write("			menu.notify(\"Failed to load \"..script_name..\".\", \"\", 3, 6)\n")
				file:write("		end\n")
				file:write("	end\n")
				file:write("end\n")
				file:flush()
			end
		end
	end

	u.toggle_script_loader = menu.add_feature("", "action", u.script_loader.id, function(f)
		update_autoexec(true)
		local str <const> = essentials.get_file_string("scripts\\autoexec.lua", "*a")
		if str:find("^if false then return end") then
			essentials.replace_line_in_file_exact(
				"scripts\\autoexec.lua", 
				"if false then return end", 
				"if true then return end"
			)
			essentials.msg(lang["Turned off script loader §"], 212, true)
		elseif str:find("^if true then return end") then
			essentials.replace_line_in_file_exact(
				"scripts\\autoexec.lua", 
				"if true then return end", 
				"if false then return end"
			)
			essentials.msg(lang["Turned on script loader §"], 212, true)
		end
		update_script_loader_toggle_name()
	end)

	menu.add_feature(lang["Empty script loader file §"], "action", u.script_loader.id, function()
		local file <close> = io.open(paths.home.."scripts\\autoexec.lua", "w+")
		update_autoexec(true)
		update_script_loader_toggle_name()
		essentials.msg(lang["Emptied script loader §"], 212, true)
	end)

	menu.add_feature(lang["Add script to auto loader §"], "action", u.script_loader.id, function()
		if utils.file_exists(paths.home.."scripts\\autoexec.lua") then
			update_autoexec(true)
			local input, status <const> = keys_and_input.get_input(lang["Type in the name of the lua script to add. §"], "", 128, 0)
			if status == 2 then
				return
			end
			input = input:lower():gsub("%.lua$", "")
			local file_path <const>, file_name <const> = essentials.get_file("scripts\\", "lua", input)
			if file_path:match(essentials.remove_special(paths.home).."scripts\\(.+)") and not file_path:find("autoexec%.lua$") then 
				if not essentials.search_for_match_and_get_line("scripts\\autoexec.lua", {file_name}) then
					essentials.replace_line_in_file_exact(
						"scripts\\autoexec.lua", 
						"local scripts = {}", 
						"local scripts = {}\nscripts[#scripts + 1] = \""..file_name.."\""
					)
					essentials.msg(lang["Added §"].." "..file_path:match(essentials.remove_special(paths.home).."scripts\\(.+)").." "..lang["to script loader §"], 212, true)
				else
					essentials.msg(file_path:match(essentials.remove_special(paths.home).."scripts\\(.+)").." "..lang["is already in the script loader §"], 210, true)
				end
			else
				essentials.msg(lang["Couldn't find file §"], 6, true)
			end
			update_script_loader_toggle_name()
		else
			essentials.msg(lang["autoexec doesn't exist §"], 6, true)
		end
	end)

	menu.add_feature(lang["Remove script from auto loader §"], "action", u.script_loader.id, function()
		if utils.file_exists(paths.home.."scripts\\autoexec.lua") then
			update_autoexec(true)
			local input <const>, status <const> = keys_and_input.get_input(lang["Type in the lua script you want to remove. §"], "", 128, 0)
			if status == 2 then
				return
			end
			local file_path <const>, file_name = essentials.get_file("scripts\\", "lua", input:lower())
			if file_name == "" then
				for line in essentials.get_file_string("scripts\\autoexec.lua", "*a"):gmatch("([^\n]*)\n?") do
					if line:lower():find(input:lower(), 1, true) then
						file_name = line:match("scripts%[#scripts %+ 1%] = \"(.+)\"")
						break
					end
				end
			end
			if file_name and file_name ~= "" then
				if essentials.remove_line_from_file_exact("scripts\\autoexec.lua", "scripts[#scripts + 1] = \""..file_name.."\"") then
					essentials.msg(lang["Removed §"].." "..file_name:gsub("%.lua$", "").." "..lang["from script loader §"], 140, true)
				else
					essentials.msg(lang["Couldn't find file §"], 6, true)
				end
			end
			update_script_loader_toggle_name()
		else
			essentials.msg(lang["autoexec doesn't exist §"], 6, true)
		end
	end)
	update_autoexec()
	update_script_loader_toggle_name()
end

settings.toggle["Godmode detection"] = menu.add_feature(lang["Godmode detection §"], "toggle", u.modder_detection_settings.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if player.is_player_god(pid)
			and not player.is_player_modder(pid, -1)
			and not entity.is_entity_dead(player.get_player_ped(pid))
			and essentials.is_not_friend(pid)
			and (not f.data[player.get_player_scid(pid)] or utils.time_ms() > f.data[player.get_player_scid(pid)]) 
			and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0	
			and kek_entity.is_any_tasks_active(player.get_player_ped(pid), {
				enums.ctasks.AimGunVehicleDriveBy,
				enums.ctasks.Melee,
				enums.ctasks.Cover,
				enums.ctasks.AimAndThrowProjectile,
				enums.ctasks.ReloadGun,
				enums.ctasks.Weapon
			}) then
				f.data[player.get_player_scid(pid)] = utils.time_ms() + 10000
				menu.create_thread(function()
					local scid <const> = player.get_player_scid(pid)
					local time <const> = utils.time_ms() + 7500
					while time > utils.time_ms()
					and player.is_player_valid(pid)
					and not entity.is_entity_dead(player.get_player_ped(pid))
					and not player.is_player_modder(pid, -1)
					and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0
					and player.is_player_god(pid)
					do
						system.yield(0)
					end
					if utils.time_ms() >= time and scid == player.get_player_scid(pid) then
						essentials.msg(player.get_player_name(pid).." "..lang["is in godmode. §"], 6, true)
						player.set_player_as_modder(pid, keks_custom_modder_flags["Godmode"])
						f.data[player.get_player_scid(pid)] = utils.time_ms() + 120000
					end
				end, nil)
			end
		end
	end
end)
settings.toggle["Godmode detection"].data = {}

local function suspicious_stats(pid)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	if player.is_player_valid(pid)
	and globals.get_player_rank(pid) ~= 0 
	and not settings.toggle["Automatically check player stats"].data[player.get_player_scid(pid)] 
	and essentials.is_not_friend(pid) 
	and pid ~= player.player_id() 
	and (globals.get_player_money(pid) ~= globals.get_player_money(player.player_id()) 
		or globals.get_player_rank(pid) ~= globals.get_player_rank(player.player_id()) 
		or globals.get_player_kd(pid) ~= globals.get_player_kd(player.player_id())) then
		local severity = 0
		local what_flags_they_have_text = ""
		if globals.get_player_money(pid) > 120000000 or globals.get_player_money(pid) < -0.1 then
			severity = severity + 1
			what_flags_they_have_text = what_flags_they_have_text..lang["Has a lot of money. §"].."\n"
		end
		if globals.get_player_rank(pid) < 1 then
			what_flags_they_have_text = what_flags_they_have_text..lang["Has Negative lvl §"].."\n"
			severity = severity + 3
		end
		if globals.get_player_kd(pid) < -0.1 then
			what_flags_they_have_text = what_flags_they_have_text..lang["Has Negative k/d §"].."\n"
			severity = severity + 3
		end
		if globals.get_player_rank(pid) > 1200 then
			severity = severity + 1
			what_flags_they_have_text = what_flags_they_have_text..lang["Has a high rank. §"].."\n"
		end
		if globals.get_player_kd(pid) > 10 then
			severity = severity + 1
			what_flags_they_have_text = what_flags_they_have_text..lang["Has a high k/d. §"].."\n"
		end
		if player.get_player_armour(pid) > 50 then
			severity = severity + 3
			what_flags_they_have_text = what_flags_they_have_text..lang["Has modded armor. §"].."\n"
		end
		local Ped <const> = player.get_player_ped(pid)
		if weapon.has_ped_got_weapon(Ped, 911657153) -- Stun gun
		or weapon.has_ped_got_weapon(Ped, 1752584910) -- Illegal rpg
		or weapon.has_ped_got_weapon(Ped, 1834241177) -- Railgun
		or weapon.has_ped_got_weapon(Ped, 3126027122) -- Hazardous jerry can
		or weapon.has_ped_got_weapon(Ped, 101631238) -- Fire extinguisher
		or weapon.has_ped_got_weapon(Ped, 2694266206) then -- BZ gas
			severity = severity + 2
			what_flags_they_have_text = what_flags_they_have_text..lang["Has modded weapons. §"].."\n"
		end
		if severity >= 3 then
			player.set_player_as_modder(pid, keks_custom_modder_flags["Has-Suspicious-Stats"])
			settings.toggle["Automatically check player stats"].data[player.get_player_scid(pid)] = true
			essentials.msg(player.get_player_name(pid).." "..lang["has: §"].."\n"..what_flags_they_have_text, 6, true)
		end
	end
end

settings.toggle["Modded name detection"] = menu.add_feature(lang["Modded name detection §"], "toggle", u.modder_detection_settings.id, function(f)
	if f.on then
		essentials.listeners["player_join"]["modded_name_detection"] = event.add_event_listener("player_join", function(event)
			local player_name = player.get_player_name(event.player)
			if player.is_player_valid(event.player) 
			and player.player_id() ~= event.player
			and not player.is_player_modder(event.player, keks_custom_modder_flags["Modded-Name"]) 
			and essentials.is_not_friend(event.player) then
				if #player_name <= 5 
				or #player_name > 16 
				or player_name:gsub("[%.%-_]", ""):find("[%p%s%c]") then
					local count = 0
					for pid in essentials.players() do
						if player.get_player_name(pid) == player_name then
							count = count + 1
						end
						if count > 1 then
							return
						end
					end
					if count == 1 then
						essentials.msg(player_name.." "..lang["has a modded name. §"], 6, true)
						player.set_player_as_modder(event.player, keks_custom_modder_flags["Modded-Name"])
					end
				end 
			end
		end)
	else
		event.remove_event_listener("player_join", essentials.listeners["player_join"]["modded_name_detection"])
		essentials.listeners["player_join"]["modded_name_detection"] = nil
	end
end)

settings.toggle["Blacklist"] = menu.add_feature(lang["Blacklist §"], "toggle", u.modder_detection_settings.id, function(f)
	if f.on then
		essentials.listeners["player_join"]["blacklist"] = event.add_event_listener("player_join", function(event)
			if player.is_player_valid(event.player) and player.player_id() ~= event.player and essentials.is_not_friend(event.player) then
				local rid <const> = player.get_player_scid(event.player)
				local name = player.get_player_name(event.player)
				local ip <const> = player.get_player_ip(event.player)
				if #name < 1 then
					name = math.random(-2^61, 2^62)
				end
				local tags, what_was_detected = essentials.search_for_match_and_get_line("scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log", {"/"..rid.."/", "&"..ip.."&", "§"..name.."§"}, false, true)
				if tags and what_was_detected then
					if what_was_detected:find("/", 1, true) then
						what_was_detected = lang["Rid §"]..": "..what_was_detected:gsub("/", "")
					elseif what_was_detected:find("&", 1, true) then 
						what_was_detected = lang["IP §"]..": "..essentials.dec_to_ipv4(math.tointeger(what_was_detected:gsub("&", "")))
					elseif what_was_detected:find("§", 1, true) then
						what_was_detected = lang["Name §"]..": "..what_was_detected:gsub("§", "")
					end
					if settings.toggle["Auto kicker"].on and settings.in_use[o.modder_flag_setting_properties[2][1]..player.get_modder_flag_text(keks_custom_modder_flags["Blacklist"])] then
						globals.kick(event.player)
						system.yield(500)
					end
					tags = tags:match("<(.+)>") or ""
					essentials.msg(lang["Recognized §"].." "..name..lang["\\nDetected: §"].." "..what_was_detected..lang["\\nTags:\\n §"]..tags, 6, settings.in_use["Blacklist notifications #notifications#"], 6)
					if player.is_player_valid(event.player) then
						player.set_player_as_modder(event.player, keks_custom_modder_flags["Blacklist"])
					end
				end
			end
		end)
	else
		event.remove_event_listener("player_join", essentials.listeners["player_join"]["blacklist"])
		essentials.listeners["player_join"]["blacklist"] = nil
	end
end)

settings.toggle["Automatically check player stats"] = menu.add_feature(lang["Check people's stats automatically §"], "toggle", u.modder_detection_settings.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if f.on and not player.is_player_modder(pid, keks_custom_modder_flags["Has-Suspicious-Stats"]) then
				suspicious_stats(pid)
			end
		end
	end
end)
settings.toggle["Automatically check player stats"].data = {}

local function add_to_blacklist(...)
	if utils.file_exists(paths.home.."scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log") then
		local name,
		ip <const>,
		rid <const>,
		reason,
		text <const> = ...
		if not name or #name < 1 then
			name = "INVALID_NAME_758349843"
		end
		if not reason or #reason == 0 then
			reason = "Manually added"
		end
		local results <const> = essentials.log("scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log", "§"..name.."§ /"..rid.."/ &"..ip.."& <"..reason..">", {"/"..rid.."/", "&"..ip.."&", "§"..name.."§"})
		if results then
			essentials.replace_line_in_file_exact(
				"scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log", 
				results, 
				results:match("(.+)<").."<"..reason..">"
			)
			essentials.msg(lang["Changed the reason this person was added to the blacklist. §"], 212, text)
		else
			essentials.msg(lang["Added to blacklist. §"], 210, text)
			return true
		end
	else
		essentials.msg(lang["Blacklist file doesn't exist. §"], 6, text)
	end
end

local function remove_from_blacklist(...)
	if utils.file_exists(paths.home.."scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log") then
		local name,
		ip,
		rid,
		text <const> = ...
		ip = tostring(ip)
		rid = tostring(rid)
		if ip:find("%.") then
			ip = tostring(essentials.ipv4_to_dec(ip))
		end
		local result = essentials.remove_line_from_file_substring("scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log", "/"..rid.."/")
		result = result or essentials.remove_line_from_file_substring("scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log", "&"..ip.."&")
		result = result or essentials.remove_line_from_file_substring("scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log", "§"..name.."§")
		if result then
			essentials.msg(lang["Removed rid. §"], 210, text)
		else
			essentials.msg(lang["Couldn't find player. §"], 6, text)
		end
	else
		essentials.msg(lang["Blacklist file doesn't exist. §"], 6, text)
	end
end

menu.add_player_feature(lang["Blacklist §"], "action_value_str", u.player_misc_features, function(f, pid)
	if f.value == 0 then
		if pid == player.player_id() then
			essentials.msg(lang["You can't add yourself to the blacklist... §"], 212, true)
			return
		end
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in why you're adding this person. §"], "", 128, 0)
		if status == 2 then
			return
		end
		add_to_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid), input, true)
		player.set_player_as_modder(pid, keks_custom_modder_flags["Blacklist"])
	elseif f.value == 1 then
		remove_from_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid), true)
	end
end):set_str_data({
	lang["Add §"],
	lang["Remove §"]
})

settings.toggle["Kick any vote kickers"] = menu.add_feature(lang["Kick any vote kickers §"], "toggle", u.protections.id, function(f)
	if f.on then
		essentials.nethooks["vote_kick_protex"] = hook.register_net_event_hook(function(pid, me, event)
			if event == 64
			and pid ~= me
			and	(not f.data[player.get_player_scid(pid)] or utils.time_ms() > f.data[player.get_player_scid(pid)])
			and essentials.is_not_friend(pid) then
				essentials.msg(player.get_player_name(pid).." "..lang["sent vote kick. Kicking them... §"], 6, true)
				if network.network_is_host() then
					network.network_session_kick_player(pid)
				else
					script.trigger_script_event(globals.get_script_event_hash("Netbail kick"), pid, {pid, globals.generic_player_global(pid)})
					f.data[player.get_player_scid(pid)] = utils.time_ms() + 2500
				end
			end
		end)
	else
		hook.remove_net_event_hook(essentials.nethooks["vote_kick_protex"])
		essentials.nethooks["vote_kick_protex"] = nil
	end
end)
settings.toggle["Kick any vote kickers"].data = {}

settings.toggle["Revenge"] = menu.add_feature(lang["Revenge §"], "value_str", u.protections.id, function(f)
	while f.on do
		system.yield(0)
		if entity.is_entity_dead(player.get_player_ped(player.player_id())) then
			local pid
			for p in essentials.players() do
				if player.player_id() ~= p and entity.has_entity_been_damaged_by_entity(player.get_player_ped(player.player_id()), player.get_player_ped(p)) then
					pid = p
				end
			end
			if pid then
				if f.value == 0 then
					if essentials.is_in_vehicle(pid) then
						ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
						system.yield(300)
					end
					essentials.use_ptfx_function(fire.add_explosion, location_mapper.get_most_accurate_position(player.get_player_coords(pid)), 29, true, false, 0, player.get_player_ped(pid))
				elseif f.value == 1 then
					troll_entity.send_clown_van(pid)
				elseif f.value == 2 then
					globals.kick(pid)
				elseif f.value == 3 then
					globals.script_event_crash(pid)
				elseif f.value == 4 then
					local their_pid <const> = pid
					for pid in essentials.players() do
						if pid ~= their_pid then
							essentials.use_ptfx_function(fire.add_explosion, location_mapper.get_most_accurate_position(player.get_player_coords(pid)), 29, true, false, 0, player.get_player_ped(their_pid))
						end
					end					
				end
				while entity.is_entity_dead(player.get_player_ped(player.player_id())) do
					system.yield(0)
				end
			end
		end
	end
end)
settings.valuei["Revenge mode"] = settings.toggle["Revenge"]
settings.valuei["Revenge mode"]:set_str_data({
	lang["Kill §"],
	lang["Clowns §"],
	lang["Kick §"],
	lang["Crash §"],
	lang["Kill session §"]
})

settings.toggle["Aim protection"] = menu.add_feature(lang["Aim protection §"], "value_str", u.protections.id, function(f)
	local player_cooldowns <const> = {
		cage = {}
	}
	while f.on do
		for pid in essentials.players() do
			if player.get_entity_player_is_aiming_at(pid) == player.get_player_ped(player.player_id()) then
				if f.value == 0 or f.value == 1 then
					if essentials.is_in_vehicle(pid) then
						ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
						system.yield(300)
					end
					local blame = pid
					if f.value == 1 then
						blame = player.player_id()
					end
					essentials.use_ptfx_function(fire.add_explosion, location_mapper.get_most_accurate_position(player.get_player_coords(pid)), 1, true, false, 0, player.get_player_ped(blame))
				elseif f.value == 2 then
					local time <const> = utils.time_ms() + 500
					while time > utils.time_ms() do
						gameplay.shoot_single_bullet_between_coords(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 0.3), select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f1, v3())), 0, gameplay.get_hash_key("weapon_stungun"), player.get_player_ped(player.player_id()), true, false, 1000)
						system.yield(0)
					end
				elseif f.value == 3 then
					globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, math.random(1, 114), 1, 1, 1}, true)
				elseif f.value == 4 and (not player_cooldowns.cage[player.get_player_scid(pid)] or utils.time_ms() > player_cooldowns.cage[player.get_player_scid(pid)]) then
					kek_entity.create_cage(pid)
					player_cooldowns.cage[player.get_player_scid(pid)] = utils.time_ms() + 10000
				end
			end
		end
		system.yield(0)
	end
end)
settings.valuei["Aim protection mode"] = settings.toggle["Aim protection"]
settings.valuei["Aim protection mode"]:set_str_data({
	lang["Explode §"],
	lang["Explode with blame §"],
	lang["Taze §"],
	lang["Invite to apartment §"],
	lang["Cage §"]
})

settings.toggle["Log modders"] = menu.add_feature(lang["Log modders with selected tags to blacklist §"], "toggle", u.modder_detection.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if not f.data[player.get_player_scid(pid)]
			and player.is_player_modder(pid, -1)
			and not player.is_player_modder(pid, keks_custom_modder_flags["Blacklist"])  
			and essentials.is_not_friend(pid) then
				local number_of_flags <const>, modder_flags <const> = get_all_modder_flags(pid, o.modder_flag_setting_properties[1][1])
				if number_of_flags > 0 then
					local name = player.get_player_name(pid)
					local rid <const> = player.get_player_scid(pid)
					local ip <const> = player.get_player_ip(pid)
					if #name < 1 then
						name = math.random(-2^61, 2^62)
					end
					essentials.log("scripts\\kek_menu_stuff\\kekMenuLogs\\Blacklist.log", "§"..name.."§ /"..rid.."/ &"..ip.."& <"..modder_flags..">", {"/"..rid.."/", "&"..ip.."&", "§"..name.."§"}, false, true)
					f.data[player.get_player_scid(pid)] = true
				end
			end
		end
	end
end)
settings.toggle["Log modders"].data = {}

settings.toggle["Auto kicker"] = menu.add_feature(lang["Auto kicker §"], "toggle", u.modder_detection.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if (not f.data[player.get_player_scid(pid)] or utils.time_ms() > f.data[player.get_player_scid(pid)])
			and player.is_player_modder(pid, -1) 
			and essentials.is_not_friend(pid) then
				local number_of_flags , modder_flags = get_all_modder_flags(pid, o.modder_flag_setting_properties[2][1])
				if number_of_flags > 0 then
					if settings.toggle["Log modders"].on then
						system.yield(3500)
					end
					if not player.is_player_valid(pid) then
						break
					end
					number_of_flags, modder_flags = get_all_modder_flags(pid, o.modder_flag_setting_properties[2][1])
					if number_of_flags > 0 and f.on then
						essentials.msg(lang["Kicking §"].." "..player.get_player_name(pid)..lang[", flags:\\n §"]..modder_flags, 212, settings.in_use["Auto kicker #notifications#"])
						globals.kick(pid)
						f.data[player.get_player_scid(pid)] = utils.time_ms() + 20000
					end
				end
			end
		end
	end
end)
settings.toggle["Auto kicker"].data = {}

menu.add_feature(lang["Blacklist §"], "action_value_str", u.modder_detection.id, function(f)
	if f.value == 0 then
		local ip, reason, name = "", "", ""
		local scid <const>, status = keys_and_input.get_input(lang["Type in social club ID, also known as: rid / scid. §"], "", 16, 3)
		if status == 2 then
			return
		end
		while true do
			ip, status = keys_and_input.get_input(lang["Type in ip. §"], ip, 128, 0)
			if status == 2 then
				return
			end
			if ip:find("[/§&<>]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"/\", \"§\", \"&\", \"<\", \">\"", 6, true, 7)
			else
				break
			end
			system.yield(0)
		end
		if ip:find("%.") then
			ip = essentials.ipv4_to_dec(ip)
		end
		while true do
			reason, status = keys_and_input.get_input(lang["Type in why you're adding this person. §"], reason, 128, 0)
			if status == 2 then
				return
			end
			if reason:find("[/§&<>]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"/\", \"§\", \"&\", \"<\", \">\"", 6, true, 7)
			else
				break
			end
			system.yield(0)
		end
		while true do
			name, status = keys_and_input.get_input(lang["Type in their name. §"], name, 128, 0)
			if status == 2 then
				return
			end
			if name:find("[/§&<>]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"/\", \"§\", \"&\", \"<\", \">\"", 6, true, 7)
			else
				break
			end
			system.yield(0)
		end
		add_to_blacklist(name, ip, scid, reason, true)
		for pid in essentials.players() do
			if player.get_player_scid(pid) == scid then
				player.set_player_as_modder(pid, keks_custom_modder_flags["Blacklist"])
			end
		end
	elseif f.value == 1 then
		local scid <const>, status <const> = keys_and_input.get_input(lang["Type in social club ID, also known as: rid / scid. §"], "", 16, 3)
		if status == 2 then
			return
		end
		local ip <const>, status <const> = keys_and_input.get_input(lang["Type in ip. §"], "", 128, 0)
		if status == 2 then
			return
		end
		remove_from_blacklist("", ip, scid, true)
	elseif f.value == 2 then
		local reason <const>, status <const> = keys_and_input.get_input(lang["Type in the why you're adding everyone. §"], "", 128, 0)
		if status == 2 then
			return
		end
		local number_of_players_added = 0
		local number_of_players_modified = 0
		for pid in essentials.players() do
			if add_to_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid), reason) then
				number_of_players_added = number_of_players_added + 1
			else
				number_of_players_modified = number_of_players_modified + 1
			end
		end
	elseif f.value == 3 then
		for pid in essentials.players() do
			remove_from_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid))
		end
	end
end):set_str_data({
	lang["Add §"],
	lang["Remove §"],
	lang["Add session §"],
	lang["Remove session §"]
})

settings.toggle["Script quick access"] = menu.add_feature(lang["Script quick access §"], "toggle", u.settingsUI.id)

settings.toggle["Debug mode"] = menu.add_feature(lang["Debug mode §"], "toggle", u.debug.id, function(f)
	if f.on and keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
		essentials.msg(lang["Save settings and reset lua state to load in debug mode. §"], 6, true, 12)
		essentials.msg(lang["All scripts will run slower and might lag. More errors will occur, especially if you run other scripts. §"], 6, true, 12)
		essentials.msg(lang["Only use this mode if you intend to find bugs. §"], 6, true, 12)
	end
end)

local function vehicle_effect_standard(...)
	local remove_players <const>,
	effect <const>,
	wait <const> = ...
	local entities = vehicle.get_all_vehicles()
	if remove_players then
		entities = kek_entity.remove_player_entities(entities)
	end
	local Ped <const> = essentials.get_ped_closest_to_your_pov()
	table.sort(entities, function(a, b) return (essentials.get_distance_between(a, Ped) < essentials.get_distance_between(b, Ped)) end)
	for _, Vehicle in pairs(entities) do
		if not entity.is_entity_attached(Vehicle) and kek_entity.get_control_of_entity(Vehicle, 0) then
			effect(Vehicle, Ped, entities)
			if wait then 
				essentials.random_wait(wait)
			end
		end
	end
end		

settings.valuei["Horn boost speed"] = menu.add_feature(lang["Give nearby players horn boost §"], "slider", u.vehicle_friendly.id, function(f)
	while f.on do
		settings.in_use["Horn boost speed"] = f.value
		system.yield(0)
		for pid in essentials.players() do
			if not menu.get_player_feature(player_feat_ids["Player horn boost"]).feats[pid].on 
			and (not f.data[player.get_player_scid(pid)] or utils.time_ms() > f.data[player.get_player_scid(pid)]) 
			and player.is_player_pressing_horn(pid) 
			and kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
				vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), math.min(150, entity.get_entity_speed(player.get_player_vehicle(pid)) + f.value))
				f.data[player.get_player_scid(pid)] = utils.time_ms() + 550
			end
		end
	end
end)
settings.valuei["Horn boost speed"].data = {}
settings.valuei["Horn boost speed"].max = 100
settings.valuei["Horn boost speed"].min = 5
settings.valuei["Horn boost speed"].mod = 5
settings.toggle["Horn boost"] = settings.valuei["Horn boost speed"]

menu.add_feature(lang["Max nearby cars §"], "toggle", u.vehicle_friendly.id, function(f)
	while f.on do
		system.yield(0)
		vehicle_effect_standard(true, function(car) 
			kek_entity.max_car(car) 
		end, 1)
	end
end)

menu.add_feature(lang["Repair nearby cars §"], "toggle", u.vehicle_friendly.id, function(f)
	while f.on do
		system.yield(0)
		vehicle_effect_standard(true, function(car)
			if vehicle.is_vehicle_damaged(car) then
				kek_entity.repair_car(car)
			end
		end, 1)
	end			
end)

menu.add_feature(lang["Give nearby cars godmode §"], "toggle", u.vehicle_friendly.id, function(f)
	while f.on do
		system.yield(0)
		vehicle_effect_standard(true, function(car) kek_entity.modify_entity_godmode(car, true) end, 1)
	end
	vehicle_effect_standard(true, function(car) kek_entity.modify_entity_godmode(car, false) end)
end)

menu.add_feature(lang["Nearby cars have no collision §"], "toggle", u.vehicle_friendly.id, function(f)
	while f.on do 
		system.yield(0)
		vehicle_effect_standard(true, function(car)
			entity.set_entity_no_collsion_entity(car, essentials.get_most_relevant_entity(player.get_player_from_ped(essentials.get_ped_closest_to_your_pov())), false)
		end, 10)
	end
	vehicle_effect_standard(true, function(car)
		entity.set_entity_no_collsion_entity(car, essentials.get_most_relevant_entity(player.get_player_from_ped(essentials.get_ped_closest_to_your_pov())), true)
	end)
end)

u.modify_nearby_car_top_speed = menu.add_feature(lang["Drive force multiplier §"], "value_f", u.vehicle_friendly.id, function(f)
	while f.on do 
		system.yield(0)
		vehicle_effect_standard(true, function(car)
			entity.set_entity_max_speed(car, 45000)
			vehicle.modify_vehicle_top_speed(car, (f.value - 1) * 100)
		end, 1)
	end
end)
u.modify_nearby_car_top_speed.max = 20.0
u.modify_nearby_car_top_speed.min = -4.0
u.modify_nearby_car_top_speed.mod = 0.1
u.modify_nearby_car_top_speed.value = 1.0

menu.add_feature(lang["Nearby cars have zero gravity §"], "toggle", u.vehicle_friendly.id, function(f)
	while f.on do 
		system.yield(0)
		vehicle_effect_standard(true, function(car)
			if player.get_player_vehicle(player.player_id()) ~= car then
				entity.set_entity_gravity(car, false)
			end
		end, 1)
	end
	vehicle_effect_standard(true, function(car)
		if player.get_player_vehicle(player.player_id()) ~= car then
			entity.set_entity_gravity(car, true)
		end
	end)
end)

menu.add_feature(lang["Swap nearby cars §"], "toggle", u.vehicle_friendly.id, function(f)
	local num_of_vehicles_tracker <const>, peds <const> = {}, {}
	menu.create_thread(function()
		while f.on do
			system.yield(0)
			for i, Vehicle in pairs(num_of_vehicles_tracker) do
				if essentials.get_distance_between(essentials.get_ped_closest_to_your_pov(), Vehicle) > 250 then
					kek_entity.clear_entities({Vehicle})
					num_of_vehicles_tracker[i] = nil
				end
			end
			for i, Ped in pairs(peds) do
				if not ped.is_ped_in_any_vehicle(Ped) then
					kek_entity.clear_entities({Ped})
					peds[i] = nil
				end
			end
		end
	end, nil)
	while f.on do
		system.yield(0)
		local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["Default vehicle"])
		if streaming.is_model_a_vehicle(hash) then
			local vehicles <const> = kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(
				{
					vehicles = {
						entities 			   = vehicle.get_all_vehicles(),
						max_number_of_entities = nil,
						remove_player_entities = true,
						max_range 			   = 240,
						sort_by_closest        = false
					}
				},
				essentials.get_ped_closest_to_your_pov()
			)
			for _, Vehicle in pairs(essentials.deep_copy(vehicles)) do
				if not f.on then
					break
				end
				if entity.is_an_entity(Vehicle) 
				and not entity.is_entity_attached(Vehicle) 
				and not ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver)) 
				and not vehicle.is_vehicle_model(Vehicle, hash) 
				and kek_entity.get_control_of_entity(Vehicle, 0) then
					local passengers <const>, is_there_player <const> = kek_entity.get_number_of_passengers(Vehicle)
					if not is_there_player and #passengers > 0 then
						local velocity = v3()
						local car <const> = kek_entity.spawn_entity(hash, function()
							local pos <const>, dir <const> = entity.get_entity_coords(Vehicle), entity.get_entity_heading(Vehicle)
							velocity = entity.get_entity_velocity(Vehicle)
							kek_entity.clear_entities({Vehicle})
							return pos, dir
						end, entity.get_entity_god_mode(Vehicle), true)
						if entity.is_an_entity(car) then
							num_of_vehicles_tracker[car] = car
							entity.set_entity_velocity(car, velocity)
							local Ped <const> = kek_entity.spawn_entity(ped_mapper.get_random_ped("all peds except animals"), function() 
								return entity.get_entity_coords(car), 0
							end, false, false, enums.ped_types.civmale)
							if entity.is_an_entity(Ped) then
								peds[Ped] = Ped
								ped.set_ped_into_vehicle(Ped, car, enums.vehicle_seats.driver)
								ai.task_vehicle_drive_wander(Ped, car, 150, settings.in_use["Drive style"])
							end
						end
					end
				end
			end
		end
	end
end)

menu.add_feature(lang["Vehicle fly nearby vehicles §"], "toggle", u.vehicle_friendly.id, function(f)
	while f.on do
		system.yield(0)
		local control_indexes <const> = essentials.const({
			enums.inputs["W LEFT STICK"],
			enums.inputs["S LEFT STICK"],
			forward_button = enums.inputs["W LEFT STICK"],
			backward_button = enums.inputs["S LEFT STICK"]

		})
		local cars <const> = essentials.const_all(kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(
			{
				vehicles = {
					entities 			   = vehicle.get_all_vehicles(),
					max_number_of_entities = 35,
					remove_player_entities = true,
					max_range			   = nil,
					sort_by_closest 	   = true
				}
			},
			essentials.get_ped_closest_to_your_pov()
		))
		for i = 1, 2 do
			while f.on and controls.is_disabled_control_pressed(0, control_indexes[i]) do
				system.yield(0)
				local speed <const> = essentials.const({
					settings.valuei["Vehicle fly speed"].value, 
					-settings.valuei["Vehicle fly speed"].value
				})
				for i2 = 1, #cars do
					if kek_entity.get_control_of_entity(cars[i2], 25) then
						entity.set_entity_rotation(cars[i2], cam.get_gameplay_cam_rot())
						entity.set_entity_max_speed(cars[i2], 45000)
						vehicle.set_vehicle_forward_speed(cars[i2], speed[i])
					end
				end
			end
		end
		while f.on and not controls.is_disabled_control_pressed(0, control_indexes.forward_button) and not controls.is_disabled_control_pressed(0, control_indexes.backward_button) do
			system.yield(0)
			for i = 1, #cars do
				if kek_entity.get_control_of_entity(cars[i], 25) then
					entity.set_entity_velocity(cars[i], v3())
					entity.set_entity_rotation(cars[i], cam.get_gameplay_cam_rot())
				end
			end
		end
	end
end)

menu.add_feature(lang["Ram everyone §"], "toggle", u.session_trolling.id, function(f)
	local hash, vehicle_name
	while f.on do
		if vehicle_name ~= settings.in_use["Default vehicle"] then
			hash = vehicle_mapper.get_hash_from_user_input(settings.in_use["Default vehicle"])
			vehicle_name = settings.in_use["Default vehicle"]
		end
		if streaming.is_model_a_vehicle(hash) then
			local entities <const> = {}
			for pid in essentials.players() do
				if f.on
				and essentials.is_not_friend(pid) 
				and not player.is_player_god(pid)
				and not entity.is_entity_dead(player.get_player_ped(pid)) then
					entities[#entities + 1] = essentials.use_ptfx_function(kek_entity.spawn_and_push_a_vehicle_in_direction, pid, false, 8, hash)
				end
				if #entities > 0 then
					entity.set_entity_as_no_longer_needed(entities[#entities])
				end
				if not f.on then
					break
				end
			end
			system.yield(350)
			kek_entity.clear_entities(entities)
		else
			system.yield(0)
		end
	end
end)

menu.add_feature(lang["Disable vehicles §"], "toggle", u.session_malicious.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if (player.get_player_vehicle(player.player_id()) == 0 or player.get_player_vehicle(pid) ~= player.get_player_vehicle(player.player_id())) then
				globals.disable_vehicle(pid, true)
			end
		end
		system.yield(250)
	end
end)

local function disable_weapons(...)
	local f <const>, pid <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	if kek_entity.is_any_tasks_active(player.get_player_ped(pid), {
		enums.ctasks.AimGunOnFoot,
		enums.ctasks.Weapon,
		enums.ctasks.PlayerWeapon,
		enums.ctasks.SwapWeapon,
		enums.ctasks.Gun,
		enums.ctasks.Melee,
		enums.ctasks.MoveMeleeMovement,
		enums.ctasks.MeleeActionResult,
		enums.ctasks.MeleeUpperbodyAnims,
		enums.ctasks.ComplexEvasiveStep,
		enums.ctasks.MountThrowProjectile,
		enums.ctasks.AimGunVehicleDriveBy,
		enums.ctasks.AimAndThrowProjectile,
		enums.ctasks.ThrowProjectile,
		enums.ctasks.AimFromGround,
		enums.ctasks.AimGunScripted,
		enums.ctasks.ReloadGun,
		enums.ctasks.VehicleGun, 
		enums.ctasks.Bomb
	}) then
		if f.value == 0 then
			ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
		elseif f.value == 1 then
			local time <const> = utils.time_ms() + 500
			while time > utils.time_ms() do
				gameplay.shoot_single_bullet_between_coords(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 0.3), select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f1, v3())), 0, gameplay.get_hash_key("weapon_stungun"), player.get_player_ped(player.player_id()), true, false, 1000)
				system.yield(0)
			end
		elseif f.value == 2 then
			ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			essentials.use_ptfx_function(fire.add_explosion, player.get_player_coords(pid), 29, true, false, 0, player.get_player_ped(pid))
		elseif f.value == 3 then
			ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			essentials.use_ptfx_function(fire.add_explosion, player.get_player_coords(pid), 29, true, false, 0, player.get_player_ped(player.player_id()))
		end
	end
end

menu.add_feature(lang["Disable weapons §"], "value_str", u.session_malicious.id, function(f, pid)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) then
				disable_weapons(f, pid)
			end
		end
	end
end):set_str_data({
	lang["Clear tasks §"],
	lang["Taze §"],
	lang["Explode §"],
	lang["Explode with blame §"]
})

do
	local weapon_blacklist_settings <const> = {}
	if not utils.file_exists(paths.kek_menu_stuff.."kekMenuData\\weapon_blacklist_settings.ini") then
		essentials.create_empty_file(paths.kek_menu_stuff.."kekMenuData\\weapon_blacklist_settings.ini")
	end
	do
		local str <const> = essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\weapon_blacklist_settings.ini", "*a")
		local file <close> = io.open(paths.kek_menu_stuff.."kekMenuData\\weapon_blacklist_settings.ini", "a")
		for _, hash in pairs(weapon.get_all_weapon_hashes()) do
			if not str:find(hash, 1, true) then
				file:write(hash.."=".."false".."\n")
			end
		end
		file:flush()
	end
	for weapon in essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\weapon_blacklist_settings.ini", "*a"):gmatch("([^\n]*)\n?") do
		weapon_blacklist_settings[tonumber(weapon:match("(%d+)="))] = {setting = weapon:match("=(.+)") == "true"}
	end

	settings.toggle["Weapon blacklist"] = menu.add_feature(lang["Weapon blacklist §"], "toggle", u.weapon_blacklist.id, function(f)
		while f.on do
			system.yield(0)
			for _, hash in pairs(weapon.get_all_weapon_hashes()) do
				if weapon_blacklist_settings[hash].feat.on then
					for pid in essentials.players() do
						if weapon.has_ped_got_weapon(player.get_player_ped(pid), hash)
						and ((f.data[player.get_player_scid(pid)] or {})[hash] or 0) < utils.time_ms() 
						and essentials.is_not_friend(pid) then
							weapon.remove_weapon_from_ped(player.get_player_ped(pid), hash)
							essentials.msg(lang["Removed §"].." "..player.get_player_name(pid).."\'s "..weapon.get_weapon_name(hash)..".", 6, settings.in_use["Weapon blacklist notifications #notifications#"])
							if not f.data[player.get_player_scid(pid)] then
								f.data[player.get_player_scid(pid)] = {}
							end
							f.data[player.get_player_scid(pid)][hash] = utils.time_ms() + 60000
						end
					end
				end
			end
		end
	end)
	settings.toggle["Weapon blacklist"].data = {}

	for i, weapon_group_name in pairs({
		lang["Rifles §"],
		lang["SMGs §"],
		lang["Shotguns §"],
		lang["Pistols §"],
		lang["Explosives §"],
		lang["Throwables §"],
		lang["Heavy §"],
		lang["Melee §"],
		lang["Miscellaneous §"]
	}) do
		local parent <const> = menu.add_feature(weapon_group_name, "parent", u.weapon_blacklist.id)
		for _, hash in pairs(weapon_mapper.get_table_of_weapons({
			rifles = 1 == i,
			smgs = 2 == i,
			shotguns = 3 == i,
			pistols = 4 == i,
			explosives_heavy = 5 == i,
			throwables = 6 == i,
			heavy = 7 == i,
			melee = 8 == i,
			misc = 9 == i
		})) do
			if not weapon_blacklist_settings[hash].feat then
				weapon_blacklist_settings[hash].feat = menu.add_feature(weapon.get_weapon_name(hash), "toggle", parent.id, function(f)
					if utils.time_ms() > f.data then
						essentials.replace_line_in_file_exact(
							"scripts\\kek_menu_stuff\\kekMenuData\\weapon_blacklist_settings.ini",
							hash.."="..tostring(weapon_blacklist_settings[hash].setting), 
							hash.."="..tostring(weapon_blacklist_settings[hash].feat.on)
						)
						weapon_blacklist_settings[hash].setting = weapon_blacklist_settings[hash].feat.on
					end
				end)
				weapon_blacklist_settings[hash].feat.data = utils.time_ms() + 1000
				weapon_blacklist_settings[hash].feat.on = weapon_blacklist_settings[hash].setting
			end
		end
		if i == 9 then
			for _, hash in pairs(weapon.get_all_weapon_hashes()) do
				if not weapon_blacklist_settings[hash].feat then
					weapon_blacklist_settings[hash].feat = menu.add_feature(weapon.get_weapon_name(hash), "toggle", parent.id, function(f)
						if utils.time_ms() > f.data then
							essentials.replace_line_in_file_exact(
								"scripts\\kek_menu_stuff\\kekMenuData\\weapon_blacklist_settings.ini", 
								hash.."="..tostring(weapon_blacklist_settings[hash].setting), 
								hash.."="..tostring(weapon_blacklist_settings[hash].feat.on)
							)
							weapon_blacklist_settings[hash].setting = weapon_blacklist_settings[hash].feat.on
						end
					end)
					weapon_blacklist_settings[hash].feat.data = utils.time_ms() + 1000
					weapon_blacklist_settings[hash].feat.on = weapon_blacklist_settings[hash].setting
				end
			end
		end
	end
end

local player_history <const> = {
	year_parents = {},
	month_parents = {},
	day_parents = {},
	hour_parents = {},
	searched_players = {},
	players_added_to_history = {},
	count = 0
}

function player_history.sort_numbers(t)
	table.sort(t, function(a, b) return (tonumber(a:match("[%d]+")) or 0) > (tonumber(b:match("[%d]+")) or 0) end)
	return t
end

function player_history.add_features(parent, rid, ip, name)
	if parent.child_count == 0 then
		menu.add_feature(lang["Copy to clipboard §"], "action_value_str", parent.id, function(f, pid)
			if f.value == 0 then
				utils.to_clipboard(rid)
			elseif f.value == 1 then
				utils.to_clipboard(ip)
			elseif f.value == 2 then
				utils.to_clipboard(name)
			end
		end):set_str_data({
			lang["rid §"],
			lang["ip §"],
			lang["name §"]
		})

		menu.add_feature(lang["Blacklist §"], "action_value_str", parent.id, function(f)
			if f.value == 0 then
				local input <const>, status <const> = keys_and_input.get_input(lang["Type in why you're adding this person. §"], "", 128, 0)
				if status == 2 then
					return
				end
				add_to_blacklist(name, essentials.ipv4_to_dec(ip), rid, input, true)
				for pid in essentials.players() do
					if rid == player.get_player_scid(pid) then
						player.set_player_as_modder(pid, keks_custom_modder_flags["Blacklist"])
						break
					end
				end
			elseif f.value == 1 then
				remove_from_blacklist(name, essentials.ipv4_to_dec(ip), rid, true)
			end
		end):set_str_data({
			lang["Add §"],
			lang["Remove §"]
		})

		local seen <const> = {}
		for info in essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuLogs\\All players.log", "*a"):gmatch("([^\n]*)\n?") do
			if info:find("&"..rid.."&", 1, true) then
				seen[#seen + 1] = (info:match("<(.+)>") or "").." "..(info:match("!(.+)!") or "")
			end
		end
		menu.add_feature(lang["First seen §"]..": "..tostring(seen[1]), "action", parent.id)
		if #seen > 1 then
			menu.add_feature(lang["Last seen §"]..": "..tostring(seen[#seen]), "action", parent.id)
			menu.add_feature(lang["Seen §"].." "..#seen.." "..lang["times. §"], "action", parent.id)
		else
			menu.add_feature(lang["Seen §"].." 1 "..lang["time. §"], "action", parent.id)
		end
	end
end

menu.add_feature(lang["Player history §"], "action_value_str", u.player_history.id, function(f)
	if f.value == 0 then
		local input, status <const> = keys_and_input.get_input(lang["Type in what player you wanna search for. rid / name / ip §"], "", 128, 0)
		if status == 2 then
			return
		end
		input = input:lower()
		local str = essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuLogs\\All players.log", "*a")
		if settings.toggle["Sort player history search from newest to oldest"].on then
			str = str:reverse()
			input = input:reverse()
		end
		for line in str:gmatch("([^\n]*)\n?") do
			if line:lower():find(input, 1, true) then
				if settings.toggle["Sort player history search from newest to oldest"].on then
					line = line:reverse()
				end
				local name <const> = line:match("|(.-)|") or "" 
				local rid <const> = line:match(" &(.-)&") or ""
				local ip <const> = line:match("%^(.-)%^") or ""
				local time <const> = line:match("!(.-)!") or ""
				player_history.searched_players[#player_history.searched_players + 1] = menu.add_feature(name.." ["..time.."]", "parent", u.player_history.id, function(f)
					player_history.add_features(f, rid, ip, name)	
				end)
				return
			end
		end
		essentials.msg(lang["Couldn't find player. §"], 6, true)
	elseif f.value == 1 then
		for _, parent in pairs(player_history.searched_players) do
			for _, child in pairs(parent.children) do
				essentials.delete_feature(child.id)
			end
			essentials.delete_feature(parent.id)
		end
		player_history.searched_players = {}
	end
end):set_str_data({
	lang["Search §"],
	lang["Clear search list §"]	
})

for _, year in pairs(player_history.sort_numbers(utils.get_all_sub_directories_in_directory(paths.kek_menu_stuff.."Player history"))) do
	player_history.year_parents[year] = menu.add_feature(year, "parent", u.player_history.id)
	for _, month in pairs(player_history.sort_numbers(utils.get_all_sub_directories_in_directory(paths.kek_menu_stuff.."Player history\\"..year))) do
		if player_history.count == 2 then
			break
		end
		player_history.month_parents[year..month] = menu.add_feature(string.gsub(month:gsub("_", " "), "%d", ""), "parent", player_history.year_parents[year].id)
		for _, day in pairs(player_history.sort_numbers(utils.get_all_sub_directories_in_directory(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month))) do
			if player_history.count == 2 then
				break
			end
			player_history.day_parents[year..month..day] = menu.add_feature(day, "parent", player_history.month_parents[year..month].id)
			player_history.count = player_history.count + 1
			for _, current_file in pairs(player_history.sort_numbers(utils.get_all_files_in_directory(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month.."\\"..day, "log"))) do
				player_history.hour_parents[year..month..day..current_file:gsub("%.log$", "")] = menu.add_feature(current_file:gsub("%.log$", ""), "parent", player_history.day_parents[year..month..day].id)
				for player_info in essentials.get_file_string("scripts\\kek_menu_stuff\\Player history\\"..year.."\\"..month.."\\"..day.."\\"..current_file, "*a"):gmatch("([^\n]*)\n?") do
					local name <const> = player_info:match("|(.+)|") or "" 
					local rid <const> = player_info:match(" &(.+)&") or ""
					local ip <const> = player_info:match("%^(.+)%^") or ""
					local time <const> = player_info:match("!(.+)!") or ""
					menu.add_feature(name.." ["..time.."]", "parent", player_history.hour_parents[year..month..day..current_file:gsub("%.log$", "")].id, function(f)
						player_history.add_features(f, rid, ip, name)	
					end)
					player_history.players_added_to_history[rid] = true
				end
			end
		end
	end
end

settings.toggle["Player history"] = menu.add_feature(lang["Player history §"], "toggle", u.player_history.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if not player_history.players_added_to_history[player.get_player_scid(pid)] and f.on then
				local day_num = os.date("%d")
				if day_num == "1" then
					day_num = "1st"
				elseif day_num == "2" then
					day_num = "2nd"
				elseif day_num == "3" then
					day_num = "3rd"
				else
					day_num = day_num.."th"
				end
				local month <const> = os.date("%B").."_".. os.date("%m")
				local day <const> = os.date("%A").." "..day_num.." of "..month:match("(.+)_")
				local year <const> = os.date("%Y")
				local time <const> = os.date("%H").." o'clock"
				local date <const> = os.date("%x")
				if not utils.dir_exists(paths.kek_menu_stuff.."Player history\\"..year) then
					utils.make_dir(paths.kek_menu_stuff.."Player history\\"..year)
				end
				if not player_history.year_parents[year] then
					player_history.year_parents[year] = menu.add_feature(year, "parent", u.player_history.id)
				end
				if not utils.dir_exists(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month) then
					utils.make_dir(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month)
				end
				if not player_history.month_parents[year..month] then
					player_history.month_parents[year..month] = menu.add_feature(string.gsub(month:gsub("_", " "), "%d", ""), "parent", player_history.year_parents[year].id)
				end

				if not utils.dir_exists(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month.."\\"..day) then
					utils.make_dir(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month.."\\"..day)
				end
				if not player_history.day_parents[year..month..day] then
					player_history.day_parents[year..month..day] = menu.add_feature(day, "parent", player_history.month_parents[year..month].id)
				end

				if not utils.file_exists(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month.."\\"..day.."\\"..time..".log") then
					essentials.create_empty_file(paths.kek_menu_stuff.."Player history\\"..year.."\\"..month.."\\"..day.."\\"..time..".log")
				end
				if not player_history.hour_parents[year..month..day..time] then
					player_history.hour_parents[year..month..day..time] = menu.add_feature(time, "parent", player_history.day_parents[year..month..day].id)
				end
				local name <const>, rid <const>, ip <const> = player.get_player_name(pid), player.get_player_scid(pid), essentials.dec_to_ipv4(player.get_player_ip(pid))
				local player_info <const> = name.." ["..os.date("%X").."]"
				local info_to_log <const> = "|"..name.."| &"..rid.."& ^"..ip.."^".." !"..os.date("%X").."!".." <"..date..">"
				local path <const> = "scripts\\kek_menu_stuff\\Player history\\"..year.."\\"..month.."\\"..day
				for _, hour in pairs(player_history.sort_numbers(utils.get_all_files_in_directory(paths.home..path, "log"))) do
					if essentials.search_for_match_and_get_line(path.."\\"..hour, {"&"..rid.."&"}, false, true) then
						player_history.players_added_to_history[rid] = true
						break
					end
				end
				if not player_history.players_added_to_history[rid] then
					essentials.log(select(1, (paths.kek_menu_stuff.."Player history\\"..year.."\\"..month.."\\"..day.."\\"..time..".log"):gsub(essentials.remove_special(paths.home), "")), info_to_log)
					menu.add_feature(player_info, "parent", player_history.hour_parents[year..month..day..time].id, function(f)
						if f.child_count == 0 then
							player_history.add_features(f, rid, ip, name)
						end
					end)
					essentials.log("scripts\\kek_menu_stuff\\kekMenuLogs\\All players.log", info_to_log)
					player_history.players_added_to_history[rid] = true
				end
			end
			system.yield(0)
		end
	end
end)

settings.toggle["Sort player history search from newest to oldest"] = menu.add_feature(lang["Sort search from newest §"], "toggle", u.player_history.id)

menu.add_player_feature(lang["Disable weapons §"], "value_str", u.malicious_player_features, function(f, pid)
	while f.on do
		system.yield(0)
		disable_weapons(f, pid)
	end
end):set_str_data({
	lang["Clear tasks §"],
	lang["Taze §"],
	lang["Explode §"],
	lang["Explode with blame §"]
})

menu.add_player_feature(lang["Disable vehicles §"], "toggle", u.malicious_player_features, function(f, pid)
	while f.on do
		globals.disable_vehicle(pid)
		system.yield(2000)
	end
end)

menu.add_player_feature(lang["Script event crash §"], "action", u.malicious_player_features, function(f, pid)
	globals.script_event_crash(pid) 
end)

menu.add_player_feature(lang["Crash §"], "action", u.malicious_player_features, function(f, pid)
	local Entity <const> = menyoo.spawn_custom_vehicle(paths.kek_menu_stuff.."kekMenuLibs\\data\\Truck.xml", player.player_id())
	entity.freeze_entity(Entity, true)
	local time <const> = utils.time_ms() + 3500
	while time > utils.time_ms() and entity.is_an_entity(Entity) and player.is_player_valid(pid) do
		kek_entity.teleport(Entity, location_mapper.get_most_accurate_position(player.get_player_coords(pid)) + v3(0, 0, 5))
		system.yield(0)
	end
	kek_entity.teleport(Entity, v3(math.random(20000, 24000), math.random(20000, 24000), math.random(-2400, 2400)))
	kek_entity.hard_remove_entity_and_its_attachments(Entity)
end)

menu.add_player_feature(lang["Hurricane §"], "toggle", u.malicious_player_features, function(f, pid)
	essentials.set_all_player_feats_except(menu.get_player_feature(f.id).id, false, {pid})
	local entities <const> = {}
	menu.create_thread(function()
		while f.on do
			system.yield(0)
			for i = 1, 7 do
				if not entity.is_an_entity(entities[i] or 0) then
					local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["Default vehicle"])
					if streaming.is_model_a_vehicle(hash) then
						entities[i] = kek_entity.spawn_entity(hash, function()
							return player.get_player_coords(player.player_id()) + v3(0, 0, essentials.random_real(30, 50)), 0
						end)
					end
				end
				if not f.on then
					break
				end
			end
		end
	end, nil)
	while f.on do
		system.yield(0)
		if not entity.is_entity_dead(player.get_player_ped(pid)) then
			for _, Entity in pairs(essentials.deep_copy(entities)) do
				if entity.is_entity_dead(Entity) then
					kek_entity.repair_car(Entity)
				end
				system.yield(0)
				if kek_entity.get_control_of_entity(Entity, 200) then
					essentials.use_ptfx_function(vehicle.set_vehicle_out_of_control, Entity, false, true)
					kek_entity.teleport(Entity, location_mapper.get_most_accurate_position(player.get_player_coords(pid)) + v3(essentials.random_real(-2, 2), essentials.random_real(-2, 2), essentials.random_real(-2, 2)))
				end
			end
		end
	end
	kek_entity.clear_entities(entities)
end)

menu.add_player_feature(lang["Perma-cage §"], "toggle", u.malicious_player_features, function(f, pid)
	local Ped = 0
	while f.on do
		system.yield(0)
		if not kek_entity.get_control_of_entity(Ped) then
			kek_entity.hard_remove_entity_and_its_attachments(Ped)
			Ped = kek_entity.create_cage(pid)
		end
		if essentials.get_distance_between(player.get_player_coords(pid), Ped) > 5 then
			ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			kek_entity.teleport(Ped, player.get_player_coords(pid))
		end
	end
	kek_entity.hard_remove_entity_and_its_attachments(Ped)
end)

local vehicle_blacklist_settings <const> = {}
do
	local vehicle_blacklist_reactions <const> = essentials.const({
		lang["Turned off §"],
		lang["EMP §"],
		lang["Kick from vehicle §"],
		lang["Explode §"],
		lang["Ram §"],
		lang["Glitch §"],
		lang["Fill, steal & run away §"],
		lang["Kick from session §"],
		lang["Crash §"],
		lang["Random §"]
	})
	local vehicle_blacklist_reaction_names <const> = essentials.const({
		"Turned off",
		"EMP",
		"Kick from vehicle",
		"Explode",
		"Ram",
		"Glitch their vehicle",
		"steal",
		"Kick from session",
		"Crash",
		"Random"
	})

	if not utils.file_exists(paths.kek_menu_stuff.."kekMenuData\\Vehicle blacklist settings.ini") then
		essentials.create_empty_file(paths.kek_menu_stuff.."kekMenuData\\Vehicle blacklist settings.ini")
	end
	local str <const> = essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Vehicle blacklist settings.ini", "*a")
	local file <close> = io.open(paths.kek_menu_stuff.."kekMenuData\\Vehicle blacklist settings.ini", "a")
	for _, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
		if not str:find(hash, 1, true) then
			file:write(hash.."="..vehicle_blacklist_reaction_names[1].."\n")
		end
	end
	file:flush()
	for vehicle_entry in essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Vehicle blacklist settings.ini", "*a"):gmatch("([^\n]*)\n?") do
		vehicle_blacklist_settings[tonumber(vehicle_entry:match("(%d+)="))] = vehicle_entry:match("=(.+)")
	end

	menu.add_feature(lang["Turn everything off §"], "action", u.vehicle_blacklist.id, function()
		local file <close> = io.open(paths.kek_menu_stuff.."kekMenuData\\Vehicle blacklist settings.ini", "w+")
		for _, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
			file:write(hash.."="..vehicle_blacklist_reaction_names[1].."\n")
		end
		for _, feat in pairs(essentials.get_descendants(u.vehicle_blacklist, {})) do
			if math.type(feat.data) == "integer" and streaming.is_model_valid(feat.data) then
				feat.value = 0
			end
		end
		file:flush()
	end)

	local parent <const> = menu.add_feature(lang["Search §"], "parent", u.vehicle_blacklist.id)
	local search_feat = menu.add_feature(lang["Search §"], "action", parent.id, function(f)
		local input, status <const> = keys_and_input.get_input(lang["Type in name of vehicle §"], "", 128, 0)
		if status == 2 then
			return
		end
		for _, feat in pairs(f.data) do
			essentials.delete_feature(feat.id)
		end
		f.data = {}
		input = input:lower()
		for _, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
			if vehicle_mapper.get_translated_vehicle_name(hash):lower():find(input) then
				f.data[#f.data + 1] = menu.add_feature(vehicle_mapper.get_translated_vehicle_name(hash), "autoaction_value_str", parent.id, function(f)
					essentials.replace_line_in_file_exact(
						"scripts\\kek_menu_stuff\\kekMenuData\\Vehicle blacklist settings.ini",
						f.data.."="..vehicle_blacklist_settings[f.data], 
						f.data.."="..vehicle_blacklist_reaction_names[f.value + 1]
					)
					vehicle_blacklist_settings[f.data] = vehicle_blacklist_reaction_names[f.value + 1]
					for _, feat in pairs(essentials.get_descendants(u.vehicle_blacklist, {})) do
						if feat ~= f and feat.data == f.data then
							feat.value = f.value
						end
					end
				end)
				f.data[#f.data]:set_str_data(getmetatable(vehicle_blacklist_reactions).__index)
				f.data[#f.data].data = hash
				f.data[#f.data].value = essentials.get_index_of_value(vehicle_blacklist_reaction_names, vehicle_blacklist_settings[f.data[#f.data].data]) - 1
			end
		end
	end)
	search_feat.data = {}

	settings.toggle["Vehicle blacklist"] = menu.add_feature(lang["Vehicle blacklist §"], "toggle", u.vehicle_blacklist.id, function(f)
		local recently_activated_blacklist <const> = {}
		while f.on do
			for pid in essentials.players() do
				if f.on
				and utils.time_ms() > essentials.new_session_timer
				and player.is_player_in_any_vehicle(pid)
				and vehicle_blacklist_settings[entity.get_entity_model_hash(player.get_player_vehicle(pid))] ~= "Turned off"
				and not player.is_player_modder(pid, -1) 
				and essentials.is_not_friend(pid)
				and (not recently_activated_blacklist[player.get_player_vehicle(pid)] or recently_activated_blacklist[player.get_player_vehicle(pid)] < utils.time_ms()) then
					if player.get_player_vehicle(player.player_id()) ~= 0 and player.get_player_vehicle(pid) == player.get_player_vehicle(player.player_id()) then
						break
					end
					local name <const> = player.get_player_name(pid)
					recently_activated_blacklist[player.get_player_vehicle(pid)] = utils.time_ms() + 16000
					local what_reaction = vehicle_blacklist_settings[entity.get_entity_model_hash(player.get_player_vehicle(pid))]
					if what_reaction == "Random" then
						what_reaction = vehicle_blacklist_reaction_names[math.random(2, #vehicle_blacklist_reaction_names - 3)]
					end
					menu.create_thread(function()
						local veh_name <const> = vehicle_mapper.get_translated_vehicle_name(entity.get_entity_model_hash(player.get_player_vehicle(pid)))
						if what_reaction == "EMP" then
							local pos <const> = player.get_player_coords(pid)
							globals.send_script_event("Vehicle EMP", pid, {pid, essentials.round(pos.x), essentials.round(pos.y), essentials.round(pos.z), 0})
							essentials.msg(lang["Vehicle blacklist:\\nEMP'd §"].." "..name.."'s' "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
						elseif what_reaction == "Kick from vehicle" then
							globals.disable_vehicle(pid)
							essentials.msg(lang["Vehicle blacklist:\\nKicked §"].." "..name.." "..lang["out of their §"].." "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
						elseif what_reaction == "Explode" then
							essentials.msg(lang["Vehicle blacklist:\\nExploding §"].." "..name.."'s' "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
							local time <const> = utils.time_ms() + 10000
							while time > utils.time_ms() and not entity.is_entity_dead(player.get_player_ped(pid)) do
								essentials.use_ptfx_function(fire.add_explosion, location_mapper.get_most_accurate_position(player.get_player_coords(pid)), math.random(0, 82), true, false, 0, player.get_player_ped(pid))
								system.yield(300)
							end
						elseif what_reaction == "Ram" then
							essentials.msg(lang["Vehicle blacklist:\\nRamming §"].." "..name.."'s' "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
							local time <const> = utils.time_ms() + 3000
							while time > utils.time_ms() and not entity.is_entity_dead(player.get_player_ped(pid)) do
								essentials.use_ptfx_function(kek_entity.spawn_and_push_a_vehicle_in_direction, pid, true, 8, gameplay.get_hash_key("tanker"))
								system.yield(250)
							end
						elseif what_reaction == "Glitch their vehicle" then
							kek_entity.glitch_vehicle(player.get_player_vehicle(pid))
							essentials.msg(lang["Vehicle blacklist:\\nGlitching §"].." "..name.."'s' "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
						elseif what_reaction == "steal" then
							essentials.msg(lang["Vehicle blacklist:\\nstealing §"].." "..name.."'s' "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
							menu.get_player_feature(player_feat_ids["Mad peds"]).feats[pid].value = 0
							menu.get_player_feature(player_feat_ids["Mad peds"]).feats[pid].on = true
						elseif what_reaction == "Kick from session" then
							globals.kick(pid)
							essentials.msg(lang["Vehicle blacklist:\\nKicked §"].." "..name.." "..lang["for using §"].." "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
						elseif what_reaction == "Crash" then
							globals.script_event_crash(pid)
							essentials.msg(lang["Vehicle blacklist:\\nCrashed §"].." "..name.." "..lang["for using §"].." "..veh_name..".", 140, settings.in_use["Vehicle blacklist #notifications#"])
						end
					end, nil)
					break
				end
			end
			system.yield(0)
		end
	end)

	kek_entity.generate_vehicle_list(
		"autoaction_value_str",
		getmetatable(vehicle_blacklist_reactions).__index,
		u.vehicle_blacklist,
		function(hash)
			return essentials.get_index_of_value(vehicle_blacklist_reaction_names, vehicle_blacklist_settings[hash]) - 1
		end,
		function(f)
			for _, feat in pairs(essentials.get_descendants(u.vehicle_blacklist, {})) do
				if feat ~= f and f.data == feat.data then
					feat.value = f.value
				end
			end
			essentials.replace_line_in_file_exact(
				"scripts\\kek_menu_stuff\\kekMenuData\\Vehicle blacklist settings.ini",
				f.data.."="..vehicle_blacklist_settings[f.data], 
				f.data.."="..vehicle_blacklist_reaction_names[f.value + 1]
			)
			vehicle_blacklist_settings[f.data] = vehicle_blacklist_reaction_names[f.value + 1]
		end
	)
end

menu.add_feature(lang["Spawn vehicle for everyone §"], "action", u.vehicle_friendly.id, function()
	local model <const>, status <const> = keys_and_input.get_input(lang["Type in which car to spawn §"], "", 128, 0)
	if status == 2 then
		return
	end
	local hash <const> = vehicle_mapper.get_hash_from_user_input(model:lower())
	if streaming.is_model_a_vehicle(hash) then
		local spawn_count = 0
		for pid in essentials.players() do
			local car <const> = kek_entity.spawn_entity(hash, function()
				return location_mapper.get_most_accurate_position(player.get_player_coords(pid)), player.get_player_heading(pid)
			end, settings.toggle["Spawn #vehicle# in godmode"].on, settings.toggle["Spawn #vehicle# maxed"].on)
			if not entity.is_an_entity(car) then
				essentials.msg(lang["Failed to spawn §"].." "..(player.player_count() - spawn_count).."/"..player.player_count().." "..lang["Vehicles §"]:lower()..". "..lang["Vehicle limit was reached. §"], 6, true, 6)
				break
			end
			spawn_count = spawn_count + 1
			decorator.decor_set_int(car, "MPBitset", 1 << 10)
		end
		essentials.msg(lang["Cars spawned. §"], 140, true)
	end
end)

menu.add_feature(lang["Max everyone's car §"], "action", u.vehicle_friendly.id, function()
	local initial_pos <const> = player.get_player_coords(player.player_id())
	for pid in essentials.players() do
		if kek_entity.is_target_viable(pid) then
			kek_entity.max_car(player.get_player_vehicle(pid))
		end
	end
	kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
	essentials.msg(lang["Maxed everyone's cars. §"], 212, true)
end)	

menu.add_player_feature(lang["Make nearby peds hostile §"], "toggle", u.player_trolling_features, function(f, pid)
	if f.on then
		local weapons <const> = weapon_mapper.get_table_of_weapons({
			rifles = true,
			smgs = true,
			heavy = true,
			throwables = true
		})
		local peds = {}
		local ped_tracker <const> = {}
		while f.on do
			system.yield(250)
			peds = essentials.const_all(kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(
				{
					peds = {
						entities 			   = ped.get_all_peds(),
						max_number_of_entities = 20,
						remove_player_entities = true,
						max_range			   = nil,
						sort_by_closest		   = true
					}	
				},
				player.get_player_ped(pid)
			))
			for _, Ped in pairs(peds) do
				if kek_entity.get_control_of_entity(Ped, 100) then
					ai.task_combat_ped(Ped, player.get_player_ped(pid), 0, 16)
					if not ped_tracker[Ped] then
						weapon.give_delayed_weapon_to_ped(Ped, weapons[math.random(1, #weapons)], 0, 1)
						kek_entity.set_combat_attributes(Ped, true, {})
						ped.set_ped_can_ragdoll(Ped, false)
						gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(Ped), entity.get_entity_coords(Ped) + v3(0, 0.0, 0.1), 0, gameplay.get_hash_key("weapon_pistol"), player.get_player_ped(pid), false, true, 100)
						ped.set_ped_can_ragdoll(Ped, true)
						ped_tracker[Ped] = true
					end
				end
				if not f.on then
					break
				end
			end
		end
		for Ped, _ in pairs(ped_tracker) do
			if kek_entity.get_control_of_entity(Ped, 100) then
				weapon.remove_all_ped_weapons(Ped)
				kek_entity.set_combat_attributes(Ped, false, {})
				ped.clear_ped_tasks_immediately(Ped)
			end
		end
	end
end)

player_feat_ids["Mad peds"] = menu.add_player_feature(lang["Mad peds in their car §"], "action_value_str", u.player_trolling_features, function(f, pid)
	for _, Vehicle in pairs({player.get_player_vehicle(pid), globals.get_player_personal_vehicle(pid)}) do
		if entity.is_entity_a_vehicle(Vehicle) and not entity.is_entity_dead(Vehicle) then
			if (f.value == 0 or f.value == 1) and ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0) then
				ped.clear_ped_tasks_immediately(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0)
				local time <const> = utils.time_ms() + 3000
				while entity.is_an_entity(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0) and time > utils.time_ms() do
					system.yield(0)
				end
				system.yield(500)
			end
			local hash <const> = gameplay.get_hash_key(ped_mapper.LIST_OF_SPECIAL_PEDS[math.random(1, #ped_mapper.LIST_OF_SPECIAL_PEDS)])
			if f.value == 0 and not entity.is_an_entity(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0) then
				local Ped <const> = kek_entity.spawn_entity(hash, function()
					return player.get_player_coords(player.player_id()) + v3(0, 0, 10), 0
				end, false, false, enums.ped_types.civmale)
				ped.set_ped_into_vehicle(Ped, Vehicle, enums.vehicle_seats.driver)
				ped.set_ped_combat_attributes(Ped, 3, false)
			end
			troll_entity.setup_peds_and_put_in_seats(kek_entity.get_empty_seats(Vehicle), hash, Vehicle, pid, true)
			if f.value == 0 then
				ai.task_vehicle_drive_to_coord_longrange(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0, Vehicle, v3(math.random(-7000, 7000), math.random(-7000, 7000), 50), 150, drive_style_mapper.get_drive_style_from_list({
					["Stop before vehicles"] = false,
					["Stop before peds"] = false,
					["Avoid vehicles"] = true,
					["Avoid empty vehicles"] = true,
					["Avoid peds"] = false,
					["Avoid objects"] = false,
					["Stop at traffic lights"] = false,
					["Use blinkers"] = false,
					["Allow going wrong way"] = true,
					["Drive in reverse"] = false,
					["Take shortest path"] = false,
					["Allow overtaking vehicles"] = true,
					["Ignore roads"] = false,
					["Ignore all pathing"] = false,
					["Avoid highways"] = false
				}), 100)
			end
		end
	end
end).id
menu.get_player_feature(player_feat_ids["Mad peds"]):set_str_data({
	lang["Fill, steal & run away §"],
	lang["Fill & steal §"],
	lang["Fill §"]
})

menu.add_feature(lang["Teleport session §"], "value_str", u.session_trolling.id, function(f)
	local initial_pos <const> = player.get_player_coords(player.player_id())
	menu.create_thread(function()
		while f.on do
			entity.set_entity_velocity(essentials.get_most_relevant_entity(player.player_id()), v3())
			system.yield(0)
		end
	end, nil)
	while f.on do
		if f.value == 0 then
			local pos <const> = player.get_player_coords(player.player_id())
			while f.value == 0 and f.on do
				kek_entity.teleport_session(pos, f)
				system.yield(0)
			end
		elseif f.value == 1 and ui.get_waypoint_coord().x < 14000 then
			local pos <const> = location_mapper.get_most_accurate_position(v3(ui.get_waypoint_coord().x, ui.get_waypoint_coord().y, -50))
			while f.value == 1 and f.on do
				kek_entity.teleport_session(pos, f)
				system.yield(0)
			end
		elseif f.value == 2 then
			local players <const> = {}
			for pid in essentials.players() do
				if f.value ~= 2 or not f.on then
					break
				end
				if essentials.is_not_friend(pid) then
					local status <const> = kek_entity.teleport_player_and_vehicle_to_position(pid, v3(491.9401550293, 5587, 794.00347900391), true, false)
					if status then
						globals.disable_vehicle(pid)
						players[#players + 1] = pid
					end
				end
			end
			essentials.wait_conditional(1500, function()
				return f.on and f.value == 2
			end)
			for i = 1, #players do
				if not entity.is_entity_dead(player.get_player_ped(players[i])) then
					for i2 = 1, 10 do
						system.yield(0)
						essentials.use_ptfx_function(fire.add_explosion, player.get_player_coords(players[i]), 29, true, false, 0, player.get_player_ped(players[i]))
					end
				end
			end
		elseif f.value == 3 then
			kek_entity.teleport_session(v3(24000, -24000, 2300), f)
		end
		system.yield(0)
	end
	kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
end):set_str_data({
	lang["Current position §"],
	lang["Waypoint §"],
	lang["Mount Chiliad & kill §"],
	lang["far away §"]
})

do
	local function get_people_in_front_of_person_in_host_queue()
		if network.network_is_host() then
			return
		end
		local hosts <const>, friends <const> = {}, {}
		local player_host_priority <const> = player.get_player_host_priority(player.player_id())
		for pid in essentials.players() do
			if player.get_player_host_priority(pid) <= player_host_priority or player.is_player_host(pid) then
				hosts[#hosts + 1] = pid
				if network.is_scid_friend(player.get_player_scid(pid)) then
					friends[#friends + 1] = pid
				end
			end
		end
		return hosts, friends
	end

	local function get_host(...)
		local hosts <const>, friends <const> = get_people_in_front_of_person_in_host_queue()
		if friends and settings.in_use["Exclude friends from attacks #malicious#"] and #friends > 0 then
			essentials.msg(lang["One of the people further in host queue is your friend! Cancelled. §"], 212, true)
		elseif hosts then
			for _, pid in pairs(hosts) do
				globals.send_script_event("Netbail kick", pid, {pid, globals.generic_player_global(pid)})
			end
		end
	end

	menu.add_feature(lang["Get host §"], "action", u.session_malicious.id, function(f)
		get_host()
	end)

	settings.toggle["Force host"] = menu.add_feature(lang["Get host automatically §"], "toggle", u.session_malicious.id, function(f)
		while f.on do
			system.yield(0)
			local players_in_queue <const>, friends_in_queue <const> = get_people_in_front_of_person_in_host_queue()
			if players_in_queue and (not settings.in_use["Exclude friends from attacks #malicious#"] or #friends_in_queue == 0)
			and #players_in_queue <= settings.valuei["Max number of people to kick in force host"].value then
				get_host()
			end
		end
	end)
end

settings.valuei["Max number of people to kick in force host"] = menu.add_feature(lang["Max kicks for auto host §"], "autoaction_value_i", u.session_malicious.id)
settings.valuei["Max number of people to kick in force host"].max, settings.valuei["Max number of people to kick in force host"].min, settings.valuei["Max number of people to kick in force host"].mod = 31, 1, 1

do
	local block_area_parent <const> = menu.add_feature(lang["Block areas §"], "parent", u.session_malicious.id)

	local function block_area(...)
		local angles <const>,
		offsets <const>,
		locations <const>,
		object_model <const> = ...
		for i, location in pairs(locations) do
			local offset = v3()
			if offsets[i] then
				offset = offsets[i]
			end
			local object <const> = kek_entity.spawn_entity(gameplay.get_hash_key(object_model), function()
				return location - v3(0, 0, 2) + offset, 0
			end)
			if object and entity.is_an_entity(object) then
				if angles[i] then
					entity.set_entity_heading(object, angles[i])
				end
			end
		end
	end

	local function unblock_area(...)
		local model <const>, positions <const> = ...
		essentials.assert(streaming.is_model_valid(gameplay.get_hash_key(model)), "Invalid model.")
		local initial_pos <const> = player.get_player_coords(player.player_id())
		local had_to_teleport
		for _, pos in pairs(positions) do
			if essentials.get_distance_between(player.get_player_ped(player.player_id()), pos) > 200 then
				kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), pos)
				had_to_teleport = true
				system.yield(100)
			end
			for _, Entity in pairs(object.get_all_objects()) do
				if entity.get_entity_model_hash(Entity) == gameplay.get_hash_key(model) then
					kek_entity.clear_entities({Entity})
				end
			end
		end
		if had_to_teleport then
			kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
		end
	end

	menu.add_feature(lang["Los santos customs §"], "action_value_str", block_area_parent.id, function(f)
		if f.value == 0 then
			local angles <const> = essentials.const({
				-135, 
				0, 
				-40, 
				-90, 
				70, 
				0
			})
			block_area(angles, {}, location_mapper.LSC_POSITIONS, "v_ilev_cin_screen")
		elseif f.value == 1 then
			unblock_area("v_ilev_cin_screen", location_mapper.LSC_POSITIONS)
		end
	end):set_str_data({
		lang["Block §"],
		lang["Unblock §"]
	})

	menu.add_feature(lang["Ammu-Nations §"], "action_value_str", block_area_parent.id, function(f)
		if f.value == 0 then
			block_area({}, {}, location_mapper.AMMU_NATION_POSITIONS, "prop_air_monhut_03_cr")
		elseif f.value == 1 then
			unblock_area("prop_air_monhut_03_cr", location_mapper.AMMU_NATION_POSITIONS)
		end
	end):set_str_data({
		lang["Block §"],
		lang["Unblock §"]
	})

	menu.add_feature(lang["Casino §"], "action_value_str", block_area_parent.id, function(f)
		if f.value == 0 then
			local offsets <const> = 
				{
					v3(), 
					v3(-3, 4, 0), 
					v3(-2.5, 1.75, 0)
				}
			local angles <const> = essentials.const({
				55, 
				-34, 
				-32
			})
			block_area(angles, offsets, location_mapper.CASINO_POSITIONS, "prop_sluicegater")
		elseif f.value == 1 then
			unblock_area("prop_sluicegater", location_mapper.CASINO_POSITIONS)
		end
	end):set_str_data({
		lang["Block §"],
		lang["Unblock §"]
	})
end

menu.add_feature(lang["Freeze session §"], "toggle", u.session_malicious.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) 
			and not player.is_player_modder(pid, -1) 
			and not entity.is_entity_dead(player.get_player_ped(pid)) then
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			end
		end
	end
end)	

menu.add_feature(lang["Cage session §"], "action", u.session_malicious.id, function()
	for pid in essentials.players() do
		if essentials.is_not_friend(pid) then
			kek_entity.create_cage(pid)
		end
	end
end)

menu.add_feature(lang["Give session bounty §"], "action_value_str", u.session_trolling.id, function(f)
	if f.value == 2 then
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in bounty amount §"], "", 5, 3)
		if status == 2 then
			return
		end
		settings.in_use["Bounty amount"] = input
	else
		for pid in essentials.players() do
			globals.set_bounty(pid, true, f.value == 0)
		end
	end
end):set_str_data({
	lang["Anonymous §"],
	lang["With your name §"],
	lang["Change amount §"]		
})

menu.add_feature(lang["Reapply bounty §"], "value_str", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if entity.is_entity_dead(player.get_player_ped(pid)) then
				globals.set_bounty(pid, true, f.value == 0)
			end
		end
		system.yield(500)
	end
end):set_str_data({
	lang["Anonymous §"],
	lang["With your name §"]	
})

menu.add_feature(lang["Never wanted §"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if player.get_player_wanted_level(pid) > 0 and not player.is_player_modder(pid, -1) then
				globals.send_script_event("Remove wanted level", pid, {pid, globals.generic_player_global(pid)}, true)
			end
		end
		system.yield(500)
	end
end)

menu.add_feature(lang["off the radar §"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if not globals.is_player_otr(pid) and not player.is_player_modder(pid, -1) then
				globals.send_script_event("Give OTR or ghost organization", pid, {pid, utils.time() - 60, utils.time(), 1, 1, globals.generic_player_global(pid)}, true)
			end
		end
		system.yield(500)
	end
end)

u.send_30k_to_session = menu.add_feature(lang["30k ceo loop §"], "toggle", u.session_trolling.id, function(f)
	menu.get_player_feature(player_feat_ids["30k ceo"]).on = false
	menu.create_thread(function()
		while f.on do
			system.yield(0)
			for pid in essentials.players() do
				globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 0, globals.generic_player_global(pid), globals.get_9__10_globals_pair()})
			end
			essentials.wait_conditional(15000, function() 
				return f.on 
			end)
			for pid in essentials.players() do
				globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 1, globals.generic_player_global(pid), globals.get_9__10_globals_pair()})
			end
			essentials.wait_conditional(15000, function() 
				return f.on 
			end)
		end
	end, nil)
	while f.on do
		for pid in essentials.players() do
			globals.send_script_event("CEO money", pid, {pid, 30000, 198210293, 1, globals.generic_player_global(pid), globals.get_9__10_globals_pair()})
		end
		essentials.wait_conditional(100000, function() 
			return f.on 
		end)
		system.yield(0)
	end
end)

menu.add_feature(lang["Block passive §"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Block passive", pid, {pid, 1})
			end
			system.yield(0)
		end
	end
	for pid in essentials.players() do
		if not player.is_player_modder(pid, -1) then
			globals.send_script_event("Block passive", pid, {pid, 0})
		end
	end
end)

menu.add_feature(lang["Send to random mission §"], "action", u.session_trolling.id, function(f)
	for pid in essentials.players() do
		if not player.is_player_modder(pid, -1) then
			globals.send_script_event("Send to mission", pid, {pid, math.random(1, 7)}, true)
		end
	end
end)

menu.add_feature(lang["Perico island §"], "toggle", u.session_trolling.id, function(f)
	if f.on then
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Send to Perico island", pid, {pid, globals.get_script_event_hash("Send to Perico island"), 0, 0}, true)
			end
		end
	else
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, 1, 1, 1, 1}, true)
			end
		end
	end
end)

menu.add_feature(lang["Apartment invites §"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, math.random(1, 114), 1, 1, 1}, true)
			end
		end
		system.yield(5000)
	end
end)

menu.add_feature(lang["CEO §"], "action_value_str", u.session_trolling.id, function(f)
	if f.value == 0 then
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("CEO ban", pid, {pid, 1}, true)
			end
		end
	elseif f.value == 1 then
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Dismiss or terminate from CEO", pid, {pid, 1, 5}, true)
			end
		end
	elseif f.value == 2 then
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Dismiss or terminate from CEO", pid, {pid, 1, 6}, true)
			end
		end
	end
end):set_str_data({
	lang["Ban §"],
	lang["Dismiss §"],
	lang["Terminate §"]
})

menu.add_feature(lang["Notification spam §"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			globals.send_script_event("Insurance notification", pid, {pid, math.random(-2147483647, 2147483647)}, true)
		end
	end
end)

menu.add_feature(lang["Transaction error §"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Transaction error", pid, {pid, 50000, 0, 1, globals.generic_player_global(pid), globals.get_9__10_globals_pair(), 1})
			end
		end
		system.yield(1000)
	end
end)

settings.toggle["Chat logger"] = menu.add_feature(lang["Chat logger §"], "toggle", u.chat_stuff.id, function(f)
	if f.on then
		essentials.listeners["chat"]["logger"] = event.add_event_listener("chat", function(event)
			if player.is_player_valid(event.player)
			and (not f.data[player.get_player_scid(event.player)] or utils.time_ms() + 10000 > f.data[player.get_player_scid(event.player)]) then
				local name <const> = player.get_player_name(event.player).."                "
				local str = ""
				for line in event.body:gmatch("([^\n]*)\n?") do
					if line ~= "" then
						str = str.."["..name:sub(1, 16).."]["..os.date().."]: "..line.."\n"
					end
				end
				essentials.log("scripts\\kek_menu_stuff\\kekMenuLogs\\Chat log.log", str)
				if f.data[player.get_player_scid(event.player)] and utils.time_ms() < f.data[player.get_player_scid(event.player)] then
					f.data[player.get_player_scid(event.player)] = f.data[player.get_player_scid(event.player)] + 2000
				else
					f.data[player.get_player_scid(event.player)] = utils.time_ms() + 1000
				end
			end
			system.yield(0)
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["logger"])
		essentials.listeners["chat"]["logger"] = nil
	end
end)
settings.toggle["Chat logger"].data = {}

settings.toggle["Anti chat spam"] = menu.add_feature(lang["Anti chat spam §"], "value_str", u.chat_stuff.id, function(f)
	if f.on then
		if essentials.listeners["chat"]["anti spam"] then
			return
		end
		essentials.listeners["chat"]["anti spam"] = event.add_event_listener("chat", function(event)
			local scid <const> = player.get_player_scid(event.player)
			if essentials.is_not_friend(event.player) and utils.time_ms() > (f.data.since_last_reaction[scid] or 0) and event.player ~= player.player_id() then
				if f.data[scid] then
					if f.data[scid].previous_msg == event.body then
						f.data[scid].same_in_a_row_count = f.data[scid].same_in_a_row_count + 1
					else
						f.data[scid].same_in_a_row_count = 1
						f.data[scid].previous_msg = event.body
					end
				else
					f.data[scid] = {
						same_in_a_row_count = 1,
						previous_msg = event.body,
						fast_spam_count = 0,
						time = utils.time_ms() + 1000
					}
				end
				f.data[scid].fast_spam_count = f.data[scid].fast_spam_count + 1
				if utils.time_ms() > f.data[scid].time then
					f.data[scid].time = 0
					f.data[scid].fast_spam_count = 0
				end
				if f.data[scid].same_in_a_row_count >= 3 or f.data[scid].fast_spam_count >= 3 then
					f.data.since_last_reaction[scid] = utils.time_ms() + 90000
					if f.data[scid].same_in_a_row_count >= 3 then
						essentials.msg(player.get_player_name(event.player) .. " " .. lang["kicked for sending the same message 3 times in a row. §"], 212, true, 6)
					else
						essentials.msg(player.get_player_name(event.player) .. " " .. lang["kicked for spamming chat. §"], 212, true, 6)
					end
					f.data[scid] = nil
					if f.value == 1 or f.value == 3 then
						essentials.add_to_timeout(event.player)
					end
					if f.value == 0 or f.value == 1 then
						if network.network_is_host() then
							network.network_session_kick_player(event.player)
						else
							globals.send_script_event("Netbail kick", event.player, {event.player, globals.generic_player_global(event.player)})
						end
					elseif f.value == 2 or f.value == 3 then
						globals.script_event_crash(event.player)
					end
				end
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["anti spam"])
		essentials.listeners["chat"]["anti spam"] = nil			
	end
end)
settings.valuei["Anti chat spam reaction"] = settings.toggle["Anti chat spam"]
settings.valuei["Anti chat spam reaction"]:set_str_data({
	lang["Kick §"],
	lang["Kick & add to timeout §"],
	lang["Crash §"],
	lang["Crash & add to timeout §"]
})
settings.toggle["Anti chat spam"].data = {since_last_reaction = {}}

do
	local function create_anti_stuck_thread(...)
		local f <const>, wp <const> = ...
		return menu.create_thread(function()
			local consecutive_stuck_counter = 0
			while f.on do
				system.yield(0)
				if settings.toggle["Anti stuck measures"].on then
					local time <const> = utils.time_ms() + 4000
					while f.on
					and settings.toggle["Anti stuck measures"].on
					and (not wp or f.value ~= 1 or ui.get_waypoint_coord().x < 14000)
					and player.is_player_in_any_vehicle(player.player_id())
					and time > utils.time_ms()
					and entity.get_entity_speed(player.get_player_vehicle(player.player_id())) < 2
					and entity.get_entity_submerged_level(player.get_player_vehicle(player.player_id())) ~= 1
					and not entity.is_entity_in_air(player.get_player_vehicle(player.player_id())) do
						system.yield(0)
						if utils.time_ms() > time then
							consecutive_stuck_counter = consecutive_stuck_counter + 1
							if consecutive_stuck_counter < 5 then
								vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()), -10)
								entity.set_entity_heading(player.get_player_vehicle(player.player_id()), kek_entity.get_rotated_heading(player.get_player_vehicle(player.player_id()), 180, player.player_id(), player.get_player_heading(player.player_id())))
							end
						end
					end
					if not settings.toggle["Anti stuck measures"].on then
						consecutive_stuck_counter = 0
					end
					if wp and f.value == 1 and ui.get_waypoint_coord().x > 14000 then
						consecutive_stuck_counter = 0
					end
					if entity.get_entity_speed(player.get_player_vehicle(player.player_id())) > 12 then
						consecutive_stuck_counter = 0
					end
					if consecutive_stuck_counter > 3 or vehicle.is_vehicle_stuck_on_roof(player.get_player_vehicle(player.player_id())) or (entity.get_entity_submerged_level(player.get_player_vehicle(player.player_id())) == 1 and not streaming.is_model_a_boat(entity.get_entity_model_hash(player.get_player_vehicle(player.player_id())))) then
						consecutive_stuck_counter = 0
						kek_entity.teleport(player.get_player_vehicle(player.player_id()), location_mapper.get_most_accurate_position(player.get_player_coords(player.player_id()) + essentials.get_random_offset(-80, 80, 25, 75), true))
					end
				end
				if entity.is_an_entity(player.get_player_vehicle(player.player_id())) and entity.is_entity_dead(player.get_player_vehicle(player.player_id())) and player.is_player_in_any_vehicle(player.player_id()) then
					kek_entity.repair_car(player.get_player_vehicle(player.player_id()))
				end
			end
		end, nil)
	end

	settings.toggle["Anti stuck measures"] = menu.add_feature(lang["Anti stuck §"], "toggle", u.ai_drive.id)

	u.ai_drive_feature = menu.add_feature(lang["Ai driving §"], "value_str", u.ai_drive.id, function(f)
		if f.on then
			local thread <const> = create_anti_stuck_thread(f, true)
			local value, speed, style, Vehicle
			local time = 0
			local pos = ui.get_waypoint_coord()
			menu.get_player_feature(player_feat_ids["Follow player"]).on = false
			while f.on do
				if player.is_player_in_any_vehicle(player.player_id()) then
					if (f.value ~= 1 or ui.get_waypoint_coord().x < 14000) and entity.is_entity_upside_down(player.get_player_vehicle(player.player_id())) then
						local rot <const> = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
						entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), v3(0, 0, rot.z))
					end
					if value ~= f.value 
					or Vehicle ~= player.get_player_vehicle(player.player_id()) 
					or speed ~= u.drive_speed.value 
					or style ~= settings.in_use["Drive style"] 
					or (f.value == 1 and pos ~= ui.get_waypoint_coord()) 
					or utils.time_ms() > time
					or (f.value == 0 and not ai.is_task_active(player.get_player_ped(player.player_id()), enums.ctasks.CarDriveWander)) then
						if f.value == 1 and ui.get_waypoint_coord().x > 14000 then
							kek_entity.clear_tasks_without_leaving_vehicle(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()))
							while f.on and f.value == 1 and ui.get_waypoint_coord().x > 14000 do
								system.yield(0)
							end
						end
						value = f.value
						speed = u.drive_speed.value
						style = settings.in_use["Drive style"]
						pos = ui.get_waypoint_coord()
						Vehicle = player.get_player_vehicle(player.player_id())
						time = utils.time_ms() + 7000
						entity.set_entity_max_speed(player.get_player_vehicle(player.player_id()), u.drive_speed.value)
						if f.value == 0 then
							ai.task_vehicle_drive_wander(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), u.drive_speed.value, settings.in_use["Drive style"])
						elseif f.value == 1 and ui.get_waypoint_coord().x < 14000 then
							ai.task_vehicle_drive_to_coord_longrange(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), location_mapper.get_most_accurate_position(v3(ui.get_waypoint_coord().x, ui.get_waypoint_coord().y, -50)), u.drive_speed.value, settings.in_use["Drive style"], 10)
						end
					end
				end
				system.yield(250)
			end
			menu.delete_thread(thread)
			kek_entity.clear_tasks_without_leaving_vehicle(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()))
		end
	end)
	u.ai_drive_feature:set_str_data({
		lang["Wander §"],
		lang["waypoint §"]
	})


	player_feat_ids["Follow player"] = menu.add_player_feature(lang["Follow player §"], "toggle", u.player_misc_features, function(f, pid)
		if f.on then
			if player.player_id() == pid then
				f.on = false
				return
			end
			essentials.set_all_player_feats_except(player_feat_ids["Follow player"], false, {pid})
			u.ai_drive_feature.on = false
			local thread <const> = create_anti_stuck_thread(f)
			local speed, style, Vehicle, value
			local time = 0
			local pos = player.get_player_coords(player.player_id())
			while f.on do
				if player.is_player_in_any_vehicle(player.player_id()) then
					if entity.is_entity_upside_down(player.get_player_vehicle(player.player_id())) then
						local rot <const> = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
						entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), v3(0, 0, rot.z))
					end
					if Vehicle ~= player.get_player_vehicle(player.player_id()) 
					or speed ~= u.drive_speed.value 
					or style ~= settings.in_use["Drive style"] 
					or utils.time_ms() > time
					or ((value > 250 and (essentials.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id())) < 250 or essentials.get_distance_between(pos, player.get_player_coords(pid)) > 250))
						or (value < 250 and essentials.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id())) > 250)) then
						speed = u.drive_speed.value
						style = settings.in_use["Drive style"]
						Vehicle = player.get_player_vehicle(player.player_id())
						value = essentials.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id()))
						pos = player.get_player_coords(pid)
						entity.set_entity_max_speed(player.get_player_vehicle(player.player_id()), u.drive_speed.value)
						time = utils.time_ms() + 7000
						if essentials.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id())) > 250 then
							ai.task_vehicle_drive_to_coord_longrange(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), pos, u.drive_speed.value, settings.in_use["Drive style"], 10)
						else
							ai.task_vehicle_follow(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), player.get_player_ped(pid), u.drive_speed.value, settings.in_use["Drive style"], 0)
						end
					end
				end
				system.yield(250)
			end
			menu.delete_thread(thread)
			kek_entity.clear_tasks_without_leaving_vehicle(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()))
		end
	end).id
end

u.drive_speed = menu.add_feature(lang["Drive speed §"], "action_slider", u.ai_drive.id, function(f)
	keys_and_input.input_value_i(f, lang["Type in vehicle speed §"])
end)
u.drive_speed.max, u.drive_speed.min, u.drive_speed.mod = 150, 5, 5
u.drive_speed.value = 90

for _, drive_style_property in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
	settings.drive_style_toggles[#settings.drive_style_toggles + 1] = {drive_style_property.flag, menu.add_feature(lang[drive_style_property.name.." §"], "toggle", u.drive_style_cfg.id, function(f)
		if f.on and settings.in_use["Drive style"] & drive_style_property.flag == 0 then
			settings.in_use["Drive style"] = settings.in_use["Drive style"] + drive_style_property.flag
		elseif not f.on and settings.in_use["Drive style"] & drive_style_property.flag ~= 0 then
			settings.in_use["Drive style"] = settings.in_use["Drive style"] - drive_style_property.flag
		end
	end)}
end

menu.add_player_feature(lang["This player can't use chat commands §"], "toggle", u.player_misc_features, function(f, pid)
	settings.toggle["Chat commands"].data.player_chat_command_blacklist[player.get_player_scid(pid)] = f.on
end)

do
	local function create_judge_feat(...)
		local name <const> = ...
		if name:find("..", 1, true) or name:find("%.$") or name ~= essentials.get_safe_feat_name(name) then
			return
		end
		menu.add_feature(essentials.get_safe_feat_name(name):gsub("%.ini$", ""), "action_value_str", u.custom_chat_judger.id, function(f)
			if f.value == 0 then
				if not utils.file_exists(paths.home.."scripts\\kek_menu_stuff\\Chat judger profiles\\"..f.name..".ini") then
					essentials.msg(lang["Couldn't find file §"], 6, true)
				else
					local str <const> = essentials.get_file_string("scripts\\kek_menu_stuff\\Chat judger profiles\\"..f.name..".ini", "*a")
					local count = 1
					for chat_judge_entry in str:gmatch("([^\n]*)\n?") do
						if not pcall(function()
							return str:find(chat_judge_entry)
						end) then
							essentials.msg(lang["Failed to load profile. Error at line §"]..": "..count.."\nscripts\\kek_menu_stuff\\Chat judger profiles\\"..f.name..".ini", 6, true, 8)
							return
						end
						count = count + 1
					end
					essentials.msg(lang["Successfully loaded §"].." "..f.name, 210, true)
					local file <close> = io.open(paths.kek_menu_stuff.."kekMenuData\\custom_chat_judge_data.txt", "w+")
					file:write(str)
					file:flush()
					o.update_chat_judge = true
				end
			elseif f.value == 1 then
				local text = ""
				local status
				while true do
					text, status = keys_and_input.get_input(lang["Type in what to add. §"], text, 128, 0)
					if status == 2 then
						return
					end
					if essentials.search_for_match_and_get_line("scripts\\kek_menu_stuff\\Chat judger profiles\\"..f.name..".ini", {text}, true) then
						essentials.msg(lang["Entry already exists in this profile. §"], 6, true, 6)
						goto skip 
					end
					if not essentials.invalid_pattern(text, true, true) then
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.log("scripts\\kek_menu_stuff\\Chat judger profiles\\"..f.name..".ini", text)
				essentials.msg(lang["Added §"].." "..text, 212, true)
			elseif f.value == 2 then
				local text <const>, status <const> = keys_and_input.get_input(lang["Type in what to remove. §"], "", 128, 0)
				if status == 2 then
					return
				end
				if essentials.remove_line_from_file_exact("scripts\\kek_menu_stuff\\Chat judger profiles\\"..f.name..".ini", text) then
					essentials.msg(lang["Removed §"].." "..text, 212, true)
				else 
					essentials.msg(lang["Couldn't find entry. §"], 6, true)
				end
			elseif f.value == 3 then
				if utils.file_exists(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini") then
					io.remove(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini")
				end
				f.hidden = true
			elseif f.value == 4 then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in the name of the profile. §"], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
						goto skip
					end
					if utils.file_exists(paths.kek_menu_stuff.."Chat judger profiles\\"..input..".ini") then
						essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
						goto skip
					end
					if input:find("[<>:\"/\\|%?%*]") then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
					else
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file("scripts\\kek_menu_stuff\\Chat judger profiles\\", f.name, input, "ini")
				f.name = input
			end
		end):set_str_data({
			lang["Load §"],
			lang["Add §"],
			lang["Remove §"],
			lang["Delete §"],
			lang["Change name §"]
		})
	end

	settings.toggle["Custom chat judger"] = menu.add_feature(lang["Custom chat judge §"], "value_str", u.custom_chat_judger.id, function(f)
		if f.on then
			if essentials.listeners["chat"]["judger"] then
				return
			end
			f.data.str = essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\custom_chat_judge_data.txt", "*a"):lower()
			do
				local count = 1
				for chat_judge_entry in f.data.str:gmatch("([^\n]*)\n?") do
					if not pcall(function()
						return f.data.str:find(chat_judge_entry)
					end) then
						essentials.msg("["..lang["Custom chat judge §"].."]: "..lang["Failed to load profile. Error at line §"]..": "..count.."\nscripts\\kek_menu_stuff\\kekMenuData\\custom_chat_judge_data.txt", 6, true, 12)
						f.data.str = ""
					end
					count = count + 1
				end
			end
			essentials.listeners["chat"]["judger"] = event.add_event_listener("chat", function(event)
				if player.is_player_valid(event.player)
				and event.player ~= player.player_id()
				and (not f.data.tracker[player.get_player_scid(event.player)] or utils.time_ms() > f.data.tracker[player.get_player_scid(event.player)])
				and essentials.is_not_friend(event.player) then
					if o.update_chat_judge then
						f.data.str = essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\custom_chat_judge_data.txt", "*a"):lower()
						o.update_chat_judge = false
					end
					local msg <const> = event.body:lower()
					for chat_judge_entry in f.data.str:gmatch("([^\n]*)\n?") do
						local is_blacklist <const> = chat_judge_entry:find("[blacklist]", 1, true) ~= nil
						local is_timeout <const> = chat_judge_entry:find("[join timeout]", 1, true) ~= nil
						chat_judge_entry = (chat_judge_entry:gsub("%[join timeout%]", "")):gsub("%[blacklist%]", "")
						if msg:find(chat_judge_entry) then
							f.data.tracker[player.get_player_scid(event.player)] = utils.time_ms() + 4000
							if player.is_player_valid(event.player) then
								local player_name <const> = player.get_player_name(event.player)
								if not f.data.blacklist_tracker[player.get_player_scid(event.player)] and is_blacklist then
									add_to_blacklist(player_name, player.get_player_ip(event.player), player.get_player_scid(event.player), lang["Custom chat judge §"]..": \""..chat_judge_entry.."\"")
									f.data.blacklist_tracker[player.get_player_scid(event.player)] = true
								end
								if not f.data.timeout_tracker[player.get_player_scid(event.player)] and is_timeout then
									essentials.add_to_timeout(event.player)
									f.data.timeout_tracker[player.get_player_scid(event.player)] = true
								end
								if f.value == 0 then
									ped.clear_ped_tasks_immediately(player.get_player_ped(event.player))
									essentials.msg(lang["Chat judge:\\nRamming §"].." "..player_name.." "..lang["with explosive tankers §"], 140, settings.in_use["Chat judge #notifications#"])
									local time <const> = utils.time_ms() + 2000
									while time > utils.time_ms() and not entity.is_entity_dead(player.get_player_ped(event.player)) do
										essentials.use_ptfx_function(kek_entity.spawn_and_push_a_vehicle_in_direction, event.player, true, 8, gameplay.get_hash_key("tanker"))
										system.yield(250)
									end
								elseif f.value == 1 then
									local their_pid <const> = event.player
									for pid in essentials.players() do
										if pid ~= their_pid and not entity.is_entity_dead(player.get_player_ped(pid)) then
											ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
											system.yield(0)
											essentials.use_ptfx_function(fire.add_explosion, location_mapper.get_most_accurate_position(player.get_player_coords(pid)), 29, true, false, 0, player.get_player_ped(their_pid))
										end
									end
									essentials.msg(lang["Chat judge:\\nBlaming §"].." "..player_name.." "..lang["for killing session. §"], 140, settings.in_use["Chat judge #notifications#"])
								elseif f.value == 2 then
									essentials.msg(lang["Chat judge:\\nKicking §"].." "..player_name, 140, settings.in_use["Chat judge #notifications#"])
									globals.send_script_event("Netbail kick", event.player, {event.player, globals.generic_player_global(event.player)})
									globals.kick(event.player)
								elseif f.value == 3 then
									essentials.msg(lang["Chat judge\\nCrashing §"].." "..player_name, 140, settings.in_use["Chat judge #notifications#"])
									globals.script_event_crash(event.player)
								end
							end
							break
						end
					end
				end
			end)
		else
			event.remove_event_listener("chat", essentials.listeners["chat"]["judger"])
			essentials.listeners["chat"]["judger"] = nil
		end
	end)
	settings.valuei["Chat judge reaction"] = settings.toggle["Custom chat judger"]
	settings.valuei["Chat judge reaction"].data = {
		tracker = {},
		blacklist_tracker = {},
		timeout_tracker = {}
	}
	settings.valuei["Chat judge reaction"]:set_str_data({
		lang["Ram §"], 
		lang["Blame for killing session §"], 
		lang["Kick from session §"], 
		lang["Crash §"]
	})

	menu.add_feature(lang["Create new judger profile §"], "action", u.custom_chat_judger.id, function(f)
		local input, status
		while true do
			input, status = keys_and_input.get_input(lang["Type in the name of the profile. §"], input, 128, 0)
			if status == 2 then
				return
			end
			if input:find("..", 1, true) or input:find("%.$") then
				essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
				goto skip
			end
			if utils.file_exists(paths.kek_menu_stuff.."Chat judger profiles\\"..input..".ini") then
				essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
				goto skip
			end
			if input:find("[<>:\"/\\|%?%*]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
			else
				break
			end
			::skip::
			system.yield(0)
		end
		essentials.create_empty_file(paths.kek_menu_stuff.."Chat judger profiles\\"..input..".ini")
		create_judge_feat(input)
	end)

	menu.add_feature(lang["How to use §"], "action_value_str", u.custom_chat_judger.id, function(f)
		essentials.send_pattern_guide_msg(f.value, "Chat judger")
	end):set_str_data({
		lang["Part §"].." 1",
		lang["Part §"].." 2",
		lang["Part §"].." 3",
		lang["Part §"].." 4",
		lang["Part §"].." 5",
		lang["Part §"].." 6"
	})

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."Chat judger profiles", "ini")) do
		create_judge_feat(file_name)
	end
end

do
	local feat = menu.add_feature(lang["Chat spammer §"], "value_str", u.chat_spammer.id, function(f)
		while f.on do
			if f.value == 0 then
				essentials.send_message(settings.in_use["Spam text"])
			elseif f.value == 1 then
				essentials.send_message(essentials.get_random_string(1, 20))
			elseif f.value == 2 then
				local str <const> = settings.in_use["Spam text"]
				local value <const> = f.value
				for line in str:gmatch("([^\n]*)\n?") do
					essentials.send_message(line)
					f.data.wait(f)
					if settings.in_use["Spam text"] ~= str or f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			elseif f.value == 3 then
				essentials.send_message(utils.from_clipboard())
			elseif f.value == 4 then
				local str <const> = utils.from_clipboard()
				local value <const> = f.value
				for line in str:gmatch("([^\n]*)\n?") do
					essentials.send_message(line)
					f.data.wait(f)
					if utils.from_clipboard() ~= str or f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			elseif f.value == 5 then
				essentials.send_message(essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Spam text.txt", "*a"))
			elseif f.value == 6 then
				local value <const> = f.value
				for line in essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Spam text.txt", "*a"):gmatch("([^\n]*)\n?") do
					essentials.send_message(line)
					f.data.wait(f)
					if f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			elseif f.value == 7 then
				local strings <const> = {}
				local value <const> = f.value
				for line in essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Spam text.txt", "*a"):gmatch("([^\n]*)\n?") do
					strings[#strings + 1] = line
				end
				for i = 1, #strings do
					local num <const> = math.random(1, #strings)
					essentials.send_message(strings[num])
					table.remove(strings, num)
					f.data.wait(f)
					if f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			end
			f.data.wait(f)
		end
	end)
	feat.data = essentials.const({
		wait = function(...)
		local f <const> = ...
		local value <const> = f.value
		local spam_speed <const> = settings.valuei["Spam speed"].value
		local time <const> = utils.time_ms() + settings.valuei["Spam speed"].value
		repeat
			system.yield(0)
		until essentials.round(utils.time_ms() / gameplay.get_frame_time() * 1000) >= essentials.round(time / gameplay.get_frame_time() * 1000) or not f.on or value ~= f.value or spam_speed ~= settings.valuei["Spam speed"].value
	end})
	feat:set_str_data({
		lang["Spam text §"],
		lang["Random §"],
		lang["Send each line §"],
		lang["From clipboard §"],
		lang["From clipboard & send each line §"],
		lang["From file §"],
		lang["From file & send each line §"],
		lang["Random text from file §"]
	})
end

settings.valuei["Spam speed"] = menu.add_feature(lang["Spam speed, click to type §"], "action_value_i", u.chat_spammer.id, function(f)
	keys_and_input.input_value_i(f, lang["Type in chat spam speed §"])
end)
settings.valuei["Spam speed"].max, settings.valuei["Spam speed"].min, settings.valuei["Spam speed"].mod = 1000000, 100, 25

menu.add_feature(lang["Text to spam, type it in §"], "action", u.chat_spammer.id, function(f)
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in what to spam in chat §"], "", 128, 0)
	if status == 2 then
		return
	end
	settings.in_use["Spam text"] = input
end)

settings.toggle["Only friends can use chat commands"] = menu.add_feature(lang["Only friends can use commands §"], "toggle", u.chat_commands.id)

settings.toggle["Friends can't be targeted by chat commands"] = menu.add_feature(lang["Friends can't be targeted §"], "toggle", u.chat_commands.id)

settings.toggle["You can't be targeted"] = menu.add_feature(lang["You can't be targeted §"], "toggle", u.chat_commands.id)

settings.toggle["Chat commands"] = menu.add_feature(lang["Chat commands §"], "toggle", u.chat_commands.id, function(f)
	if f.on then
		essentials.listeners["chat"]["commands"] = event.add_event_listener("chat", function(event)
			if f.data.command_strings[(event.body:match("^%p(%w+)") or ""):lower()] and utils.time_ms() > (f.data.tracker[player.get_player_scid(event.player)] or 0) then
				f.data.tracker[player.get_player_scid(event.player)] = utils.time_ms() + 1000
				if player.is_player_modder(event.player, -1) then
					essentials.send_message("[Chat commands]: You can't use chat commands, "..player.get_player_name(event.player)..". You've been marked as a modder.", event.player == player.player_id())
					return
				end
				if f.data.player_chat_command_blacklist[player.get_player_scid(event.player)] then
					essentials.send_message("[Chat commands]: Your chat command access have been revoked, "..player.get_player_name(event.player)..".", event.player == player.player_id())
					return
				end
				if player.is_player_valid(event.player) and (not settings.toggle["Only friends can use chat commands"].on or network.is_scid_friend(player.get_player_scid(event.player)) or player.player_id() == event.player) then
					local str = event.body:lower()
					local found_player_pid
					local num = tonumber(str:match("%((%d+)%)") or 1)
					str = str:gsub("%("..num.."%)", "")
					str = str:gsub("[%[%]%(%)]", "")
					local pid
					local str2 <const> = str:match("^%p+%a+%s+([%p%w]+)")
					if str2 and not str:find("^%pteleport%s+[%w%p]+$") and not str:find("^%ptp%s+[%w%p]+$") and player.is_player_valid(essentials.name_to_pid(str2)) then
						pid = essentials.name_to_pid(str2)
						str = str:gsub("%s+"..essentials.remove_special(str2).."%s+", " ")
						str = str:gsub("%s+"..essentials.remove_special(str2).."$", " ")
						found_player_pid = true
					else
						pid = event.player
					end
					if settings.toggle["You can't be targeted"].on and player.player_id() == pid and event.player ~= player.player_id() then
						essentials.send_message("[Chat commands]: You can't use chat commands on this player.")
						return
					end
					if settings.toggle["Friends can't be targeted by chat commands"].on and event.player ~= pid and network.is_scid_friend(player.get_player_scid(pid)) and player.player_id() ~= event.player then
						essentials.send_message("[Chat commands]: You can't use chat commands on this player.")
						return
					end
					if f.on and player.is_player_valid(pid) then
						if settings.in_use["Spawn #chat command#"] and str:find("^%pspawn%s+.+") then
							if not kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
								essentials.send_message("[Chat commands]: Vehicle spawn limit is reached. Spawns are disabled.", event.player == player.player_id())
								return
							end
							local hash <const> = vehicle_mapper.get_hash_from_user_input(str:match("^%pspawn%s+(.*)"))
							if player.player_id() ~= event.player and num > 1 and essentials.get_index_of_value(f.data.hashes_not_allowed_to_spam, hash) then
								essentials.send_message("[Chat commands]: You're not allowed to spawn more than one of this vehicle at once.")
								return
							end
							if not streaming.is_model_a_vehicle(hash) then
								essentials.send_message("[Chat commands]: Invalid vehicle name.", event.player == player.player_id())
								return
							end
							if player.player_id() ~= event.player 
							and not network.is_scid_friend(player.get_player_scid(event.player))
							and settings.toggle["Vehicle blacklist"].on
							and vehicle_blacklist_settings[hash] ~= "Turned off" then
								essentials.send_message("[Chat commands]: This vehicle is blacklisted.", event.player == player.player_id())
								return
							end
							menu.create_thread(function()
								if num > 12 then
									essentials.send_message("[Chat commands]: You're not allowed to spawn more than 12 vehicles at once.", event.player == player.player_id())
									return
								end
								for i = 1, num do
									local Vehicle <const> = kek_entity.spawn_entity(hash, function() 
										return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 5)) + v3(0, 0, (i - 1) * 3), 0
									end, settings.toggle["Spawn #vehicle# in godmode"].on, settings.toggle["Spawn #vehicle# maxed"].on)
									if not entity.is_an_entity(Vehicle) then
										essentials.send_message("[Chat commands]: Vehicle spawn limit is reached. Spawns are disabled.", event.player == player.player_id())
										return
									end
								end
							end, nil)
						elseif settings.in_use["weapon #chat command#"] and str:find("^%pweapon%s+.+") then
							if str:find("^%pweapon%s+all$") then
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									weapon.remove_weapon_from_ped(player.get_player_ped(pid), weapon_hash)
									system.yield(0)
								end
								system.yield(0)
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									if not weapon.has_ped_got_weapon(player.get_player_ped(pid), weapon_hash) then
										weapon.give_delayed_weapon_to_ped(player.get_player_ped(pid), weapon_hash, 1, 0)
										system.yield(0)
										if pid == player.player_id() then 
											weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(pid), true, weapon_hash)
										end
									end
								end
							else
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									if (weapon.get_weapon_name(weapon_hash):gsub("%s", "")):lower() == (str:match("^%pweapon%s+(.+)"):gsub("%s", "")):lower() then
										if not weapon.has_ped_got_weapon(player.get_player_ped(pid), weapon_hash) then
											weapon.remove_weapon_from_ped(player.get_player_ped(pid), weapon_hash)
											system.yield(0)
											weapon.give_delayed_weapon_to_ped(player.get_player_ped(pid), weapon_hash, 1, 0)
											if pid == player.player_id() then 
												weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(pid), true, weapon_hash)
											end
											return
										end
									end
								end
								essentials.send_message("[Chat commands]: Invalid weapon name.", event.player == player.player_id())
							end
						elseif settings.in_use["removeweapon #chat command#"] and str:find("^%premoveweapon%s+.+") then
							if str:find("^%premoveweapon%s+all$") then
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									weapon.remove_weapon_from_ped(player.get_player_ped(pid), weapon_hash)
									system.yield(0)
								end
							else
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									if (weapon.get_weapon_name(weapon_hash):gsub("%s", "")):lower() == (str:match("^%premoveweapon%s+(.+)"):gsub("%s", "")):lower() then
										weapon.remove_weapon_from_ped(player.get_player_ped(pid), weapon_hash)
										break
									end
								end
							end
						elseif settings.in_use["Kill #chat command#"] and str:find("^%p+kill") and (pid ~= event.player or found_player_pid) then
							if player.is_player_god(pid) then
								essentials.send_message("[Chat commands] Failed to kill "..player.get_player_name(pid).."; He is in a property or in godmode.", event.player == player.player_id())
							else
								menu.create_thread(function()
									local blame
									if player.is_player_valid(essentials.name_to_pid(str:match("^%p+kill%s+([%w%p]+)$"))) then
										blame = essentials.name_to_pid(str:match("^%p+kill%s+([%w%p]+)$"))
									else
										blame = event.player
									end
									local time <const> = utils.time_ms() + 1200
									ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
									while not entity.is_entity_dead(player.get_player_ped(pid)) and time > utils.time_ms() do
										essentials.use_ptfx_function(fire.add_explosion, location_mapper.get_most_accurate_position(player.get_player_coords(pid)), 27, true, false, 0, player.get_player_ped(blame))
										system.yield(75)
									end
									local time <const> = utils.time_ms() + 5000
									while not entity.is_entity_dead(player.get_player_ped(pid)) and time > utils.time_ms() do
										essentials.use_ptfx_function(kek_entity.spawn_and_push_a_vehicle_in_direction, pid, true, 8, gameplay.get_hash_key("tanker"))
										system.yield(0)
									end
								end, nil)
							end
						elseif settings.in_use["neverwanted #chat command#"] and str:find("^%pneverwanted%s*$") then
							menu.get_player_feature(player_feat_ids["Never wanted"]).feats[pid]:toggle()
						elseif settings.in_use["Cage #chat command#"] and str:find("^%pcage%s*$") and (pid ~= event.player or found_player_pid) then
							local update <const> = kek_entity.entity_manager:update()
							if update.is_object_limit_not_breached and update.is_ped_limit_not_breached then
								menu.create_thread(function()
									local Ped <const> = kek_entity.create_cage(pid)
									if not entity.is_entity_a_ped(Ped) then
										essentials.send_message("[Chat commands]: Failed to spawn cage. Entity limits are reached.", event.player == player.player_id())
									end
								end, nil)
							else
								essentials.send_message("[Chat commands]: Failed to spawn cage. Entity limits are reached.", event.player == player.player_id())
							end
						elseif settings.in_use["Kick #chat command#"] and str:find("^%pkick%s*$") then
							if pid ~= player.player_id() and (pid ~= event.player or found_player_pid) and not network.is_scid_friend(player.get_player_scid(pid)) then
								menu.create_thread(function()
									globals.kick(pid)
								end, nil)
							end
						elseif settings.in_use["Crash #chat command#"] and str:find("^%pcrash%s*$") then
							if pid ~= player.player_id() and (pid ~= event.player or found_player_pid) and not network.is_scid_friend(player.get_player_scid(pid)) then
								menu.create_thread(function()
									globals.script_event_crash(pid)
								end, nil)
							end
						elseif settings.in_use["clowns #chat command#"] and str:find("^%pclowns%s*$") then
							if num > 5 and event.player ~= player.player_id() then
								essentials.send_message("[Chat commands]: You can't spawn more than 5 clowns at once.")
								return
							end
							if num > 15 then
								essentials.send_message("[Chat commands]: You can't spawn more than 15 clowns at once.", true)
								return
							end
							menu.create_thread(function()
								for i = 1, num do
									local clown <const> = troll_entity.send_clown_van(pid)
									if not entity.is_an_entity(clown) then
										essentials.send_message("[Chat commands]: Failed to spawn "..((num - i) + 1).."/"..num.." clowns. Entity limits were reached.", event.player == player.player_id())
										return
									end
								end
							end, nil)
						elseif settings.in_use["chopper #chat command#"] and str:find("^%pchopper%s*$") then
							if num > 5 and event.player ~= player.player_id() then
								essentials.send_message("[Chat commands]: You can't spawn more than 5 choppers at once.")
								return
							end
							if num > 15 then
								essentials.send_message("[Chat commands]: You can't spawn more than 15 choppers at once.", true)
								return
							end
							menu.create_thread(function()
								for i = 1, num do
									local chopper <const> = troll_entity.send_attack_chopper(pid)
									if not entity.is_an_entity(chopper) then
										essentials.send_message("[Chat commands]: Failed to spawn "..((num - i) + 1).."/"..num.." choppers. Entity limits were reached.", event.player == player.player_id())
										return
									end
								end
							end, nil)
						elseif settings.in_use["teleport #chat command#"] and (str:match("^%pteleport%s+([%w%p]+)") or str:match("^%ptp%s+([%w%p]+)")) then
							str = str:gsub("^%ptp%s+", "!teleport ")
							menu.create_thread(function()
								local pos
								if player.is_player_valid(essentials.name_to_pid(str:match("^%pteleport%s+([%p%w]+)"))) then
									pos = location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(essentials.name_to_pid(str:match("^%pteleport%s+([%p%w]+)"))), 8))
								end
								if pid ~= player.player_id() and not essentials.is_in_vehicle(pid) then
									essentials.send_message("[Chat commands]: Failed to teleport "..player.get_player_name(pid).."; he isn't in a vehicle.", event.player == player.player_id())
									return
								end
								if not pos and ((str:match("^%pteleport%s+([%w]+)%s*$") and str:match("^%pteleport%s+([%w]+)%s*$"):lower() == "waypoint") or (str:match("^%pteleport%s+([%w]+)%s*$") and str:match("^%pteleport%s+([%w]+)%s*$"):lower() == "wp")) then
									if math.abs(ui.get_waypoint_coord().x) < 16000 and math.abs(ui.get_waypoint_coord().x) > 10 and math.abs(ui.get_waypoint_coord().y) > 10 then
										pos = location_mapper.get_most_accurate_position(v3(ui.get_waypoint_coord().x, ui.get_waypoint_coord().y, -50), true)
									else
										essentials.send_message("[Chat commands]: No waypoint found.", event.player == player.player_id())
										return
									end
								end
								if not pos then
									local str <const> = str:match("^%pteleport%s+(.+)"):lower()
									for name, vector in pairs(location_mapper.GENERAL_POSITIONS) do
										if name:lower() == str then
											pos = vector
										end
									end
								end
								if not pos then
									local x <const> = tonumber(str:gsub(",", " "):match("^%pteleport%s+([%d%-%.]+)%s+[%d%-%.]+"))
									local y <const> = tonumber(str:gsub(",", " "):match("^%pteleport%s+[%d%-%.]+%s+([%d%-%.]+)"))
									local z <const> = tonumber(str:gsub(",", " "):match("^%pteleport%s+[%d%-%.]+%s+[%d%-%.]+%s+([%d%-%.]+)"))
									if x and y then
										if not z then
											pos = location_mapper.get_most_accurate_position(v3(x, y, -50), true)
										else
											pos = v3(x, y, z)
										end
									end
								end
								if type(pos) == "userdata" then
									if (pid == player.player_id() and not player.is_player_in_any_vehicle(player.player_id())) 
									or (player.get_player_vehicle(pid) == player.get_player_vehicle(player.player_id()) and player.is_player_in_any_vehicle(pid) and player.is_player_in_any_vehicle(player.player_id())) then
										kek_entity.teleport(essentials.get_most_relevant_entity(pid), pos)
									else
										menu.create_thread(function()
											kek_entity.teleport_player_and_vehicle_to_position(pid, pos, true)
										end, nil)
									end
								else
									essentials.send_message("[Chat commands]: Failed to find out where you wanted to teleport to.", event.player == player.player_id())
								end
							end, nil)
						elseif settings.in_use["apartmentinvite #chat command#"] and str:match("^%papartmentinvite%s+%d+$") then
							local num <const> = tonumber(str:match("^%papartmentinvite%s+(%d+)$"))
							if num and num > 0 and num <= 114 then
								globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, num, 1, 1, 1})
							end
						elseif settings.in_use["otr #chat command#"] and str:find("^%potr%s*$") then
							menu.get_player_feature(player_feat_ids["player otr"]).feats[pid]:toggle()
						elseif str:find("^%phelp%s*$") then
							if not admin_mapper.is_there_admin_in_session() then
								f.data.send_chat_commands()
							end
						end
					end
				end
			end
			system.yield(0)
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["commands"])
		essentials.listeners["chat"]["commands"] = nil
	end
end)

settings.toggle["Chat commands"].data = essentials.const({
	tracker = {},
	command_strings = {
		tp = true,
		help = true
	},
	player_chat_command_blacklist = {},
	hashes_not_allowed_to_spam = essentials.const({
		gameplay.get_hash_key("cargoplane"),
		gameplay.get_hash_key("jet"),
		gameplay.get_hash_key("kosatka"),
		gameplay.get_hash_key("cargobob"),
		gameplay.get_hash_key("cargobob2"),
		gameplay.get_hash_key("cargobob3"),
		gameplay.get_hash_key("cargobob4"),
		gameplay.get_hash_key("tug"),
		gameplay.get_hash_key("blimp"),
		gameplay.get_hash_key("blimp2"),
		gameplay.get_hash_key("blimp3"),
		gameplay.get_hash_key("bombushka"),
		gameplay.get_hash_key("volatol"),
		gameplay.get_hash_key("alkonost"),
		gameplay.get_hash_key("avenger"),
		gameplay.get_hash_key("avenger2"),
		gameplay.get_hash_key("titan")
	}),
	send_chat_commands = function()
		local str = "Chat Commands:\n"
		for i = 1, #settings.general do
			if settings.in_use[settings.general[i].setting_name] and settings.general[i].setting_name:find("#chat command#", 1, true) then
				str = str
				.."!"
				..settings.general[i].setting_name:lower():gsub("#chat command#", "")
				..(settings.general[i].alternative_command_info or "")
				.."<Player>"
				..(settings.general[i].extra_command_display or "")
				.."\n"
			end
			if #str > 205 then
				essentials.send_message(str)
				str = " "
			end
		end
		if #str > 210 then
			essentials.send_message(str)
			str = " "
		end
		str = str.."To show this again, do !help"
		essentials.send_message(str)
	end
})
for _, properties in pairs(settings.general) do
	if properties.setting_name:find("#chat command#", 1, true) then
		settings.toggle["Chat commands"].data.command_strings[properties.setting_name:lower():match("(%w+)%s+#chat command#")] = false
	end
end

menu.add_feature(lang["Send command list §"], "action", u.chat_commands.id, function()
	settings.toggle["Chat commands"].data.send_chat_commands()
end)

settings.toggle["Send command info"] = menu.add_feature(lang["Send command list every §"], "value_str", u.chat_commands.id, function(f)
	while f.on do
		local time <const> = utils.time_ms() + ((f.value + 1) * 60000)
		local value <const> = f.value
		while f.on and time > utils.time_ms() and utils.time_ms() > essentials.new_session_timer and f.value == value do
			system.yield(0)
		end
		if settings.toggle["Chat commands"].on and settings.toggle["Send command info"].on and value == f.value then
			while utils.time_ms() < essentials.new_session_timer and f.on do
				system.yield(0)
			end
			if not admin_mapper.is_there_admin_in_session() then
				settings.toggle["Chat commands"].data.send_chat_commands()
			end
		end
		system.yield(0)
	end
end)
do
	local str <const> = {
		lang["minute §"],
		"2nd "..lang["minute §"],
		"3rd "..lang["minute §"]
	}
	for i = 4, 120 do
		str[i] = i.."th "..lang["minute §"]
	end
	settings.toggle["Send command info"]:set_str_data(str)
end
settings.valuei["Help interval"] = settings.toggle["Send command info"]

u.chat_commands_parent = menu.add_feature(lang["Commands §"], "parent", u.chat_commands.id)
for _, properties in pairs(settings.general) do
	if properties.setting_name:find("#chat command#", 1, true) then
		settings.toggle[properties.setting_name] = menu.add_feature(properties.feature_name, "toggle", u.chat_commands_parent.id, function(f)
			settings.in_use[properties.setting_name] = f.on
			settings.toggle["Chat commands"].data.command_strings[properties.setting_name:lower():match("(%w+)%s+#chat command#")] = f.on
		end)
	end
end

settings.valuei["Echo delay"] = menu.add_feature(lang["Echo delay, click to type §"], "action_value_i", u.chat_spammer.id, function(f)
	keys_and_input.input_value_i(f, lang["Type in echo delay. §"])	
end)
settings.valuei["Echo delay"].max, settings.valuei["Echo delay"].min, settings.valuei["Echo delay"].mod = 20000, 0, 25

settings.toggle["Echo chat"] = menu.add_feature(lang["Echo chat §"], "toggle", u.chat_spammer.id, function(f)
	if f.on then
		essentials.listeners["chat"]["echo"] = event.add_event_listener("chat", function(event)
			if player.is_player_valid(event.player) 
			and player.player_id() ~= event.player 
			and essentials.is_not_friend(event.player) then
				for i = 1, settings.valuei["Echo delay"].value / 10 do
					if not f.on or settings.valuei["Echo delay"].value ~= settings.valuei["Echo delay"].value then
						break
					end
					system.yield(0)
				end
				essentials.send_message(event.body)
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["echo"])
		essentials.listeners["chat"]["echo"] = nil
	end
end)

do
	local function create_chatbot_feat(...)
		local name <const> = ...
		if name:find("..", 1, true) or name:find("%.$") or name ~= essentials.get_safe_feat_name(name) then
			return
		end
		menu.add_feature(essentials.get_safe_feat_name(name):gsub("%.ini$", ""), "action_value_str", u.chat_bot.id, function(f)
			if f.value == 0 then
				if not utils.file_exists(paths.home.."scripts\\kek_menu_stuff\\Chatbot profiles\\"..f.name..".ini") then
					essentials.msg(lang["Couldn't find file §"], 6, true)
				else
					local str <const> = essentials.get_file_string("scripts\\kek_menu_stuff\\Chatbot profiles\\"..f.name..".ini", "*a")
					local count = 1
					for chatbot_entry in str:gmatch("([^\n]*)\n?") do
						if not pcall(function()
							return str:find(chatbot_entry)
						end) then
							essentials.msg(lang["Failed to load profile. Error at line §"]..": "..count.."\nscripts\\kek_menu_stuff\\Chatbot profiles\\"..f.name..".ini", 6, true, 8)
							return
						end
						count = count + 1
					end
					essentials.msg(lang["Successfully loaded §"].." "..f.name, 210, true)
					local file <close> = io.open(paths.kek_menu_stuff.."kekMenuData\\Kek's chat bot.txt", "w+")
					file:write(str)
					file:flush()
					o.update_chat_bot = true
				end
			elseif f.value == 1 then
				local what_to_react_to = ""
				local status
				while true do
					what_to_react_to, status = keys_and_input.get_input(lang["Type in what the bot will react to. §"], what_to_react_to, 128, 0)
					if essentials.search_for_match_and_get_line("scripts\\kek_menu_stuff\\Chatbot profiles\\"..f.name..".ini", {"|"..what_to_react_to.."|"}) then
						essentials.msg(lang["Entry already exists in this profile. §"], 6, true, 6)
						goto skip 
					end
					if status == 2 then
						return
					end
					if not essentials.invalid_pattern(what_to_react_to, true, true) and not what_to_react_to:find("[¢|&]") then
						break
					elseif not essentials.invalid_pattern(what_to_react_to) then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"¢\", \"|\" & \"&\"", 6, true, 7)
					end
					::skip::
					system.yield(0)
				end
				local reaction <const> = {}
				local i = 1
				local str, status = ""
				while u.number_of_responses_from_chat_bot.value >= i do
					str, status = keys_and_input.get_input(lang["Type in what the bot will say to what you previously typed in. §"], str, 128, 0)
					if status == 2 then
						return
					end	
					if not str:find("[¢|&]") then
						reaction[#reaction + 1] = str
						i = i + 1
						str = ""
					else
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"¢\", \"|\" & \"&\"", 6, true, 7)
					end
					system.yield(0)
				end
				if #reaction == 0 then
					essentials.msg(lang["Too few reactions to add entry. §"], 6, true)
					return
				end
				essentials.log("scripts\\kek_menu_stuff\\Chatbot profiles\\"..f.name..".ini", "|"..what_to_react_to.."|&".."¢ "..table.concat(reaction, " ¢¢ ").." ¢".."&")
				essentials.msg(lang["Successfully added entry. §"], 210, true)
			elseif f.value == 2 then
				local what_to_remove <const>, status <const> = keys_and_input.get_input(lang["Type in what the text the bot reacts to in the entry you wish to remove. §"], "", 128, 0)
				if status == 2 then
					return
				end
				if essentials.remove_line_from_file_exact("scripts\\kek_menu_stuff\\Chatbot profiles\\"..f.name..".ini", "|"..what_to_remove.."|") then
					essentials.msg(lang["Removed entry. §"], 212, true)
				else 
					essentials.msg(lang["Couldn't find entry. §"], 6, true)
				end
			elseif f.value == 3 then
				if utils.file_exists(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini") then
					io.remove(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini")
				end
				f.hidden = true
			elseif f.value == 4 then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in the name of the profile. §"], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
						goto skip
					end
					if utils.file_exists(paths.kek_menu_stuff.."Chatbot profiles\\"..input..".ini") then
						essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
						goto skip
					end
					if input:find("[<>:\"/\\|%?%*]") then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
					else
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file("scripts\\kek_menu_stuff\\Chatbot profiles\\", f.name, input, "ini")
				f.name = input
			end
		end):set_str_data({
			lang["Load §"],
			lang["Add §"],
			lang["Remove §"],
			lang["Delete §"],
			lang["Change name §"]
		})
	end

	u.number_of_responses_from_chat_bot = menu.add_feature(lang["Number of responses §"], "action_value_i", u.chat_bot.id)
	u.number_of_responses_from_chat_bot.max = 100
	u.number_of_responses_from_chat_bot.min = 1
	u.number_of_responses_from_chat_bot.mod = 1
	u.number_of_responses_from_chat_bot.value = 1

	settings.valuei["chat bot delay"] = menu.add_feature(lang["Answer delay chatbot §"], "action_value_i", u.chat_bot.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in answer delay. §"])	
	end)
	settings.valuei["chat bot delay"].max, settings.valuei["chat bot delay"].min, settings.valuei["chat bot delay"].mod = 7200, 0, 20

	settings.valuei["Chance to reply"] = menu.add_feature(lang["Chance to reply §"].." %", "action_value_i", u.chat_bot.id)
	settings.valuei["Chance to reply"].min = 1
	settings.valuei["Chance to reply"].max = 100
	settings.valuei["Chance to reply"].mod = 1

	settings.toggle["chat bot"] = menu.add_feature(lang["Chat bot §"], "toggle", u.chat_bot.id, function(f)
		if f.on then
			local str = essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Kek's chat bot.txt", "*a")
			local line_num = 1
			for chatbot_entry in str:gmatch("([^\n]*)\n?") do
				if not pcall(function()
					return str:find(chatbot_entry)
				end) then
					essentials.msg("["..lang["Chat bot §"].."]: "..lang["Failed to load profile. Error at line §"]..": "..line_num.."\nscripts\\kek_menu_stuff\\kekMenuData\\Kek's chat bot.txt", 6, true, 12)
					str = ""
				end
				line_num = line_num + 1
			end
			essentials.listeners["chat"]["bot"] = event.add_event_listener("chat", function(event)
				if player.is_player_valid(event.player)
				and player.player_id() ~= event.player
				and math.random(1, 100) <= settings.valuei["Chance to reply"].value then
					system.yield(settings.valuei["chat bot delay"].value)
					if o.update_chat_bot then
						str = essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Kek's chat bot.txt", "*a")
						o.update_chat_bot = false
					end
					local count, response, found = 0, ""
					for chat_bot_entry in str:gmatch("([^\n]*)\n?") do
						if chat_bot_entry:match("|(.+)|&¢") then
							local temp_match_result, temp_count
							if #chat_bot_entry:gsub("%s", "") > 0 and event.body:lower():find(chat_bot_entry:lower():match("|(.+)|&¢")) then
								temp_match_result, temp_count = event.body:lower():find(chat_bot_entry:lower():match("|(.+)|&¢"))
							end
							if temp_match_result and temp_count > count then
								count = temp_count
								response = chat_bot_entry
								found = temp_match_result
							end
						end
					end
					if found then
						local temp <const> = {}
						for entry in response:gmatch("¢ (.-) ¢") do
							temp[#temp + 1] = entry
						end
						local str = temp[math.random(math.min(1, #temp), #temp)]
						if player.is_player_valid(event.player) then
							str = str:gsub("%[PLAYER_NAME%]", player.get_player_name(event.player))
							str = str:gsub("%[MY_NAME%]", player.get_player_name(player.player_id()))
							str = str:gsub("%[RANDOM_NAME%]", function()
								return player.get_player_name(essentials.get_random_player_except({player.player_id()}))
							end)
							essentials.send_message(str)
						end
					end
				end
			end)
		else
			event.remove_event_listener("chat", essentials.listeners["chat"]["bot"])
			essentials.listeners["chat"]["bot"] = nil
		end
	end) 

	menu.add_feature(lang["Create new chatbot profile §"], "action", u.chat_bot.id, function(f)
		local input, status
		while true do
			input, status = keys_and_input.get_input(lang["Type in the name of the profile. §"], input, 128, 0)
			if status == 2 then
				return
			end
			if input:find("..", 1, true) or input:find("%.$") then
				essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
				goto skip
			end
			if utils.file_exists(paths.kek_menu_stuff.."Chatbot profiles\\"..input..".ini") then
				essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
				goto skip
			end
			if input:find("[<>:\"/\\|%?%*]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
			else
				break
			end
			::skip::
			system.yield(0)
		end
		essentials.create_empty_file(paths.kek_menu_stuff.."Chatbot profiles\\"..input..".ini")
		create_chatbot_feat(input)
	end)

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."Chatbot profiles", "ini")) do
		create_chatbot_feat(file_name)
	end

	menu.add_feature(lang["How to use §"], "action_value_str", u.chat_bot.id, function(f)
		essentials.send_pattern_guide_msg(f.value, "Chatbot")
	end):set_str_data({
		lang["Part §"].." 1",
		lang["Part §"].." 2",
		lang["Part §"].." 3",
		lang["Part §"].." 4",
		lang["Part §"].." 5"
	})
end

settings.toggle["Clever bot"] = menu.add_feature(lang["Log chat & use as chatbot §"], "toggle", u.chat_bot.id, function(f)
	if f.on then
		local data <const> = {}
		local index = ""
		for line in essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Clever bot.ini", "*a"):gmatch("([^\n]*)\n?") do
			if line:find("§|§", 1, true) then
				index = line:match("(.*)§|§")
				data[index] = {}
			elseif line:match("	(.+)") then
				data[index][#data[index] + 1] = line:match("	(.+)")
			end
		end
		local last_response
		essentials.listeners["chat"]["Clever bot"] = event.add_event_listener("chat", function(event)
			if (not f.data[player.get_player_scid(event.player)] or utils.time_ms() > f.data[player.get_player_scid(event.player)]) 
			and math.random(1, 100) <= settings.valuei["Chance to reply"].value then
				system.yield(settings.valuei["chat bot delay"].value)
				f.data[player.get_player_scid(event.player)] = utils.time_ms() + 1000
				if data[event.body] and event.player ~= player.player_id() then
					essentials.send_message(data[event.body][math.random(1, #data[event.body])])
				end
				if not event.body:find("^%p") and not event.body:lower():find("[Chat commands]", 1, true) and not essentials.contains_advert(event.body) then
					if last_response then
						if data[last_response] then
							for i = 1, #data[last_response] do
								if data[last_response][i] == event.body then
									return
								end
							end
							data[last_response][#data[last_response] + 1] = event.body
						else
							data[last_response] = {event.body}
						end
						local file <close> = io.open(paths.kek_menu_stuff.."kekMenuData\\Clever bot.ini", "w+")
						for statement, responses in pairs(data) do
							file:write(statement.."§|§\n")
							for i = 1, #responses do
								file:write("	"..responses[i].."\n")
							end
						end
						file:flush()
					end
					last_response = event.body
				end
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["Clever bot"])
		essentials.listeners["chat"]["Clever bot"] = nil
	end
end)
settings.toggle["Clever bot"].data = {}

settings.toggle["Auto tp to waypoint"] = menu.add_feature(lang["Auto tp to waypoint §"], "toggle", u.self_options.id, function(f)
	while f.on do
		system.yield(0)
		if math.abs(ui.get_waypoint_coord().x) < 16000 and math.abs(ui.get_waypoint_coord().x) > 10 and math.abs(ui.get_waypoint_coord().y) > 10 then
			local pos <const> = ui.get_waypoint_coord()
			ui.set_waypoint_off()
			for i = 1, 2 do
				kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), location_mapper.get_most_accurate_position(v3(pos.x, pos.y, -50)))
				system.yield(0)
			end
		end
	end
end)

settings.toggle["Tp to player while spectating"] = menu.add_feature(lang["Teleport to player when spectating §"], "toggle", u.self_options.id, function(f)
	local initial_pos = player.get_player_coords(player.player_id())
	while f.on do
		local pos <const> = player.get_player_coords(player.player_id())
		if pos.z < 2275 or pos.z > 2325 then
			initial_pos = pos
		end
		while network.get_player_player_is_spectating(player.player_id()) and f.on do
			local pos <const> = player.get_player_coords(network.get_player_player_is_spectating(player.player_id()))
			kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), v3(pos.x, pos.y, 2300))
			system.yield(0)
			if not network.get_player_player_is_spectating(player.player_id()) then
				kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
				break
			end
		end
		system.yield(0)
	end
	kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
end)

local function display_settings(...)
	local parent <const>,
	name_of_feature <const>,
	x <const>,
	y <const>,
	scale <const>,
	max_scale <const>,
	stretch <const> = ...

	if stretch then
		settings.valuei[name_of_feature.." stretch"] = menu.add_feature(lang["Stretch §"], "action_value_f", parent.id, function(f)
			keys_and_input.input_value_i(f, lang["Type in stretch §"], 5)
		end)
		settings.valuei[name_of_feature.." stretch"].min = 0.2
		settings.valuei[name_of_feature.." stretch"].max = 250
		settings.valuei[name_of_feature.." stretch"].mod = 0.2
		settings.add_setting({
			setting_name = name_of_feature.." stretch", 
			setting = 35
		})
	end
	settings.valuei[name_of_feature.." X"] = menu.add_feature("X", "action_value_i", parent.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in where horizontally the time is displayed. §"])
	end)
	settings.valuei[name_of_feature.." X"].min = 0
	settings.valuei[name_of_feature.." X"].max = 2000
	settings.valuei[name_of_feature.." X"].mod = 10
	settings.add_setting({
		setting_name = name_of_feature.." X", 
		setting = x
	})

	settings.valuei[name_of_feature.." Y"] = menu.add_feature("Y", "action_value_i", parent.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in where vertically the time is displayed. §"])
	end)
	settings.valuei[name_of_feature.." Y"].min = 0
	settings.valuei[name_of_feature.." Y"].max = 2000
	settings.valuei[name_of_feature.." Y"].mod = 10
	settings.add_setting({
		setting_name = name_of_feature.." Y", 
		setting = y
	})

	settings.valuei[name_of_feature.." font"] = menu.add_feature(lang["Font §"], "action_value_i", parent.id)
	settings.valuei[name_of_feature.." font"].min = 0
	settings.valuei[name_of_feature.." font"].max = 8
	settings.valuei[name_of_feature.." font"].mod = 1
	settings.add_setting({
		setting_name = name_of_feature.." font", 
		setting = 1
	})

	settings.toggle[name_of_feature.." outline"] = menu.add_feature(lang["Outline §"], "toggle", parent.id)
	settings.add_setting({
		setting_name = name_of_feature.." outline", 
		setting = true
	})

	settings.valuei[name_of_feature.." R"] = menu.add_feature("R", "action_value_i", parent.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in RGB §"]..": R")
	end)
	settings.valuei[name_of_feature.." R"].min = 0
	settings.valuei[name_of_feature.." R"].max = 255
	settings.valuei[name_of_feature.." R"].mod = 5
	settings.add_setting({
		setting_name = name_of_feature.." R", 
		setting = 255
	})

	settings.valuei[name_of_feature.." G"] = menu.add_feature("G", "action_value_i", parent.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in RGB §"]..": G")
	end)
	settings.valuei[name_of_feature.." G"].min = 0
	settings.valuei[name_of_feature.." G"].max = 255
	settings.valuei[name_of_feature.." G"].mod = 5
	settings.add_setting({
		setting_name = name_of_feature.." G", 
		setting = 100
	})

	settings.valuei[name_of_feature.." B"] = menu.add_feature("B", "action_value_i", parent.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in RGB §"]..": B")
	end)
	settings.valuei[name_of_feature.." B"].min = 0
	settings.valuei[name_of_feature.." B"].max = 255
	settings.valuei[name_of_feature.." B"].mod = 5
	settings.add_setting({
		setting_name = name_of_feature.." B", 
		setting = 255
	})

	settings.valuei[name_of_feature.." scale"] = menu.add_feature(lang["Size §"], "action_slider", parent.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in the size of the text. §"])
	end)
	settings.valuei[name_of_feature.." scale"].min = 0
	settings.valuei[name_of_feature.." scale"].max = max_scale
	settings.valuei[name_of_feature.." scale"].mod = 1
	settings.add_setting({
		setting_name = name_of_feature.." scale", 
		setting = scale
	})

	settings.valuei[name_of_feature.." A"] = menu.add_feature(lang["Opacity §"], "action_slider", parent.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in RGB opacity §"])
	end)
	settings.valuei[name_of_feature.." A"].min = 0
	settings.valuei[name_of_feature.." A"].max = 255
	settings.valuei[name_of_feature.." A"].mod = 5
	settings.add_setting({
		setting_name = name_of_feature.." A", 
		setting = 255
	})
end

u.display_notifications = menu.add_feature(lang["Display notifications §"], "parent", u.self_options.id)
settings.toggle["Display 2take1 notifications"] = menu.add_feature(lang["Display 2take1 notifications on screen §"], "toggle", u.display_notifications.id, function(f)
	if not utils.file_exists(paths.home.."notification.log") then
		essentials.create_empty_file(paths.home.."notification.log")
	end
	local file, strings
	f.data.is_on = true
	while f.on do
		if f.data.is_on then
			strings = {}
			if io.type(file) == "file" then
				file:close()
			end
			file = io.open(paths.home.."notification.log")
			for line in file:read("*a"):reverse():gmatch("([^\n]*)\n?") do
				line = line:reverse()
				if line:find("[%w%p]") and not f.data.filter(line, f) then
					strings[#strings + 1] = line
				end
				if #strings == settings.valuei["Number of notifications to display"].max then
					break
				end
			end
			local temp <const> = {}
			for i = 1, #strings do
				temp[i] = strings[(#strings + 1) - i]
			end
			strings = temp
			f.data.is_on = false
		end
		local str <const> = file:read("*l")
		if str and str:find("[%w%p]") and not f.data.filter(str, f) then
			if #strings >= settings.valuei["Number of notifications to display"].max then
				table.remove(strings, 1)
			end
			strings[#strings + 1] = str
		end
		local i = 0
		for i2 = math.max(1, #strings - settings.valuei["Number of notifications to display"].value + 1), #strings do
			ui.set_text_color(settings.valuei["Display 2take1 notifications R"].value, settings.valuei["Display 2take1 notifications G"].value, settings.valuei["Display 2take1 notifications B"].value, settings.valuei["Display 2take1 notifications A"].value)
			ui.set_text_scale(settings.valuei["Display 2take1 notifications scale"].value / 30)
			ui.set_text_font(settings.valuei["Display 2take1 notifications font"].value)
			ui.set_text_outline(settings.toggle["Display 2take1 notifications outline"].on)
			ui.draw_text(strings[i2], v2(settings.valuei["Display 2take1 notifications X"].value / 2000, (settings.valuei["Display 2take1 notifications Y"].value + (i * settings.valuei["Display 2take1 notifications stretch"].value)) / 2000))
			i = i + 1
		end
		system.yield(0)
	end
	file:close()
end)
settings.toggle["Display 2take1 notifications"].data = {
	is_on = true,
	blacklisted_strings = essentials.const({
		"stack traceback",
		"LUA state has been reset",
		"\\",
		"] [Kek's ",
		"Error executing",
		"has been executed.",
		"Failed to load",
		"Kek's menu is already loaded!",
		"[C]",
		"MoistScript",
		"2Take1Script",
		"2T1Script Revive",
		"ZeroMenu"
	}),
	whitelisted_strings = essentials.const({
		lang["is in godmode. §"],
		lang["Recognized §"],
		lang["has a modded name. §"]				
	}),
	filter = function(...)
		local str <const>, feat <const> = ...
		if settings.toggle["Display notify filter"].on then
			for i = 1, #feat.data.whitelisted_strings do
				if str:find(feat.data.whitelisted_strings[i], 1, true) then
					return false
				end
			end
			if not str:find("^%[202%d%-%d%d%-%d%d") and not str:find(":", 1, true) then
				return true
			end
			for i = 1, #feat.data.blacklisted_strings do
				if str:find(feat.data.blacklisted_strings[i], 1, true) then
					return true
				end
			end
		end
	end
}
settings.valuei["Number of notifications to display"] = menu.add_feature(lang["Number of notifications §"], "action_value_i", u.display_notifications.id)
settings.valuei["Number of notifications to display"].max = 100
settings.valuei["Number of notifications to display"].min = 1
settings.valuei["Number of notifications to display"].mod = 1

settings.toggle["Log 2take1 notifications to console"] = menu.add_feature(lang["Log to console §"], "toggle", u.display_notifications.id, function(f)
	local file <close> = io.open(paths.home.."notification.log")
	file:read("*a")
	while f.on do
		local str <const> = file:read("*l")
		if str then
			print(str)
		end
		system.yield(0)
	end
end)

settings.toggle["Display notify filter"] = menu.add_feature(lang["Filter §"], "toggle", u.display_notifications.id, function()
	settings.toggle["Display 2take1 notifications"].data.is_on = true
end)

display_settings(u.display_notifications, "Display 2take1 notifications", 1560, 40, 9, 25, true)

u.display_time = menu.add_feature(lang["Display time §"], "parent", u.self_options.id)
settings.toggle["Time OSD"] = menu.add_feature(lang["Display time §"], "toggle", u.display_time.id, function(f)
	while f.on do
		ui.set_text_color(settings.valuei["Time OSD R"].value, settings.valuei["Time OSD G"].value, settings.valuei["Time OSD B"].value, settings.valuei["Time OSD A"].value)
		ui.set_text_scale(settings.valuei["Time OSD scale"].value / 30)
		ui.set_text_font(settings.valuei["Time OSD font"].value)
		ui.set_text_outline(settings.toggle["Time OSD outline"].on)
		ui.draw_text(os.date(), v2(settings.valuei["Time OSD X"].value / 2000, settings.valuei["Time OSD Y"].value / 2000))
		system.yield(0)
	end
end)
display_settings(u.display_time, "Time OSD", 0, 0, 15, 50)

u.force_field = menu.add_feature(lang["Force field §"], "parent", u.self_options.id)

menu.add_feature(lang["Force field §"], "value_str", u.force_field.id, function(f)
	if f.on then
		local pos = v3()
		menu.create_thread(function()
			while f.on do
				if settings.toggle["Force field sphere"].on then
					graphics.draw_marker(28, pos, v3(0, 90, 0), v3(0, 90, 0), v3(u.force_field_radius.value, u.force_field_radius.value, u.force_field_radius.value), 0, 255, 0, 35, false, false, 2, false, nil, "MarkerTypeDebugSphere", false)
				end
				system.yield(0)
			end
		end, nil)
		local vehicles, peds
		while f.on do
			system.yield(0)
			vehicles, peds = {}, {}
			if u.force_field_entity_type.value == 0 or u.force_field_entity_type.value == 2 then
				vehicles = vehicle.get_all_vehicles()
				local index_of_my_vehicle = essentials.get_index_of_value(vehicles, player.get_player_vehicle(player.player_id()))
				if index_of_my_vehicle then
					table.remove(vehicles, index_of_my_vehicle)
				end
			end
			if u.force_field_entity_type.value == 1 or u.force_field_entity_type.value == 2 then
				peds = kek_entity.remove_player_entities(ped.get_all_peds())
			end
			local entities = {}
			if u.exclude_from_force_field.value == 0 or u.exclude_from_force_field.value == 1 then
				for _, Entity in pairs(essentials.merge_tables(vehicles, {peds})) do
					local is_player_in_vehicle , is_friend_in_vehicle = false, false
					if entity.is_entity_a_vehicle(Entity) then
						is_player_in_vehicle , is_friend_in_vehicle = kek_entity.is_player_in_vehicle(Entity)
					end
					if (u.exclude_from_force_field.value == 0 and not is_friend_in_vehicle and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity) or not network.is_scid_friend(player.get_player_scid(player.get_player_from_ped(Entity)))))
					or (u.exclude_from_force_field.value == 1 and not is_player_in_vehicle) then
						entities[#entities + 1] = Entity
					end
				end
			else
				entities = essentials.merge_tables(vehicles, {peds})
			end
			for _, Entity in pairs(entities) do
				pos = player.get_player_coords(player.player_id()) + v3(u.force_field_offset_x.value, u.force_field_offset_y.value, u.force_field_offset_z.value)
				if essentials.get_distance_between(pos, Entity) < u.force_field_radius.value and kek_entity.get_control_of_entity(Entity, 0) then
					if f.value == 0 then
						entity.set_entity_velocity(Entity, (entity.get_entity_coords(Entity) - pos) * (u.strength_away.value / essentials.get_distance_between(pos, Entity)))
					elseif f.value == 1 then
						if essentials.get_distance_between(pos, Entity) > 20 then
							entity.set_entity_velocity(Entity, (pos - entity.get_entity_coords(Entity)) * (u.strength_towards.value / essentials.get_distance_between(pos, Entity)))
						else
							entity.set_entity_velocity(Entity, (entity.get_entity_coords(Entity) - pos) * (u.strength_towards.value / essentials.get_distance_between(pos, Entity)))
						end
					end
				end
			end
		end
		for _, Entity in pairs(essentials.merge_tables(vehicles, {peds})) do
			if essentials.get_distance_between(player.get_player_coords(player.player_id()) + v3(u.force_field_offset_x.value, u.force_field_offset_y.value, u.force_field_offset_z.value), Entity) < u.force_field_radius.value 
			and kek_entity.get_control_of_entity(Entity, 0) then
				entity.set_entity_velocity(Entity, v3())
			end
		end
	end
end):set_str_data({
	lang["Away from you §"],
	lang["Towards you §"]
})

settings.toggle["Force field sphere"] = menu.add_feature(lang["Show sphere §"], "toggle", u.force_field.id)

u.force_field_radius = menu.add_feature(lang["Force field radius §"], "action_slider", u.force_field.id)
u.force_field_radius.max = 225
u.force_field_radius.min = 7.5
u.force_field_radius.mod = 7.5
u.force_field_radius.value = 22.5

u.strength_towards = menu.add_feature(lang["Strength towards you §"], "action_slider", u.force_field.id)
u.strength_towards.max = 100
u.strength_towards.min = 2.5
u.strength_towards.mod = 2.5
u.strength_towards.value = 10

u.strength_away = menu.add_feature(lang["Strength away from you §"], "action_slider", u.force_field.id)
u.strength_away.max = 100
u.strength_away.min = 2.5
u.strength_away.mod = 2.5
u.strength_away.value = 10

u.exclude_from_force_field = menu.add_feature(lang["Exclude §"], "action_value_str", u.force_field.id)
u.exclude_from_force_field:set_str_data({
	lang["friends §"],
	lang["players §"],
	lang["no one §"]
})

u.force_field_entity_type = menu.add_feature(lang["Entities §"], "action_value_str", u.force_field.id)
u.force_field_entity_type:set_str_data({
	lang["Vehicles §"], 
	lang["Peds §"], 
	lang["Peds & vehicles §"]
})

u.force_field_offset_x = menu.add_feature(lang["Offset §"].." x", "action_value_i", u.force_field.id)
u.force_field_offset_x.max = 100
u.force_field_offset_x.min = -100
u.force_field_offset_x.mod = 2
u.force_field_offset_x.value = 0

u.force_field_offset_y = menu.add_feature(lang["Offset §"].." y", "action_value_i", u.force_field.id)
u.force_field_offset_y.max = 100
u.force_field_offset_y.min = -100
u.force_field_offset_y.mod = 2
u.force_field_offset_y.value = 0

u.force_field_offset_z = menu.add_feature(lang["Offset §"].." z", "action_value_i", u.force_field.id)
u.force_field_offset_z.max = 100
u.force_field_offset_z.min = -100
u.force_field_offset_z.mod = 2
u.force_field_offset_z.value = 0

if not utils.dir_exists(paths.home.."scripts\\Menyoo Vehicles") then
	utils.make_dir(paths.home.."scripts\\Menyoo Vehicles")
end
local function create_custom_vehicle_feature(...)
	local name <const> = ...
	if name:find("..", 1, true) or name:find("%.$") or name ~= essentials.get_safe_feat_name(name) then
		return
	end
	local feat = menu.add_feature(essentials.get_safe_feat_name(name), "action_value_str", u.saved_custom_vehicles.id, function(f)
		if f.value == 0 then
			if settings.toggle["Delete old #vehicle#"].on then
				for _, Vehicle in pairs(kek_entity.user_vehicles) do
					kek_entity.hard_remove_entity_and_its_attachments(Vehicle)
				end
			end
			local Entity <const> = menyoo.spawn_custom_vehicle(paths.home.."scripts\\Menyoo Vehicles\\"..f.name..".xml", player.player_id())
			kek_entity.vehicle_preferences(Entity, true)
			kek_entity.user_vehicles[#kek_entity.user_vehicles + 1] = Entity
		elseif f.value == 1 then
			if utils.file_exists(paths.home.."scripts\\Menyoo Vehicles\\"..f.name..".xml") then
				io.remove(paths.home.."scripts\\Menyoo Vehicles\\"..f.name..".xml")
			end
			f.name = ";:~"
			f.hidden = true 
		elseif f.value == 2 then
			local input, status = f.name
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of menyoo vehicle. §"], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
					goto skip
				end
				if utils.file_exists(paths.home.."scripts\\Menyoo Vehicles\\"..input..".xml") then
					essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			essentials.rename_file("scripts\\Menyoo Vehicles\\", f.name, input, "xml")
			f.name = input
		end
	end)
	feat.data = "MENYOO"
	feat:set_str_data({
		lang["Spawn §"],
		lang["Delete §"],
		lang["Change name §"]
	})
end
u.saved_custom_vehicles = menu.add_feature(lang["Menyoo vehicles §"], "parent", u.gvehicle.id)

do
	local main_feat <const> = menu.add_feature(lang["Menyoo vehicles §"], "action_value_str", u.saved_custom_vehicles.id, function(f)
		if f.value == 0 then
			local input, status <const> = keys_and_input.get_input(lang["Type in name of menyoo vehicle. §"], "", 128, 0)
			if status == 2 then
				return
			end
			input = input:lower()
			for _, feature in pairs(u.saved_custom_vehicles.children) do
				if feature.data == "MENYOO" then
					feature.hidden = feature.name:lower():find(input, 1, true) == nil
				end
			end
		elseif f.value == 1 then
			if not entity.is_an_entity(player.get_player_vehicle(player.player_id())) then
				essentials.msg(lang["Found no vehicle to save. §"], 6, true)
				return
			end
			local input, status
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of menyoo vehicle. §"], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
					goto skip
				end
				if utils.file_exists(paths.home.."scripts\\Menyoo Vehicles\\"..input..".xml") then
					essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			vehicle_saver.save_vehicle(player.get_player_vehicle(player.player_id()), paths.home.."scripts\\Menyoo Vehicles\\"..input..".xml")
			create_custom_vehicle_feature(input)
		elseif f.value == 2 then
			local feats <const> = {}
			for _, feat in pairs(u.saved_custom_vehicles.children) do
				if not feat.hidden 
				and feat.data ~= "MENYOO" 
				and feat.data ~= "MAIN_FEAT" 
				and not utils.file_exists(paths.home.."scripts\\Menyoo Vehicles\\"..feat.name..".xml") then
					essentials.delete_feature(feat.id)
				elseif feat.data == "MENYOO" then
					feats[#feats + 1] = feat
				end
			end
			for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\Menyoo Vehicles", "xml")) do
				if essentials.is_all_true(feats, function(feat)
					return feat.name ~= file_name:gsub("%.xml$", "")
				end) then
					create_custom_vehicle_feature(file_name:gsub("%.xml$", ""))
				end
			end
		end
	end)
	main_feat:set_str_data({
		lang["Search §"],
		lang["Save §"],
		lang["Refresh list §"]
	})
	main_feat.data = "MAIN_FEAT"

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\Menyoo Vehicles", "xml")) do
		create_custom_vehicle_feature(file_name:gsub("%.xml$", ""))
	end
end

do
	if not utils.dir_exists(paths.home.."scripts\\Menyoo Maps") then
		utils.make_dir(paths.home.."scripts\\Menyoo Maps")
	end
	if not utils.dir_exists(paths.home.."scripts\\Race ghosts") then
		utils.make_dir(paths.home.."scripts\\Race ghosts")
	end
	local custom_maps_parent <const> = menu.add_feature(lang["Menyoo maps §"], "parent", u.self_options.id)
	local race_ghost_parent <const> = menu.add_feature(lang["Race ghosts §"], "parent", u.self_options.id)

	local function create_ghost_racer_feature(...)
		local name <const> = ...
		if name:find("..", 1, true) or name:find("%.$") or name ~= essentials.get_safe_feat_name(name) then
			return
		end
		local feat <const> = menu.add_feature(essentials.get_safe_feat_name(name), "action_value_str", race_ghost_parent.id, function(f)
			if f.value == 0 then
				if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..f.name..".lua") then
					local properties = loadfile(paths.home.."scripts\\Race ghosts\\"..f.name..".lua")
					local hash
					if not pcall(function()
						hash, properties = properties()
					end) or not streaming.is_model_valid(math.tointeger(hash) or 0) or type(properties) ~= "table" or #properties < 5 then
						essentials.msg(lang["Failed to load file. §"], 6, true)
						return
					end
					local Vehicle <const> = kek_entity.spawn_entity(math.tointeger(hash), function()
						return properties[1].pos, 0 
					end, true, true, nil, false, 1, nil, true)
					f.data.vehicle = Vehicle
					f.data.number_of_laps[Vehicle] = 0
					entity.set_entity_alpha(Vehicle, 180, true)
					entity.set_entity_collision(Vehicle, false, true, true)
					f.data.number_of_racers = f.data.number_of_racers + 1
					f.data.id[Vehicle] = f.data.number_of_racers
					kek_entity.set_blip(Vehicle, 56, math.min(f.data.number_of_racers, 84))
					menu.create_thread(function()
						while f.data.status ~= "STOP" do
							system.yield(0)
							local i = 2
							if f.data.number_of_laps[Vehicle] > 0 and #properties > 1000 then
								for i2 = 2, #properties do
									if properties[i2].time > 2 then
										i = i2
										break
									end
								end
							end
							local time = properties[i].time
							while #properties >= i do
								if not properties[i] then
									break
								end
								while time > properties[i].time do
									i = i + 1
									if not properties[i] then
										goto exit
									end
								end
								local new_pos = v3(properties[i - 1].pos.x, properties[i - 1].pos.y, properties[i - 1].pos.z)
								if essentials.round((properties[i].time - time) / gameplay.get_frame_time()) > 1 then
									while essentials.round((properties[i].time - time) / gameplay.get_frame_time()) > 1 do
										entity.set_entity_rotation(Vehicle, properties[i].rot)
										new_pos = new_pos + ((properties[i].pos - properties[i - 1].pos) / essentials.round((properties[i].time - time) / gameplay.get_frame_time()))
										entity.set_entity_coords_no_offset(Vehicle, new_pos)
										system.yield(0)
										time = time + gameplay.get_frame_time()
										if f.data.status == "STOP" or not entity.is_an_entity(Vehicle) then
											goto complete_exit
										end
									end
								else
									entity.set_entity_rotation(Vehicle, properties[i].rot)
									entity.set_entity_coords_no_offset(Vehicle, properties[i].pos)
									system.yield(0)
									time = time + gameplay.get_frame_time()
								end
								i = i + 1
								if f.data.status == "STOP" or not entity.is_an_entity(Vehicle) then
									goto complete_exit
								end
							end
							::exit::
							f.data.number_of_laps[Vehicle] = f.data.number_of_laps[Vehicle] + 1
							essentials.msg("["..lang["Race ghosts §"].."]: "..f.name.." "..f.data.id[Vehicle].." "..lang["has finished lap §"].." "..f.data.number_of_laps[Vehicle]..".", 6, true, 6)
						end
						::complete_exit::
						f.data.number_of_racers = f.data.number_of_racers - 1
						if f.data.number_of_racers == 0 then
							f.data.status = nil
						end
						f.data.number_of_laps[Vehicle] = nil
						f.data.id[Vehicle] = nil
						kek_entity.clear_entities({Vehicle})
					end, nil)
				end
			elseif f.value == 1 then
				local properties = loadfile(paths.home.."scripts\\Race ghosts\\"..f.name..".lua")
				local hash
				if not pcall(function()
					hash, properties = properties()
				end) or not streaming.is_model_valid(math.tointeger(hash) or 0) or type(properties) ~= "table" then
					essentials.msg(lang["Failed to load file. §"], 6, true)
					return
				end
				kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), properties[1].pos)
				entity.set_entity_rotation(essentials.get_most_relevant_entity(player.player_id()), properties[1].rot)
			elseif f.value == 2 then
				f.data.status = "STOP"
			elseif f.value == 3 then
				ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), f.data.vehicle, enums.vehicle_seats.driver)
			elseif f.value == 4 then
				f.data.status = "STOP"
				if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..f.name..".lua") then
					io.remove(paths.home.."scripts\\Race ghosts\\"..f.name..".lua")
				end
				f.name = ";:~"
				f.hidden = true
			elseif f.value == 5 then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in name of race ghost. §"], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
						goto skip
					end
					if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..input..".lua") then
						essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
						goto skip
					end
					if input:find("[<>:\"/\\|%?%*]") then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
					else
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file("scripts\\Race ghosts\\", f.name, input, "lua")
				f.name = input
			end
		end)
		feat:set_str_data({
			lang["Load §"],
			lang["Teleport to start §"],
			lang["Unload §"],
			lang["Set yourself in seat §"],
			lang["Delete §"],
			lang["Change name §"]
		})
		feat.data = {
			number_of_racers = 0,
			vehicle = 0,
			number_of_laps = {},
			id = {}
		}
	end

	local record_race <const> = menu.add_feature(lang["Record race §"], "toggle", race_ghost_parent.id, function(f)
		if player.is_player_in_any_vehicle(player.player_id()) then
			if utils.file_exists(paths.home.."scripts\\kek_menu_stuff\\kekMenuData\\Temp recorded race.lua") then
				essentials.msg(lang["Cleared old race & recording a new one. §"], 6, true, 3)
			end
			local file <close> = io.open(paths.home.."scripts\\kek_menu_stuff\\kekMenuData\\Temp recorded race.lua", "w+")
			file:write("return "..entity.get_entity_model_hash(player.get_player_vehicle(player.player_id()))..", {\n")
			local time = 0
			while f.on and player.is_player_in_any_vehicle(player.player_id()) do
				local str = "	{pos = "..tostring(entity.get_entity_coords(player.get_player_vehicle(player.player_id())))..", rot = "..tostring(entity.get_entity_rotation(player.get_player_vehicle(player.player_id())))..", time = "..time.."}"
				system.yield(0)
				time = time + gameplay.get_frame_time()
				if f.on then
					str = str..",\n"
				else
					str = str.."\n"
				end
				file:write(str)
			end
			f.on = false
			file:write("}\n")
			file:flush()
		else
			f.on = false
			essentials.msg(lang["You must be in a vehicle in order to record. §"], 6, true, 6)
		end
	end)

	menu.add_feature(lang["Save recorded race §"], "action", race_ghost_parent.id, function(f)
		if record_race.on then
			record_race.on = false
			system.yield(500)
		end
		local input, status
		while true do
			input, status = keys_and_input.get_input(lang["Type in name of race ghost. §"], input, 128, 0)
			if status == 2 then
				return
			end
			if input:find("..", 1, true) or input:find("%.$") then
				essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
				goto skip
			end
			if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..input..".lua") then
				essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
				goto skip
			end
			if input:find("[<>:\"/\\|%?%*]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
			else
				break
			end
			::skip::
			system.yield(0)
		end
		local file <close> = io.open(paths.home.."scripts\\Race ghosts\\"..input..".lua", "w+")
		file:write(essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\Temp recorded race.lua", "*a"))
		file:flush()
		create_ghost_racer_feature(input)
	end)

	local function create_custom_map_feature(...)
		local name <const> = ...
		if name:find("..", 1, true) or name:find("%.$") or name ~= essentials.get_safe_feat_name(name) then
			return
		end
		local feat = menu.add_feature(essentials.get_safe_feat_name(name), "action_value_str", custom_maps_parent.id, function(f)
			if f.value == 0 then
				menyoo.spawn_map(paths.home.."scripts\\Menyoo Maps\\"..f.name..".xml", player.player_id(), true)
			elseif f.value == 1 then
				if essentials.get_file_string("scripts\\Menyoo maps\\"..f.name..".xml", "*a"):find("<ReferenceCoords>", 1, true) then
					local file <close> = io.open(paths.home.."scripts\\Menyoo maps\\"..f.name..".xml")
					local line = ""
					while line do
						line = file:read("*l")
						if line and line:find("<ReferenceCoords>", 1, true) then
							local x <const> = tonumber((file:read("*l") or ""):match(">(.-)<"))
							local y <const> = tonumber((file:read("*l") or ""):match(">(.-)<"))
							local z <const> = tonumber((file:read("*l") or ""):match(">(.-)<"))
							if type(x) == "number" and type(y) == "number" and type(z) == "number" then
								kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), v3(x, y, z))
							else
								essentials.msg(lang["Failed to load spawn coordinates. §"], 6, true, 6)
							end
							return
						elseif not line then
							return
						end
					end
					essentials.msg(lang["Failed to load spawn coordinates. §"], 6, true, 6)
				else
					essentials.msg(lang["Found no spawn. §"], 6, true, 6)
				end
			elseif f.value == 2 then
				if utils.file_exists(paths.home.."scripts\\Menyoo Maps\\"..f.name..".xml") then
					local str <const> = essentials.get_file_string("scripts\\Menyoo maps\\"..f.name..".xml", "*a")
					local is_existing_ref_pos <const> = str:find("<ReferenceCoords>", 1, true) ~= nil
					local file <close> = io.open(paths.home.."scripts\\Menyoo maps\\"..f.name..".xml", "w+")
					local pos <const> = player.get_player_coords(player.player_id())
					local line_num = 1
					local End, start <const> = 7, 3
					for line in str:gmatch("([^\n]*)\n?") do
						if (not is_existing_ref_pos and line_num == 3) or (is_existing_ref_pos and line:find("<ReferenceCoords>", 1, true)) then
							if is_existing_ref_pos and line:find("<ReferenceCoords>", 1, true) then
								End = line_num + 4
							end
							file:write("	<ReferenceCoords>\n")
							file:write("		<X>"..pos.x.."</X>\n")
							file:write("		<Y>"..pos.y.."</Y>\n")
							file:write("		<Z>"..pos.z.."</Z>\n")
							file:write("	</ReferenceCoords>\n")
						end
						if line_num < start or line_num > End then
							file:write(line.."\n")
						end
						line_num = line_num + 1
					end
					file:flush()
				end
			elseif f.value == 3 then
				if utils.file_exists(paths.home.."scripts\\Menyoo Maps\\"..f.name..".xml") then
					io.remove(paths.home.."scripts\\Menyoo Maps\\"..f.name..".xml")
				end
				f.name = ";:~"
				f.hidden = true 
			elseif f.value == 4 then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in name of menyoo map. §"], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
						goto skip
					end
					if utils.file_exists(paths.home.."scripts\\Menyoo Maps\\"..input..".xml") then
						essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
						goto skip
					end
					if input:find("[<>:\"/\\|%?%*]") then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
					else
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file("scripts\\Menyoo Maps\\", f.name, input, "xml")
				f.name = input
			end
		end)
		feat.data = "MENYOO"
		feat:set_str_data({
			lang["Spawn §"],
			lang["Teleport to map spawn §"],
			lang["Set where you spawn §"],
			lang["Delete §"],
			lang["Change name §"]
		})
	end

	local main_feat <const> = menu.add_feature(lang["Menyoo maps §"], "action_value_str", custom_maps_parent.id, function(f)
		if f.value == 0 then
			local input, status <const> = keys_and_input.get_input(lang["Type in name of menyoo map. §"], "", 128, 0)
			if status == 2 then
				return
			end
			input = input:lower()
			for _, feature in pairs(custom_maps_parent.children) do
				if feature.data == "MENYOO" then
					feature.hidden = feature.name:lower():find(input, 1, true) == nil
				end
			end
		elseif f.value == 1 then
			local input, status
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of menyoo map. §"], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
					goto skip
				end
				if utils.file_exists(paths.home.."scripts\\Menyoo Maps\\"..input..".xml") then
					essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			local file <close> = io.open(paths.home.."scripts\\Menyoo Maps\\"..input..".xml", "w+")
			local ref <const> = player.get_player_coords(player.player_id())
			file:write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<SpoonerPlacements>\n")
			essentials.write_xml(file, {
				["ReferenceCoords"] = essentials.const({
					["X"] = ref.x,
					["Y"] = ref.y,
					["Z"] = ref.z
				})
			}, "	")
			local attached_entities <const> = {}
			local objects <const> = essentials.const(object.get_all_objects())
			for i = 1, #objects do
				if entity.is_entity_visible(objects[i]) then
					if not entity.is_entity_attached(objects[i]) then
						local info <const> = {["Attachment"] = {}}
						local pos <const> = entity.get_entity_coords(objects[i])
						info["Attachment"] = essentials.const_all({
							["InitialHandle"] = objects[i],
							["ModelHash"] = entity.get_entity_model_hash(objects[i]),
							["HashName"] = object_mapper.GetModelFromHash(entity.get_entity_model_hash(objects[i])),
							["IsCollisionProof"] = entity.has_entity_collided_with_anything(objects[i]),
							["FrozenPos"] = true,
							["PositionRotation"] = {
								["X"] = pos.x,
								["Y"] = pos.y,
								["Z"] = pos.z,
								["Pitch"] = entity.get_entity_pitch(objects[i]),
								["Roll"] = entity.get_entity_roll(objects[i]),
								["Yaw"] = entity.get_entity_rotation(objects[i]).z
							}
						})
						essentials.write_xml(file, info, "	")
					else
						attached_entities[kek_entity.get_parent_of_attachment(objects[i])] = true
					end
				end
			end
			for Entity, _ in pairs(attached_entities) do
				local entities <const> = kek_entity.get_all_attached_entities(Entity)
				for i = 1, #entities do
					local info <const> = {["Attachment"] = {}}
					local pos <const> = entity.get_entity_coords(entities[i])
					info["Attachment"] = {
						["InitialHandle"] = entities[i],
						["ModelHash"] = entity.get_entity_model_hash(entities[i]),
						["HashName"] = object_mapper.GetModelFromHash(entity.get_entity_model_hash(entities[i])),
						["IsCollisionProof"] = false,
						["FrozenPos"] = true,
						["PositionRotation"] = {
							["X"] = pos.x,
							["Y"] = pos.y,
							["Z"] = pos.z,
							["Pitch"] = entity.get_entity_pitch(entities[i]),
							["Roll"] = entity.get_entity_roll(entities[i]),
							["Yaw"] = entity.get_entity_rotation(entities[i]).z
						}
					}
					if entity.is_entity_attached(entities[i]) then
						info["Attachment"]["Attachment isAttached=\"true\""] = essentials.const({
							["BoneIndex"] = 0,
							["AttachedTo"] = entity.get_entity_attached_to(entities[i]),
							["Pitch"] = 0,
							["Roll"] = 0,
							["Yaw"] = 0,
							["X"] = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(entities[i]), entities[i])).x,
							["Y"] = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(entities[i]), entities[i])).y,
							["Z"] = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(entities[i]), entities[i])).z
						})
					end
					essentials.write_xml(file, info, "	")
				end
			end
			file:write("</SpoonerPlacements>")
			file:flush()
			create_custom_map_feature(input)
		elseif f.value == 2 then
			local feats <const> = {}
			for _, feat in pairs(custom_maps_parent.children) do
				if not feat.hidden 
				and feat.data ~= "MENYOO"
				and feat.data ~= "MAIN_FEAT"
				and not utils.file_exists(paths.home.."scripts\\Menyoo Maps\\"..feat.name..".xml") then
					essentials.delete_feature(feat.id)
				elseif feat.data == "MENYOO" then
					feats[#feats + 1] = feat
				end
			end
			for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\Menyoo Maps", "xml")) do
				if essentials.is_all_true(feats, function(feat)
					return feat.name ~= file_name:gsub("%.xml$", "")
				end) then
					create_custom_map_feature(file_name:gsub("%.xml$", ""))
				end
			end
		end
	end)
	main_feat:set_str_data({
		lang["Search §"],
		lang["Save §"],
		lang["Refresh list §"]
	})
	main_feat.data = "MAIN_FEAT"
	for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\Menyoo Maps", "xml")) do
		create_custom_map_feature(file_name:gsub("%.xml$", ""))
	end

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\Race ghosts", "lua")) do
		create_ghost_racer_feature(file_name:gsub("%.lua$", ""))
	end
end

player_feat_ids["Spawn a ped"] = menu.add_player_feature(lang["Spawn a ped §"], "action_value_str", u.player_misc_features, function(f, pid)
	if f.value == 0 then
		local hash <const> = ped_mapper.get_hash_from_user_input(settings.in_use["Default ped"])
		if streaming.is_model_a_ped(hash) then
			kek_entity.spawn_entity(hash, function() 
				return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 7)), 0
			end, false, false, enums.ped_types.civmale)
		end
	elseif f.value == 1 then
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in the name of the ped you want to spawn. §"], "", 128, 0)
		if status == 2 then
			return
		end
		settings.in_use["Default ped"] = input
	end
end).id
menu.get_player_feature(player_feat_ids["Spawn a ped"]):set_str_data({
	lang["Spawn §"],
	lang["Ped model §"]
})

u.max_self_vehicle_loop = menu.add_feature(lang["Max car §"], "slider", u.gvehicle.id, function(f)
	while f.on do
		kek_entity.max_car(player.get_player_vehicle(player.player_id()), false, true)
		system.yield(math.floor(1000 - f.value))
	end
end)
u.max_self_vehicle_loop.max = 975
u.max_self_vehicle_loop.min = 25
u.max_self_vehicle_loop.mod = 25
u.max_self_vehicle_loop.value = 500

menu.add_feature(lang["Change default vehicle §"], "action", u.vehicleSettings.id, function(f)
	local Vehicle_name <const>, status <const> = keys_and_input.get_input(lang["Type in the vehicle you want to be default. §"], "", 128, 0)
	if status == 2 then
		return
	end
	if streaming.is_model_a_vehicle(vehicle_mapper.get_hash_from_user_input(Vehicle_name)) then
		essentials.msg(lang["Changed default vehicle. §"], 212, true)
		settings.in_use["Default vehicle"] = Vehicle_name
	else
		essentials.msg(lang["Invalid input. Default value remains the same. §"], 6, true)
	end
end)

menu.add_feature(lang["Change backplate text §"], "action", u.vehicleSettings.id, function(f)
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in the text you want displayed on the backplate of your cars after maxing them. §"], "", 128, 0)
	if status == 2 then
		return
	end
	settings.in_use["Plate vehicle text"] = input
end)

menu.add_feature(lang["What vehicle to spawn §"], "action", u.gvehicle.id, function()
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in which car to spawn §"], "", 128, 0)
	if status == 2 then
		return
	end
	settings.in_use["Default vehicle"] = input:lower()
end)

menu.add_feature(lang["Spawn vehicle §"], "action", u.gvehicle.id, function()
	kek_entity.spawn_car()
end)

settings.valuei["Vehicle fly speed"] = menu.add_feature(lang["Vehicle fly speed, click to type §"], "action_value_i", u.gvehicle.id, function(f)
	keys_and_input.input_value_i(f, lang["Type in vehicle speed §"])
end)
settings.valuei["Vehicle fly speed"].min, settings.valuei["Vehicle fly speed"].max, settings.valuei["Vehicle fly speed"].mod = 0, 45000, 10

u.vehicle_fly = menu.add_feature(lang["Vehicle fly §"], "toggle", u.gvehicle.id, function(f)
	if f.on then
		local control_indexes <const> = essentials.const({
			[-3] = enums.inputs["A LEFT STICK"], 
			[-1] = enums.inputs["S LEFT STICK"], 
			[1] = enums.inputs["W LEFT STICK"], 
			[3] = enums.inputs["D LEFT STICK"], 
			[5] = enums.inputs["LEFT SHIFT A"], 
			[7] = enums.inputs["SPACEBAR X"]
		})
		local angles <const> = essentials.const({
			[-3] = 90,
			[3] = -90
		})
		local angle, rot = 0, v3()
		local direction_change_timer = 0
		local last_direction = 0
		local fly_entity = 0
		while f.on do
			system.yield(0)
			entity.set_entity_coords_no_offset(fly_entity, player.get_player_coords(player.player_id()))
			if player.is_player_in_any_vehicle(player.player_id()) then
				for i = -3, 7, 2 do
					while controls.is_disabled_control_pressed(0, control_indexes[i]) and f.on and player.is_player_in_any_vehicle(player.player_id()) do
						if not entity.is_an_entity(fly_entity) then
							fly_entity = kek_entity.spawn_entity(gameplay.get_hash_key("bmx"), function() 
								return player.get_player_coords(player.player_id()), 0 
							end, true, false, nil, false, nil, nil, true)
							entity.set_entity_max_speed(fly_entity, 45000)
							entity.set_entity_visible(fly_entity, false)
							entity.set_entity_collision(fly_entity, false, false, false)
						end
						for i2 = -3, 7, 2 do
							if utils.time_ms() > direction_change_timer 
							and last_direction ~= i2 
							and i2 ~= i 
							and controls.is_disabled_control_pressed(0, control_indexes[i2]) then
								direction_change_timer = utils.time_ms() + 150
								last_direction = i
								i = i2
								angle = 0
								rot = v3()
								break
							end
							if last_direction ~= 0 and not controls.is_disabled_control_pressed(0, control_indexes[last_direction]) then
								last_direction = 0
							end
						end
						entity.set_entity_max_speed(player.get_player_vehicle(player.player_id()), 45000)
						if i == 5 then
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
							entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3(0, 0, -settings.valuei["Vehicle fly speed"].value))
						elseif i == 7 then
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
							entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3(0, 0, settings.valuei["Vehicle fly speed"].value))
						elseif math.abs(i) == 1 then
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
							vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()), settings.valuei["Vehicle fly speed"].value * i / math.abs(i))
							entity.set_entity_coords_no_offset(fly_entity, player.get_player_coords(player.player_id()))
						else
							if angle == 0 or rot == v3() then
								angle = kek_entity.get_rotated_heading(player.get_player_vehicle(player.player_id()), angles[i], player.player_id())
								rot = cam.get_gameplay_cam_rot()
							end
							entity.set_entity_rotation(fly_entity, v3(0, 0, angle), player.player_id())
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), rot)
							vehicle.set_vehicle_forward_speed(fly_entity, settings.valuei["Vehicle fly speed"].value * 0.75)
							entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), entity.get_entity_velocity(fly_entity))
						end
						system.yield(0)
						kek_entity.get_control_of_entity(entity.get_entity_entity_has_collided_with(player.get_player_vehicle(player.player_id())), 0, true)
					end
					angle = 0
				end
				if f.on then
					entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3())
					entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
				end
			end
		end
		kek_entity.clear_entities({fly_entity})
	end
end)

player_feat_ids["player otr"] = menu.add_player_feature(lang["Off the radar §"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		if not globals.is_player_otr(pid) then
			globals.send_script_event("Give OTR or ghost organization", pid, {pid, utils.time() - 60, utils.time(), 1, 1, globals.generic_player_global(pid)})
		end
		system.yield(100)
	end
end).id

player_feat_ids["Never wanted"] = menu.add_player_feature(lang["Never wanted §"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		if player.is_player_valid(pid) and player.get_player_wanted_level(pid) > 0 then
			globals.send_script_event("Remove wanted level", pid, {pid, globals.generic_player_global(pid)})
		end
		system.yield(0)
	end
end).id

player_feat_ids["30k ceo"] = menu.add_player_feature(lang["30k ceo loop §"], "toggle", u.script_stuff, function(f, pid)
	if u.send_30k_to_session.on then
		f.on = false
		return
	end
	menu.create_thread(function()
		while f.on do
			system.yield(0)
			globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 0, globals.generic_player_global(pid), globals.get_9__10_globals_pair()})
			essentials.wait_conditional(15000, function() 
				return f.on 
			end)
			globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 1, globals.generic_player_global(pid), globals.get_9__10_globals_pair()})
			essentials.wait_conditional(15000, function() 
				return f.on 
			end)
		end
	end, nil)
	while f.on do
		globals.send_script_event("CEO money", pid, {pid, 30000, 198210293, 1, globals.generic_player_global(pid), globals.get_9__10_globals_pair()})
		essentials.wait_conditional(100000, function() 
			return f.on 
		end)
		system.yield(0)
	end
end).id

menu.add_player_feature(lang["Block passive §"], "toggle", u.script_stuff, function(f, pid)
	if f.on then
		globals.send_script_event("Block passive", pid, {pid, 1})
	else
		globals.send_script_event("Block passive", pid, {pid, 0})
	end
end)

menu.add_player_feature(lang["Set bounty §"], "action_value_str", u.script_stuff, function(f, pid)
	if f.value == 2 then
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in bounty amount §"], "", 5, 3)
		if status == 2 then
			return
		end
		settings.in_use["Bounty amount"] = input
	else
		globals.set_bounty(pid, false, f.value == 0)
	end
end):set_str_data({
	lang["Anonymous §"],
	lang["With your name §"],
	lang["Change amount §"]
})

menu.add_player_feature(lang["Reapply bounty §"], "value_str", u.script_stuff, function(f, pid)
	while f.on do
		if entity.is_entity_dead(player.get_player_ped(pid)) then
			globals.set_bounty(pid, false, f.value == 0)
		end
		system.yield(0)
	end
end):set_str_data({
	lang["Anonymous §"],
	lang["With your name §"]
})


menu.add_player_feature(lang["Perico island §"], "toggle", u.script_stuff, function(f, pid)
	if f.on then
		globals.send_script_event("Send to Perico island", pid, {pid, globals.get_script_event_hash("Send to Perico island"), 0, 0})
	else
		globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, math.random(1, 114), 1, 1, 1})
	end
end)

menu.add_player_feature(lang["Apartment invites §"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, math.random(1, 114), 1, 1, 1})
		system.yield(5000)
	end
end)

menu.add_player_feature(lang["Send to random mission §"], "action", u.script_stuff, function(f, pid)
	globals.send_script_event("Send to mission", pid, {pid, math.random(1, 7)})
end)

menu.add_player_feature(lang["Notification spam §"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		globals.send_script_event("Insurance notification", pid, {pid, math.random(-2147483647, 2147483647)})
		system.yield(0)
	end
end)

menu.add_player_feature(lang["Transaction error §"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		globals.send_script_event("Transaction error", pid, {pid, 50000, 0, 1, globals.generic_player_global(pid), globals.get_9__10_globals_pair(), 1})
		system.yield(500)
	end
end)

menu.add_player_feature(lang["Teleport to §"], "action_value_str", u.player_vehicle_features, function(f, pid)
	if f.value == 0 and player.player_id() ~= pid then
		kek_entity.teleport_player_and_vehicle_to_position(pid, location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8)), true, true)
	elseif f.value == 1 then
		if ui.get_waypoint_coord().x > 14000 then
			essentials.msg(lang["Please set a waypoint. §"], 6, true)
			return
		end
		kek_entity.teleport_player_and_vehicle_to_position(pid, location_mapper.get_most_accurate_position(v3(ui.get_waypoint_coord().x, ui.get_waypoint_coord().y, -50)), player.player_id() ~= pid, false, true, f)
	elseif f.value == 2 then
		kek_entity.teleport_player_and_vehicle_to_position(pid, v3(491.9401550293, 5587, 794.00347900391), player.player_id() ~= pid, true)
		globals.disable_vehicle(pid)
		system.yield(1500)
		for i = 1, 20 do
			system.yield(0)
			essentials.use_ptfx_function(fire.add_explosion, player.get_player_coords(pid), 29, true, false, 0, player.get_player_ped(pid))
		end
	elseif f.value == 3 then
		kek_entity.teleport_player_and_vehicle_to_position(pid, v3(math.random(20000, 25000), math.random(-25000, -20000), math.random(-2400, 2400)), player.player_id() ~= pid, true)
	end
end):set_str_data({
	lang["me §"],
	lang["waypoint §"],
	lang["Mount Chiliad & kill §"],
	lang["far away §"]
})

do
	local feat <const> = menu.add_player_feature(lang["Vehicle §"], "action_value_str", u.player_vehicle_features, function(f, pid)
		local initial_pos <const> = player.get_player_coords(player.player_id())
		local relative_pos <const> = kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 7)
		local status <const>, had_to_teleport <const> = kek_entity.is_target_viable(pid)
		if status then
			if f.value == 0 then
				kek_entity.max_car(player.get_player_vehicle(pid))
			elseif f.value == 1 then
				kek_entity.repair_car(player.get_player_vehicle(pid))
			elseif f.value == 2 then
				if not f.data.vehicles then
					f.data.vehicles = {}
				end
				if kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
					if not f.data.vehicles[player.get_player_vehicle(pid)] or f.data.vehicles[player.get_player_vehicle(pid)] == 1 then
						vehicle.set_vehicle_engine_health(player.get_player_vehicle(pid), -4000)
						f.data.vehicles[player.get_player_vehicle(pid)] = 0
					else
						vehicle.set_vehicle_engine_health(player.get_player_vehicle(pid), 1000)
						f.data.vehicles[player.get_player_vehicle(pid)] = 1
					end
				end
			elseif f.value == 3 then
				if kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
					vehicle.set_vehicle_doors_locked(player.get_player_vehicle(pid), 4)
				end
			elseif f.value == 4 then
				globals.send_script_event("Destroy personal vehicle", pid, {pid, pid})
				kek_entity.remove_player_vehicle(pid)
			elseif f.value == 5 then
				menyoo.clone_vehicle(player.get_player_vehicle(pid), relative_pos)
			end
		end
		if had_to_teleport then
			kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
		end
	end).id
	menu.get_player_feature(feat):set_str_data({
		lang["Max §"],
		lang["Repair §"],
		lang["Toggle engine §"],
		lang["Lock player inside §"],
		lang["Remove §"],
		lang["Clone §"]
	})
	for i = 0, 31 do
		menu.get_player_feature(feat).feats[i].data = {}
	end
end

menu.add_player_feature(lang["Spawn vehicle §"], "action", u.player_vehicle_features, function(f, pid)
	local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["Default vehicle"])
	if streaming.is_model_a_vehicle(hash) then
		if not kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
			essentials.msg(lang["Failed to spawn vehicle. Vehicle limit was reached §"], 6, true, 6)
			return
		end
		kek_entity.spawn_entity(hash, function()
			return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 8)), player.get_player_heading(pid)
		end, settings.toggle["Spawn #vehicle# in godmode"].on, settings.toggle["Spawn #vehicle# maxed"].on)
	end
end)

menu.add_player_feature(lang["What vehicle to spawn §"], "action", u.player_vehicle_features, function()
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in which car to spawn §"], "", 128, 0)
	if status == 2 then
		return
	end
	settings.in_use["Default vehicle"] = input:lower()
end)

u.spawn_vehicle_parent = menu.add_player_feature(lang["Spawn vehicle §"], "parent", u.player_vehicle_features).id
kek_entity.generate_player_vehicle_list({
		type = "action"
	},
	u.spawn_vehicle_parent,
	function(f, pid)
		settings.in_use["Default vehicle"] = vehicle_mapper.GetModelFromHash(f.data)
		if not kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
			essentials.msg(lang["Failed to spawn vehicle. Vehicle limit was reached §"], 6, true, 6)
			return
		end
		kek_entity.spawn_entity(f.data, function()
			return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 8)), player.get_player_heading(pid)
		end, settings.toggle["Spawn #vehicle# in godmode"].on, settings.toggle["Spawn #vehicle# maxed"].on)
	end,
	"")

menu.add_player_feature(lang["Spawn Menyoo vehicle §"], "action", u.player_vehicle_features, function(f, pid)
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in name of menyoo vehicle. §"], "", 128, 0)
	if status == 2 then
		return
	end
	for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\Menyoo Vehicles", "xml")) do
		if file_name:lower():find(input:lower(), 1, true) then
			menyoo.spawn_custom_vehicle(paths.home.."scripts\\Menyoo Vehicles\\"..file_name, pid, true)
			return
		end
	end
end)

player_feat_ids["Player horn boost"] = menu.add_player_feature(lang["Horn boost §"], "slider", u.player_vehicle_features, function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_pressing_horn(pid) and kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
			vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), math.min(150, entity.get_entity_speed(player.get_player_vehicle(pid)) + f.value))
			system.yield(550)
		end
	end
end).id
menu.get_player_feature(player_feat_ids["Player horn boost"]).max = 100
menu.get_player_feature(player_feat_ids["Player horn boost"]).min = 5
menu.get_player_feature(player_feat_ids["Player horn boost"]).mod = 5
menu.get_player_feature(player_feat_ids["Player horn boost"]).value = 25

do
	local feat = menu.add_player_feature(lang["Flamethrower §"], "action_value_str", u.player_vehicle_features, function(f, pid)
		if entity.is_an_entity(player.get_player_vehicle(pid)) then
			if f.value == 0 then
				if not f.data.ptfx_in_use[player.get_player_vehicle(pid)] and kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) and essentials.request_ptfx("weap_xs_vehicle_weapons") then
					f.data.ptfx_in_use[player.get_player_vehicle(pid)] = essentials.use_ptfx_function(graphics.start_networked_ptfx_looped_on_entity, f.data.ptfx_names[math.random(1, #f.data.ptfx_names)], player.get_player_vehicle(pid), v3(0, 3, 0), v3(), essentials.random_real(1, 3))
					table.remove(essentials.ptfx_in_use, #essentials.ptfx_in_use)
					essentials.ptfx_in_use[#essentials.ptfx_in_use + 1] = utils.time_ms() + 60000
				end
			elseif f.value == 1 and f.data.ptfx_in_use[player.get_player_vehicle(pid)] and kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
				graphics.remove_particle_fx(f.data.ptfx_in_use[player.get_player_vehicle(pid)], false)
				f.data.ptfx_in_use[player.get_player_vehicle(pid)] = nil
			end
		end
	end)
	for pid = 0, 31 do
		feat.feats[pid].data = essentials.const({
			ptfx_in_use = {},
			ptfx_names = essentials.const({
				"muz_xs_turret_flamethrower_looping_sf",
				"muz_xs_turret_flamethrower_looping"
			})
		})
	end
	feat:set_str_data({
		lang["Give §"],
		lang["Remove §"]
	})
end

player_feat_ids["Drive force multiplier"] = menu.add_player_feature(lang["Drive force multiplier §"], "action_value_f", u.player_vehicle_features, function(f, pid)
	if kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
		entity.set_entity_max_speed(player.get_player_vehicle(pid), 45000)
		vehicle.modify_vehicle_top_speed(player.get_player_vehicle(pid), (f.value - 1) * 100)
	end
end).id
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).max = 20.0
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).min = -4.0
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).mod = 0.1
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).value = 1.0

menu.add_player_feature(lang["Car godmode §"], "value_str", u.player_vehicle_features, function(f, pid)
	while f.on do
		system.yield(0)
		kek_entity.modify_entity_godmode(player.get_player_vehicle(pid), f.value == 0)
	end
end):set_str_data({
	lang["Give §"],
	lang["Remove §"]
})

menu.add_player_feature(lang["Vehicle can't be locked on §"], "action_value_str", u.player_vehicle_features, function(f, pid)
	if kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
		vehicle.set_vehicle_can_be_locked_on(player.get_player_vehicle(pid), f.value == 1, true)
	end
end):set_str_data({
	lang["Give §"],
	lang["Remove §"]
})

menu.add_player_feature(lang["Vehicle fly player §"], "toggle", u.player_vehicle_features, function(f, pid)
	while f.on do
		system.yield(0)
		local control_indexes <const> = essentials.const({
			32, 
			33
		})
		entity.set_entity_max_speed(player.get_player_vehicle(pid), 45000)
		for i = 1, 2 do
			while controls.is_disabled_control_pressed(0, control_indexes[i]) do
				local speed <const> = essentials.const({
					settings.valuei["Vehicle fly speed"].value, 
					-settings.valuei["Vehicle fly speed"].value
				})
				if kek_entity.get_control_of_entity(player.get_player_vehicle(pid), 0) then
					entity.set_entity_max_speed(player.get_player_vehicle(pid), 45000)
					kek_entity.get_control_of_entity(entity.get_entity_entity_has_collided_with(player.get_player_vehicle(pid)), 0)
					entity.set_entity_rotation(player.get_player_vehicle(pid), cam.get_gameplay_cam_rot())
					vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), speed[i])
				end
				system.yield(0)
				if not f.on then
					break
				end
			end
		end
		if f.on then
			entity.set_entity_velocity(player.get_player_vehicle(pid), v3())
			entity.set_entity_rotation(player.get_player_vehicle(pid), cam.get_gameplay_cam_rot())
		end
	end
end)

menu.add_player_feature(lang["Ram player with vehicle §"], "toggle", u.player_trolling_features, function(f, pid)
	local hash, vehicle_name
	while f.on do
		if vehicle_name ~= settings.in_use["Default vehicle"] then
			vehicle_name = settings.in_use["Default vehicle"]
			hash = vehicle_mapper.get_hash_from_user_input(settings.in_use["Default vehicle"])
		end
		if streaming.is_model_a_vehicle(hash) and not entity.is_entity_dead(player.get_player_ped(pid)) then
			essentials.use_ptfx_function(kek_entity.spawn_and_push_a_vehicle_in_direction, pid, true, 8, hash)
		end
		system.yield(0)
	end
end)
menu.add_player_feature(lang["Spastic car §"], "toggle", u.player_trolling_features, function(f, pid)
	while f.on do
		if kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
			entity.set_entity_rotation(player.get_player_vehicle(pid), v3(essentials.random_real(-179.9999, 179.9999), essentials.random_real(-179.9999, 179.9999), essentials.random_real(-179.9999, 179.9999)))
			vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), math.random(-1000, 1000))
			entity.apply_force_to_entity(player.get_player_vehicle(pid), 3, math.random(-4, 4), math.random(-4, 4), math.random(-1, 5), 0, 0, 0, true, true)
		end
		system.yield(0)
	end
end)

menu.add_player_feature(lang["Send Menyoo vehicle attacker §"], "action", u.player_trolling_features, function(f, pid)
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in name of menyoo vehicle. §"], "", 128, 0)
	if status == 2 then
		return
	end
	for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\Menyoo Vehicles", "xml")) do
		if file_name:lower():find(input:lower(), 1, true) then
			local Entity <const> = menyoo.spawn_custom_vehicle(paths.home.."scripts\\Menyoo Vehicles\\"..file_name, pid, false)
			if streaming.is_model_a_plane(entity.get_entity_model_hash(Entity)) then
				essentials.msg(lang["Attackers can't use planes. Cancelled. §"], 6, true)
				kek_entity.hard_remove_entity_and_its_attachments(Entity)
				return
			end
			kek_entity.teleport(Entity, location_mapper.get_most_accurate_position(player.get_player_coords(pid) + essentials.get_random_offset(-80, 80, 45, 75), true), 0)
			troll_entity.setup_peds_and_put_in_seats(kek_entity.get_empty_seats(Entity), ped_mapper.get_random_ped("all peds except animals"), Entity, pid)
			return
		end
	end
end)

menu.add_player_feature(lang["Send §"], "value_str", u.player_trolling_features, function(f, pid)
	while f.on do
		if f.value == 0 then
			troll_entity.spawn_standard_alone(f, pid, troll_entity.send_clown_van)
		elseif f.value == 1 then
			troll_entity.spawn_standard_alone(f, pid, troll_entity.send_kek_chopper)
		elseif f.value == 2 then
			troll_entity.spawn_standard_alone(f, pid, troll_entity.send_army)
		end
		system.yield(0)
	end
end):set_str_data({
	lang["Clown vans §"],
	lang["Kek's chopper §"],
	lang["Army §"]
})

settings.toggle["Exclude yourself from trolling"] = menu.add_feature(lang["Exclude you from session trolling §"], "toggle", u.self_options.id, function(f)
	settings.in_use["Exclude yourself from trolling"] = f.on
end)

menu.add_feature(lang["Get parachute §"], "action", u.self_options.id, function(f)
	weapon.give_delayed_weapon_to_ped(player.get_player_ped(player.player_id()), gameplay.get_hash_key("gadget_parachute"), 1, 0)
end)

menu.add_feature(lang["Send to session §"], "value_str", u.session_trolling.id, function(f)
	while f.on do
		system.yield(0)
		if f.value == 0 then
			troll_entity.spawn_standard(f, troll_entity.send_clown_van)
		elseif f.value == 1 then
			troll_entity.spawn_standard(f, troll_entity.send_army)
		end
	end
end):set_str_data({
	lang["Clown vans §"],
	lang["Army §"]
})

menu.add_player_feature(lang["Taze player §"], "toggle", u.player_trolling_features, function(f, pid)
	while f.on do
		gameplay.shoot_single_bullet_between_coords(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), essentials.random_real(-0.5, 0.5)) + v3(0, 0, essentials.random_real(0, 1)), select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f2, v3())), 0, gameplay.get_hash_key("weapon_stungun"), player.get_player_ped(player.player_id()), true, false, 2000)
		system.yield(1000)
	end
end)

u.atomize = menu.add_player_feature(lang["Atomize §"], "slider", u.player_trolling_features, function(f, pid)
	menu.create_thread(function()
		while f.on do
			if player.is_player_in_any_vehicle(pid) then
				kek_entity.repair_car(player.get_player_vehicle(pid))
			end
			system.yield(0)
		end
	end, nil)
	while f.on do
		if not entity.is_entity_dead(player.get_player_ped(pid)) then
			essentials.use_ptfx_function(
				gameplay.shoot_single_bullet_between_coords, 
				kek_entity.get_vector_relative_to_entity(essentials.get_most_relevant_entity(pid), 1),
				entity.get_entity_coords(essentials.get_most_relevant_entity(pid)),
				1,
				gameplay.get_hash_key("weapon_raypistol"), 
				player.get_player_ped(player.player_id()), 
				true, 
				false, 
				1000
			)
		end
		system.yield(math.floor(1000 - f.value))
	end
end)
u.atomize.max = 1000
u.atomize.min = 200
u.atomize.mod = 50
u.atomize.value = 1000

menu.add_player_feature(lang["Float §"], "value_str", u.player_trolling_features, function(f, pid)
	local hash <const> = gameplay.get_hash_key("bkr_prop_biker_bblock_sml2")
	local platform = 0
	local pos = v3()
	while f.on do
		system.yield(0)
		if not entity.is_an_entity(platform) then
			local objects <const> = essentials.const(object.get_all_objects())
			for i = 1, #objects do
				if entity.get_entity_model_hash(objects[i]) == hash and essentials.get_distance_between(objects[i], player.get_player_ped(pid)) < 75 then
					kek_entity.clear_entities({objects[i]})
				end
			end
			platform = kek_entity.spawn_entity(hash, function()
				pos = player.get_player_coords(pid) - v3(0, 0, -2.5)
				return pos
			end)
		end
		if entity.get_entity_coords(platform).z > player.get_player_coords(pid).z + 3 then
			pos.z = player.get_player_coords(pid).z - 2.5
		elseif f.value == 0 then
			pos.z = pos.z + 0.05
		elseif f.value == 2 and entity.get_entity_coords(platform).z + 5 > player.get_player_coords(pid).z then
			pos.z = pos.z - 0.05
		end
		pos.x = player.get_player_coords(pid).x
		pos.y = player.get_player_coords(pid).y
		kek_entity.teleport(platform, pos)
	end
	kek_entity.clear_entities({platform})
end):set_str_data({
	lang["Upwards §"],
	lang["Still §"],
	lang["Downwards §"]
})

menu.add_player_feature(lang["Kidnap player §"], "toggle", u.player_trolling_features, function(f, pid)
	if f.on then
		if player.player_id() == pid then
			f.on = false
			return
		end
		essentials.set_all_player_feats_except(menu.get_player_feature(f.id).id, false, {pid})
		kek_entity.remove_player_vehicle(player.player_id())
		local van = 0
		menu.create_thread(function()
			while f.on and player.is_player_valid(pid) do
				system.yield(0)
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			end
		end, nil)
		while f.on do
			system.yield(0)
			if not entity.is_entity_dead(player.get_player_ped(pid)) then
				if not entity.is_an_entity(van) then
					van = kek_entity.spawn_entity(gameplay.get_hash_key("stockade"), function()
						return location_mapper.get_most_accurate_position(player.get_player_coords(pid)) + v3(0, 0, 50), 0
					end, true, true)
					vehicle.set_vehicle_doors_locked_for_all_players(van, true)
				end
				if entity.is_an_entity(van) and not ped.is_ped_in_vehicle(player.get_player_ped(player.player_id()), van) then
					ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), van, enums.vehicle_seats.driver)
				end
				if player.is_player_valid(pid)
				and essentials.get_distance_between(player.get_player_ped(pid), van) > 5 
				and (not essentials.is_in_vehicle(pid) or kek_entity.remove_player_vehicle(pid)) then
					kek_entity.teleport(van, kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 2.20) - v3(0, 0, 1))
					entity.set_entity_heading(van, player.get_player_heading(pid))
				end
			end			
		end
		local _ <const>, is_player <const> = kek_entity.get_number_of_passengers(van)
		if not is_player then
			entity.delete_entity(van)
		end
	end
end)

menu.add_player_feature(lang["Glitch vehicle §"], "action_value_str", u.player_trolling_features, function(f, pid)
	if f.value == 0 then
		kek_entity.glitch_vehicle(player.get_player_vehicle(pid))
	elseif f.value == 1 then
		if entity.is_entity_a_vehicle(player.get_player_vehicle(pid)) then
			for seat = -1, vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(player.get_player_vehicle(pid))) - 2 do
				local Ped <const> = vehicle.get_ped_in_vehicle_seat(player.get_player_vehicle(pid), seat)
				if entity.is_an_entity(Ped) and not ped.is_ped_a_player(Ped) then
					kek_entity.clear_entities(kek_entity.get_all_attached_entities(Ped))
					kek_entity.clear_entities({Ped})
				end
			end
		end
	end
end):set_str_data({
	lang["Glitch §"],
	lang["Unglitch §"]
})

menu.add_feature(lang["Give all weapons §"], "action", u.weapons_self.id, function()
	for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
		weapon.give_delayed_weapon_to_ped(player.get_player_ped(player.player_id()), weapon_hash, 0, 0)
	end
end)

menu.add_feature(lang["Max all weapons §"], "action", u.weapons_self.id, function()
	for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
		weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(player.player_id()), false, weapon_hash)
	end
end)

menu.add_feature(lang["Randomize all weapons §"], "action", u.weapons_self.id, function()
	for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
		weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(player.player_id()), true, weapon_hash)
	end
end)

settings.toggle["Random weapon camos"] = menu.add_feature(lang["Random weapon camo §"], "slider", u.weapons_self.id, function(f)
	while f.on do
		for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
			if weapon.has_ped_got_weapon(player.get_player_ped(player.player_id()), weapon_hash) then
				local number_of_tints <const> = weapon.get_weapon_tint_count(weapon_hash)
				if weapon_hash and weapon_hash ~= gameplay.get_hash_key("weapon_unarmed") and number_of_tints > 0 then
					weapon.set_ped_weapon_tint_index(player.get_player_ped(player.player_id()), weapon_hash, math.random(1, number_of_tints))
				end
			end
		end
		system.yield(1000 - math.floor(f.value))
	end
end)
settings.valuei["Random weapon camos speed"] = settings.toggle["Random weapon camos"]
settings.valuei["Random weapon camos speed"].max = 980
settings.valuei["Random weapon camos speed"].min = 0
settings.valuei["Random weapon camos speed"].mod = 20
settings.valuei["Random weapon camos speed"].value = 500

player_feat_ids["Vehicle gun"] = menu.add_player_feature(lang["Vehicle gun §"], "toggle", u.pWeapons, function(f, pid)
	if f.on then
		if player.player_id() == pid then
			u.self_vehicle_gun.on = true
		end
		local entities <const>, distance_from_player = {}
		menu.create_thread(function()
			while f.on do
				if #entities > 15 then
					kek_entity.clear_entities({entities[1]})
					table.remove(entities, 1)
				end
				system.yield(0)
			end
		end, nil)
		while f.on do
			if settings.in_use["Default vehicle"] == "?" or player.is_player_in_any_vehicle(pid) then
				distance_from_player = 18
			else
				distance_from_player = 9
			end
			if f.on and ped.is_ped_shooting(player.get_player_ped(pid)) then
				local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["Default vehicle"])
				if streaming.is_model_a_vehicle(hash) then
					local car <const> = kek_entity.spawn_entity(hash, function()
						local pos
						if player.player_id() == pid then
							pos = kek_entity.get_vector_in_front_of_me(player.get_player_ped(pid), distance_from_player)
						else
							pos = kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), distance_from_player)
						end
						return pos, player.get_player_heading(pid)
					end)
					if player.player_id() ~= pid then
						entity.set_entity_rotation(car, entity.get_entity_rotation(player.get_player_ped(pid)))
					else
						entity.set_entity_rotation(car, cam.get_gameplay_cam_rot())
					end
					vehicle.set_vehicle_forward_speed(car, 120)
					entities[#entities + 1] = car
				end
			end
			system.yield(0)
		end
		if player.player_id() == pid then
			u.self_vehicle_gun.on = false
		end
		kek_entity.clear_entities(entities)
	end
end).id

menu.add_player_feature(lang["Kick gun §"], "toggle", u.pWeapons, function(f, pid)
	while f.on do
		system.yield(0)
		local Ped <const> = player.get_entity_player_is_aiming_at(pid)
		if entity.is_entity_a_ped(Ped) and ped.is_ped_a_player(Ped) then
			local target_pid <const> = player.get_player_from_ped(Ped)
			if ped.is_ped_shooting(player.get_player_ped(pid)) and essentials.is_not_friend(target_pid) then
				globals.kick(target_pid)
			end
		end
	end
end)

menu.add_player_feature(lang["Delete gun §"], "toggle", u.pWeapons, function(f, pid)
	while f.on do
		system.yield(0)
		local Entity <const> = player.get_entity_player_is_aiming_at(pid)
		network.request_control_of_entity(Entity)
		if ped.is_ped_shooting(player.get_player_ped(pid))
		and entity.is_an_entity(Entity) 
		and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) 
		and network.has_control_of_entity(Entity) then
			entity.set_entity_as_mission_entity(Entity, false, true)
			entity.delete_entity(Entity)
		end
	end
end)

menu.add_player_feature(lang["Explosion gun §"], "toggle", u.pWeapons, function(f, pid)
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(pid)) then
			local pos = select(2, ped.get_ped_last_weapon_impact(player.get_player_ped(pid)))
			essentials.use_ptfx_function(fire.add_explosion, pos, math.random(0, 82), true, false, 0, player.get_player_ped(pid))
		end
		system.yield(0)
	end
end)

menu.add_feature(lang["Type in what object §"], "action", u.weapons_self.id, function()
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in what object to use. §"], "", 128, 0)
	if status == 2 then
		return
	end
	local object_hash <const> = object_mapper.get_hash_from_user_input(input)
	if object_hash == 0 then
		essentials.msg(lang["Invalid object. §"], 6, true)
		return
	end
	settings.in_use["Default object"] = input:lower()
end)

u.object_gun = menu.add_feature(lang["Object gun §"], "toggle", u.weapons_self.id, function(f)
	local entities <const> = {}
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local hash <const> = object_mapper.get_hash_from_user_input(settings.in_use["Default object"])
			if streaming.is_model_an_object(hash) then
				entities[#entities + 1] = kek_entity.spawn_entity(hash, function() 
					return kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 15), 0
				end)
				local pos <const> = kek_entity.get_collision_vector(player.player_id())
				entity.set_entity_rotation(entities[#entities], cam.get_gameplay_cam_rot())
				for i = 1, 10 do
					entity.apply_force_to_entity(entities[#entities], 3, pos.x, pos.y, pos.z, 0, 0, 0, true, true)
				end
				if #entities > 10 then
					kek_entity.clear_entities({entities[1]})
					table.remove(entities, 1)
				end
			end
		end
		system.yield(0)
	end
	kek_entity.clear_entities(entities)
end)

u.airstrike_gun = menu.add_feature(lang["Airstrike gun §"], "toggle", u.weapons_self.id, function(f)
	while f.on do
		system.yield(0)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local pos <const> = kek_entity.get_collision_vector(player.player_id())
	    	gameplay.shoot_single_bullet_between_coords(pos + v3(0, 0, 15), pos, 1000, gameplay.get_hash_key("weapon_airstrike_rocket"), player.get_player_ped(player.player_id()), true, false, 250)
	    end
	end
end)

menu.add_feature(lang["What vehicle vehicle gun §"], "action", u.weapons_self.id, function()
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in what car to use §"], "", 128, 0)
	if status == 2 then
		return
	end
	settings.in_use["Default vehicle"] = input:lower()
end)

u.self_vehicle_gun = menu.add_feature(lang["Vehicle gun §"], "toggle", u.weapons_self.id, function(f)
	menu.get_player_feature(player_feat_ids["Vehicle gun"]).feats[player.player_id()].on = f.on
end)

menu.add_feature(lang["Clear entities §"], "value_str", u.kek_utilities.id, function(f)
	local radius = 0
	menu.create_thread(function()
		while f.on do
			if settings.toggle["Show red sphere clear entities"].on and f.value ~= 4 and f.value ~= 5 and radius < 10001 then
				graphics.draw_marker(28, player.get_player_coords(player.player_id()), v3(0, 90, 0), v3(0, 90, 0), v3(radius, radius, radius), 255, 0, 0, 85, false, false, 2, false, nil, "MarkerTypeDebugSphere", false)
			end
			system.yield(0)
		end
	end, nil)
	while f.on do
		system.yield(0)
		if f.value == 6 then
			gameplay.clear_area_of_cops(entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()), settings.valuei["Cops clear distance"].value, true)
			radius = settings.valuei["Cops clear distance"].value
		else
			local entities <const> = {}
			local pos <const> = entity.get_entity_coords(essentials.get_ped_closest_to_your_pov())
			if f.value == 0 or f.value == 4 or f.value == 5 then
				entities.vehicles = {
					entities 			   = vehicle.get_all_vehicles(),
					max_number_of_entities = nil,
					remove_player_entities = true,
					max_range 			   = settings.valuei["Vehicle clear distance"].value,
					sort_by_closest 	   = false
				}
				radius = settings.valuei["Vehicle clear distance"].value
			end
			if f.value == 1 or f.value == 4 or f.value == 5 then
				entities.peds = {
					entities 			   = ped.get_all_peds(),
					max_number_of_entities = nil,
					remove_player_entities = true,
					max_range 			   = settings.valuei["Ped clear distance"].value,
					sort_by_closest 	   = false
				}
				radius = settings.valuei["Ped clear distance"].value
			end
			if f.value == 2 or f.value == 5 then
				entities.objects = {
					entities 			   = object.get_all_objects(),
					max_number_of_entities = nil,
					remove_player_entities = false,
					max_range 			   = settings.valuei["Object clear distance"].value,
					sort_by_closest 	   = false
				}
				radius = settings.valuei["Object clear distance"].value
			end
			if f.value == 3 or f.value == 5 then
				entities.pickups = {
					entities 			   = object.get_all_pickups(),
					max_number_of_entities = nil,
					remove_player_entities = false,
					max_range 			   = settings.valuei["Pickup clear distance"].value,
					sort_by_closest 	   = false
				}
				radius = settings.valuei["Pickup clear distance"].value
			end
			kek_entity.clear_entities(kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(entities, essentials.get_ped_closest_to_your_pov()))
		end
	end
end):set_str_data({
	lang["Vehicles §"], 
	lang["Peds §"], 
	lang["Objects §"], 
	lang["Pickups §"], 
	lang["Peds & vehicles §"], 
	lang["All §"], 	
	lang["Cops §"]
})

settings.toggle["Show red sphere clear entities"] = menu.add_feature(lang["Show sphere §"], "toggle", u.kek_utilities.id)

for _, name in pairs({
	"Vehicle clear distance §", 
	"Ped clear distance §", 
	"Object clear distance §", 
	"Pickup clear distance §", 
	"Cops clear distance §"
}) do
	local setting_name <const> = name:gsub(" §", "")
	settings.valuei[setting_name] = menu.add_feature(lang[name], "action_value_i", u.kek_utilities.id, function(f)
		keys_and_input.input_value_i(f, lang["Type in clear distance limit. §"])
	end)
	settings.valuei[setting_name].max, settings.valuei[setting_name].min, settings.valuei[setting_name].mod = 25000, 1, 10
end

menu.add_feature(lang["Clear all owned entities §"], "action", u.kek_utilities.id, function()
	kek_entity.entity_manager:update()
	for Entity, _ in pairs(essentials.deep_copy(kek_entity.entity_manager.entities)) do
		if Entity ~= player.get_player_vehicle(player.player_id()) and kek_entity.get_control_of_entity(Entity, 200) then
			kek_entity.hard_remove_entity_and_its_attachments(Entity)
		end
	end
end)

menu.add_feature(lang["Disable ped spawning §"], "toggle", u.kek_utilities.id, function(f)
	while f.on do
		ped.set_ped_density_multiplier_this_frame(0)
		system.yield(0)
	end
end)

menu.add_feature(lang["Disable vehicle spawning §"], "toggle", u.kek_utilities.id, function(f)
	while f.on do
		vehicle.set_vehicle_density_multipliers_this_frame(0)
		system.yield(0)
	end
end)

menu.add_feature(lang["Shoot entity| get model name of entity §"], "toggle", u.kek_utilities.id, function(f)
	while f.on do
		local model_name = ""
		local Entity <const> = player.get_entity_player_is_aiming_at(player.player_id())
		local hash <const> = entity.get_entity_model_hash(Entity)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			if streaming.is_model_an_object(hash) then
				model_name = object_mapper.GetModelFromHash(hash)
			elseif streaming.is_model_a_ped(hash) then
				model_name = ped_mapper.get_model_from_hash(hash)
			elseif streaming.is_model_a_vehicle(hash) then
				model_name = vehicle_mapper.GetModelFromHash(hash)
			else
				model_name = ""
			end
		end
		if Entity ~= 0 then
			local name, model
			if entity.is_entity_a_vehicle(Entity) then
				model = vehicle_mapper.GetModelFromHash(hash)
				name = vehicle_mapper.get_translated_vehicle_name(hash).."\n"
			elseif entity.is_entity_a_ped(Entity) then
				name = ped_mapper.get_model_from_hash(hash)
			else
				name = object_mapper.GetModelFromHash(hash)
			end
			ui.set_text_color(255, 255, 255, 255)
			ui.set_text_scale(0.5)
			ui.set_text_font(1)
			ui.set_text_outline(true)
			ui.draw_text(name..(model or "").."\n"..hash, v2(0.5, 0.4))
		end
		if model_name ~= "" then
			essentials.msg(lang["The hash was copied to your clipboard, more info in the debug console. §"], 140, true)
			print("\nModel name: "..model_name.."\nModel hash: "..hash)
			utils.to_clipboard(tostring(hash))
			model_name = ""
			system.yield(250)
		end
		system.yield(0)
	end
end)

do
	u.entity_manager = menu.add_feature(lang["Entity manager §"], "parent", u.kek_utilities.id)
	local entity_manager_parents <const> = essentials.const({
		menu.add_feature(lang["Vehicles §"], "parent", u.entity_manager.id),
		menu.add_feature(lang["Peds §"], "parent", u.entity_manager.id),
		menu.add_feature(lang["Objects §"], "parent", u.entity_manager.id)
	})

	local parents_in_use <const> = essentials.const({
		{},
		{},
		{}
	})
	local filters <const> = {
		"",
		"",
		""
	}
	local free_parents <const> = essentials.const({
		{},
		{},
		{}
	})
	local get_names <const> = essentials.const({
		vehicle_mapper.get_translated_vehicle_name,
		ped_mapper.get_model_from_hash,
		object_mapper.GetModelFromHash
	})
	local number_of_features <const> = essentials.const({
		300, -- Vehicles
		256, -- Peds
		2300 -- Objects
	})

	local set_yourself_in_seat <const> = {}
	local teleport_all_in_front_of_player <const> = {}
	local teleport_in_front_of_player <const> = {}
	local seat_strings <const> = essentials.const({
		lang["Driver's seat §"],
		lang["Front passenger seat §"],
		lang["Left backseat §"],
		lang["Right backseat §"],
		lang["Extra seat §"].." 1",
		lang["Extra seat §"].." 2",
		lang["Extra seat §"].." 3",
		lang["Extra seat §"].." 4",
		lang["Extra seat §"].." 5",
		lang["Extra seat §"].." 6",
		lang["Extra seat §"].." 7",
		lang["Extra seat §"].." 8",
		lang["Extra seat §"].." 9",
		lang["Extra seat §"].." 10",
		lang["Extra seat §"].." 11",
		lang["Extra seat §"].." 12"
	})
	local function entities_ite(i)
		local ents <const> = kek_entity.get_table_of_close_entity_type(i)
		local my_ped_coords <const> = player.get_player_coords(player.player_id())
		table.sort(ents, function(a, b) 
			return (essentials.get_distance_between(a, my_ped_coords) < essentials.get_distance_between(b, my_ped_coords)) 
		end)
		local i2 = 0
		local count = 0
		return function()
			repeat
				i2 = i2 + 1
			until not ents[i2] or
			(u.entity_manager_toggle.on
			and entity.is_an_entity(ents[i2])
			and ents[i2] ~= player.get_player_vehicle(player.player_id())
			and (not entity.is_entity_a_ped(ents[i2]) or not ped.is_ped_a_player(ents[i2]))
			and (get_names[i](entity.get_entity_model_hash(ents[i2])):lower()):find(filters[i], 1, true)
			and kek_entity.get_control_of_entity(ents[i2], 0))
			count = count + 1
			system.yield(0)
			return ents[i2], count
		end
	end

	for i = 1, 3 do
		menu.add_feature(lang["All entities of this type §"], "parent", entity_manager_parents[i].id, function(parent)
			if parent.child_count == 0 then
				menu.add_feature(lang["Delete §"], "action", parent.id, function(f)
					for Entity in entities_ite(i) do
						kek_entity.hard_remove_entity_and_its_attachments(Entity)
					end
				end)
				local exp_type = menu.add_feature(lang["Explode §"], "action_value_i", parent.id, function(f)
					for Entity in entities_ite(i) do
						essentials.use_ptfx_function(fire.add_explosion, entity.get_entity_coords(Entity), f.value, true, false, 0, player.get_player_ped(player.player_id()))
					end								
				end)
				exp_type.max, exp_type.min, exp_type.mod = 82, 0, 1
				exp_type.value = 29
				if i == 1 then
					local speed_set = menu.add_feature(lang["Set speed §"], "action_value_i", parent.id, function(f)
						for Entity in entities_ite(i) do
							vehicle.set_vehicle_forward_speed(Entity, f.value)
						end
					end)
					speed_set.max, speed_set.min, speed_set.mod = 1000, -1000, 25
					speed_set.value = 100
					menu.add_feature(lang["Toggle engine §"], "action_value_str", parent.id, function(f)
						for Entity in entities_ite(i) do
							if f.value == 0 then
								vehicle.set_vehicle_engine_health(Entity, -4000)
							elseif f.value == 1 then
								vehicle.set_vehicle_engine_health(Entity, 1000)
							end
						end
					end):set_str_data({
						lang["Kill engine §"],
						lang["Heal engine §"]
					})
				end
				if i == 2 then
					menu.add_feature(lang["Clear ped tasks §"], "action", parent.id, function()
						for Entity in entities_ite(i) do
							ped.clear_ped_tasks_immediately(Entity)
						end
					end)
				end
				teleport_all_in_front_of_player[i] = menu.add_feature(lang["Teleport in front of player §"], "action_value_str", parent.id, function(f)
					if player.is_player_valid(f.data[f.value + 1]) then
						for Entity, count in entities_ite(i) do
							entity.set_entity_coords_no_offset(Entity, location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(f.data[f.value + 1]), 10)))
							if count == 30 then
								break
							end
						end
					end
				end)
				if i == 1 or i == 2 then
					menu.add_feature(lang["Godmode §"], "value_str", parent.id, function(f)
						while f.on do
							for Entity in entities_ite(i) do
								if entity.get_entity_god_mode(Entity) ~= (f.value == 0) then
									kek_entity.modify_entity_godmode(Entity, f.value == 0)
								end
							end
							system.yield(0)
						end
						for Entity in entities_ite(i) do
							if entity.get_entity_god_mode(Entity) then
								kek_entity.modify_entity_godmode(Entity, false)
							end
						end
					end):set_str_data({
						lang["Give §"],
						lang["Remove §"]
					})
					menu.add_feature(lang["Resurrect §"], "action", parent.id, function()
						for Entity in entities_ite(i) do
							if entity.is_entity_dead(Entity) then
								if entity.is_entity_a_vehicle(Entity) then
									kek_entity.repair_car(Entity)
								elseif entity.is_entity_a_ped(Entity) then
									ped.resurrect_ped(Entity)
									ped.clear_ped_tasks_immediately(Entity)
								end
							end
						end
					end)
				end
			end
			local player_names <const> = {player.get_player_name(player.player_id())}
			teleport_all_in_front_of_player[i].data = {player.player_id()}
			for pid in essentials.players() do
				player_names[#player_names + 1] = player.get_player_name(pid)
				teleport_all_in_front_of_player[i].data[#teleport_all_in_front_of_player[i].data + 1] = pid
			end
			teleport_all_in_front_of_player[i]:set_str_data(player_names)
		end)

		menu.add_feature(lang["Filter §"].." < >", "action", entity_manager_parents[i].id, function(f)
			local input <const>, status <const> = keys_and_input.get_input(lang["Type in name of entity. §"], "", 128, 0)
			if status == 2 then
				return
			end
			filters[i] = input:lower()
			if input == "" then
				f.name = lang["Filter §"].." < >"
			else
				f.name = lang["Filter §"].." < "..input.." >"
			end
		end)

		for i2 = 1, number_of_features[i] do
			free_parents[i][#free_parents[i] + 1] = menu.add_feature("", "parent", entity_manager_parents[i].id, function(parent)
				if parent.child_count == 0 then
					local exp_type = menu.add_feature(lang["Explode §"], "action_value_i", parent.id, function(f)
						essentials.use_ptfx_function(fire.add_explosion, entity.get_entity_coords(parent.data.entity), f.value, true, false, 0, player.get_player_ped(player.player_id()))
					end)
					exp_type.max, exp_type.min, exp_type.mod = 82, 0, 1
					exp_type.value = 29
					if i == 1 then
						local speed_set = menu.add_feature(lang["Set speed §"], "action_value_i", parent.id, function(f)
							if kek_entity.get_control_of_entity(parent.data.entity) then
								entity.set_entity_max_speed(parent.data.entity, 45000)
								vehicle.set_vehicle_forward_speed(parent.data.entity, f.value)
							end
						end)
						speed_set.max, speed_set.min, speed_set.mod = 1000, -1000, 25
						speed_set.value = 100
						menu.add_feature(lang["Zero gravity §"], "toggle", parent.id, function(f)
							if kek_entity.get_control_of_entity(parent.data.entity) then
								entity.set_entity_gravity(parent.data.entity, not f.on)
							end
						end)
						set_yourself_in_seat[i] = menu.add_feature(lang["Set yourself in seat §"], "action_value_str", parent.id, function(f)
							local velocity <const> = entity.get_entity_velocity(parent.data.entity)
							ped.clear_ped_tasks_immediately(vehicle.get_ped_in_vehicle_seat(parent.data.entity, f.value - 1))
							ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), parent.data.entity, f.value - 1)
							entity.set_entity_velocity(parent.data.entity, velocity)
						end)
						menu.add_feature(lang["Toggle engine §"], "action_value_str", parent.id, function(f)
							if kek_entity.get_control_of_entity(parent.data.entity) then
								if f.value == 0 then
									vehicle.set_vehicle_engine_health(parent.data.entity, -4000)
								elseif f.value == 1 then
									vehicle.set_vehicle_engine_health(parent.data.entity, 1000)
								end
							end
						end):set_str_data({
							lang["Kill engine §"],
							lang["Heal engine §"]
						})
					end
					if i == 2 then
						menu.add_feature(lang["Clear ped tasks §"], "action", parent.id, function(f)
							ped.clear_ped_tasks_immediately(parent.data.entity)
						end)
					end
					if i == 1 or i == 2 then
						menu.add_feature(lang["Clone §"], "action", parent.id, function(f)
							if entity.is_entity_a_vehicle(parent.data.entity) then
								menyoo.clone_vehicle(parent.data.entity, kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8))
							elseif entity.is_entity_a_ped(parent.data.entity) then
								local Ped <const> = ped.clone_ped(parent.data.entity)
								kek_entity.teleport(Ped, kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8))
							end
						end)
						menu.add_feature(lang["Resurrect §"], "action", parent.id, function(f)
							if entity.is_entity_dead(parent.data.entity) and kek_entity.get_control_of_entity(parent.data.entity) then
								if entity.is_entity_a_vehicle(parent.data.entity) then
									kek_entity.repair_car(parent.data.entity)
								elseif entity.is_entity_a_ped(parent.data.entity) then
									ped.resurrect_ped(parent.data.entity)
									ped.clear_ped_tasks_immediately(parent.data.entity)
								end
							end
						end)
						menu.add_feature(lang["Godmode §"], "value_str", parent.id, function(f)
							while f.on and parent.on and entity.is_an_entity(parent.data.entity) do
								kek_entity.modify_entity_godmode(parent.data.entity, f.value == 0)
								system.yield(0)
							end
							f.on = false
						end):set_str_data({
							lang["Give §"],
							lang["Remove §"]
						})
					end
					menu.add_feature(lang["Delete §"], "action", parent.id, function(f)
						for pid in essentials.players(true) do
							if player.get_player_vehicle(pid) == parent.data.entity then
								kek_entity.remove_player_vehicle(pid)
								return
							end
						end
						kek_entity.hard_remove_entity_and_its_attachments(parent.data.entity)
					end)
					menu.add_feature(lang["Teleport to entity §"], "action", parent.id, function(f)
						kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), kek_entity.get_vector_relative_to_entity(parent.data.entity, 1))
					end)
					menu.add_feature(lang["Follow entity §"], "toggle", parent.id, function(f)
						while f.on and parent.on and entity.is_an_entity(parent.data.entity) do
							player.set_player_visible_locally(player.player_id(), true)
							kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), kek_entity.get_vector_relative_to_entity(parent.data.entity, -5) + v3(0, 0, 5))
							system.yield(0)
						end
						f.on = false
					end)
					teleport_in_front_of_player[i] = menu.add_feature(lang["Teleport in front of player §"], "action_value_str", parent.id, function(f)
						if player.is_player_valid(f.data[f.value + 1]) then
							kek_entity.teleport(parent.data.entity, location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(f.data[f.value + 1]), 10)))
							entity.set_entity_as_no_longer_needed(parent.data.entity)
						end
					end)
					menu.add_feature(lang["Copy to clipboard §"], "action_value_str", parent.id, function(f)
						if f.value == 0 then
							utils.to_clipboard(tostring(entity.get_entity_coords(parent.data.entity)))
						elseif f.value == 1 then
							local pos <const> = entity.get_entity_coords(parent.data.entity)
							utils.to_clipboard(essentials.round(pos.x)..", "..essentials.round(pos.y)..", "..essentials.round(pos.z))
						elseif f.value == 2 then
							utils.to_clipboard(tostring(entity.get_entity_model_hash(parent.data.entity)))
						elseif f.value == 3 then
							if i == 1 then
								utils.to_clipboard(vehicle_mapper.GetModelFromHash(entity.get_entity_model_hash(parent.data.entity)))
							elseif i == 2 then
								utils.to_clipboard(ped_mapper.get_model_from_hash(entity.get_entity_model_hash(parent.data.entity)))
							elseif i == 3 then
								utils.to_clipboard(object_mapper.GetModelFromHash(entity.get_entity_model_hash(parent.data.entity)))
							end
						elseif f.value == 4 then
							utils.to_clipboard(get_names[i](entity.get_entity_model_hash(parent.data.entity)))
						end
					end):set_str_data({
						lang["position §"],
						lang["pos without dec §"],
						lang["hash §"],
						lang["model name §"],
						lang["name §"]
					})
				end
				if i == 1 then
					set_yourself_in_seat[i]:set_str_data(table.move(seat_strings, 1, math.max(vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(parent.data.entity)), 1), 1, {}))
				end
				local player_names <const> = {player.get_player_name(player.player_id())} -- So that you are the first player in the str_data
				teleport_in_front_of_player[i].data = {player.player_id()}
				for pid in essentials.players() do
					player_names[#player_names + 1] = player.get_player_name(pid)
					teleport_in_front_of_player[i].data[#teleport_in_front_of_player[i].data + 1] = pid
				end
				teleport_in_front_of_player[i]:set_str_data(player_names)
			end)
			free_parents[i][#free_parents[i]].on = false
		end
	end

	u.entity_manager_toggle = menu.add_feature(lang["Entity manager §"], "toggle", u.entity_manager.id, function(f)
		while f.on do
			local my_ped_coords <const> = player.get_player_coords(player.player_id())
			for i = 1, 3 do -- 1 is vehicle, 2 is ped & 3 is object
				system.yield(0)
				for Entity, parent in pairs(parents_in_use[i]) do
					if entity.is_an_entity(Entity) then
						parent.name = parent.data.entity_name.." < "..math.ceil(my_ped_coords:magnitude(entity.get_entity_coords(Entity))).." >"
						parent.on = parent.data.lowercase_entity_name:find(filters[i], 1, true) ~= nil
					else
						parent.on = false
						local children <const> = parent.children
						for i = 1, #children do
							children[i].on = children[i].type == 2048
						end
						free_parents[i][#free_parents[i] + 1] = parent
						parents_in_use[i][Entity] = nil
					end
				end
				local entities <const> = kek_entity.get_table_of_close_entity_type(i)
				for i2 = 1, #entities do
					if not parents_in_use[i][entities[i2]] and entity.is_an_entity(entities[i2]) and (i ~= 2 or not ped.is_ped_a_player(entities[i2])) then
						local entity_name <const> = get_names[i](entity.get_entity_model_hash(entities[i2]))
						parents_in_use[i][entities[i2]] = free_parents[i][#free_parents[i]]
						free_parents[i][#free_parents[i]] = nil
						parents_in_use[i][entities[i2]].data = {
							entity_name = entity_name,
							lowercase_entity_name = entity_name:lower(),
							entity = entities[i2]
						}
						parents_in_use[i][entities[i2]].on = parents_in_use[i][entities[i2]].data.lowercase_entity_name:find(filters[i], 1, true) ~= nil
					end
				end
			end
		end
		for i = 1, 3 do
			for Entity, parent in pairs(parents_in_use[i]) do
				for _, child in pairs(parent.children) do
					child.on = child.type == 2048
				end
				parent.on = false
				free_parents[i][#free_parents[i] + 1] = parent
				parents_in_use[i][Entity] = nil
			end
		end
	end)
end

menu.add_player_feature(lang["Copy to clipboard §"], "action_value_str", u.player_misc_features, function(f, pid)
	if f.value == 0 then
		utils.to_clipboard(tostring(player.get_player_scid(pid)))
	elseif f.value == 1 then
		utils.to_clipboard(essentials.dec_to_ipv4(player.get_player_ip(pid)))
	elseif f.value == 2 then
		utils.to_clipboard(select(1, string.format("%x", player.get_player_host_token(pid))))
	elseif f.value == 3 then
		local str <const> = tostring(player.get_player_coords(pid)):match("v3%(([%d%-%.%,%s]+)%)")
		utils.to_clipboard(str)
	elseif f.value == 4 then
		local pos <const> = player.get_player_coords(pid)
		utils.to_clipboard(tostring(essentials.round(pos.x)..", "..essentials.round(pos.y)..", "..essentials.round(pos.z)))
	elseif f.value == 5 then
		utils.to_clipboard(tostring(entity.get_entity_model_hash(player.get_player_vehicle(pid))))
	elseif f.value == 6 then
		local brand = vehicle.get_vehicle_brand(player.get_player_vehicle(pid)) or ""
		if brand ~= "" then
			brand = brand.." "
		end
		utils.to_clipboard(brand..tostring(vehicle.get_vehicle_model(player.get_player_vehicle(pid))))
	elseif f.value == 7 then
		utils.to_clipboard(tostring(entity.get_entity_model_hash(player.get_player_ped(pid))))
	end
end):set_str_data({
	lang["Rid §"],
	lang["IP §"],
	lang["Host token §"],
	lang["Position §"],
	lang["Position without dec §"],
	lang["Vehicle hash §"],
	lang["Vehicle name §"],
	lang["Ped hash §"]
})

do
	local function create_profile_feature(...)
		local file_name <const> = ...
		if file_name ~= essentials.get_safe_feat_name(file_name) then
			return
		end
		menu.add_feature(essentials.get_safe_feat_name(file_name):gsub("%.ini$", ""), "action_value_str", u.profiles.id, function(f)
			if f.value == 0 then
				if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..f.name..".ini") then
					settings.initialize("scripts\\kek_menu_stuff\\profiles\\"..f.name..".ini")
					essentials.msg(lang["Successfully loaded §"].." "..f.name, 210, true)
				else
					essentials.msg(lang["Couldn't find file §"], 6, true)
				end
			elseif f.value == 1 then
				settings.save("scripts\\kek_menu_stuff\\profiles\\"..f.name..".ini")
				essentials.msg(lang["Saved §"].." "..f.name..".", 212, true)
			elseif f.value == 2 then
				if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..f.name..".ini") then
					io.remove(paths.kek_menu_stuff.."profiles\\"..f.name..".ini")
				end
				f.hidden = true
			elseif f.value == 3 then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in the name of the profile. §"], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
						goto skip
					end
					if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..input..".ini") then
						essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
						goto skip
					end
					if not input:find("[<>:\"/\\|%?%*]") then
						break
					else
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file("scripts\\kek_menu_stuff\\profiles\\", f.name, input, "ini")
				f.name = input
				essentials.msg(lang["Saved profile name. §"], 212, true)
			end
		end):set_str_data({
			lang["Load §"],
			lang["Save §"],
			lang["Delete §"],
			lang["Change name §"]
		})
	end

	 menu.add_feature(lang["Settings §"], "action_value_str", u.profiles.id, function(f)
	 	if f.value == 0 then
			settings.save("scripts\\kek_menu_stuff\\keksettings.ini")
			essentials.msg(lang["Settings saved! §"], 210, true)
		elseif f.value == 1 then
			local input, status
			while true do
				input, status = keys_and_input.get_input(lang["Type in the name of the profile. §"], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name. §"], 6, true)
					goto skip
				end
				if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..input..".ini") then
					essentials.msg(lang["Existing file found. Please choose another name. §"], 6, true)
					goto skip
				end
				if not input:find("[<>:\"/\\|%?%*]") then
					break
				else
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars: §"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", 6, true, 7)
				end
				::skip::
				system.yield(0)
			end
			essentials.create_empty_file(paths.kek_menu_stuff.."profiles\\"..input..".ini")
			settings.save("scripts\\kek_menu_stuff\\profiles\\"..input..".ini")
			create_profile_feature(input..".ini")
			essentials.msg(lang["Settings saved! §"], 210, true)
		end
	end):set_str_data({
		lang["save to default §"],
		lang["New profile §"]
	})

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."profiles", "ini")) do
		create_profile_feature(file_name)
	end
end

local function switch(...)
	local feature <const>, text <const> = ...
	if not feature.on then
		feature.on = true
		essentials.msg(lang["Hotkey:\\nTurned on §"].." "..text, 140, settings.in_use["Hotkeys #notifications#"]) 
	else
		feature.on = false
		essentials.msg(lang["Hotkey:\\nTurned off §"].." "..text, 140, settings.in_use["Hotkeys #notifications#"]) 
	end
end

settings.add_setting({
	setting_name = "Spawn vehicle #keybinding#", 
	setting = "off",
	func = function() 
		if kek_entity.spawn_car() ~= -1 then
			essentials.msg(lang["Hotkey:\\nSpawned vehicle. §"], 140, settings.in_use["Hotkeys #notifications#"])
		end
	end,
	feature_name = lang["Spawn vehicle §"]
})

settings.add_setting({
	setting_name = "Vehicle fly #keybinding#", 
	setting = "off",
	func = function()
		switch(u.vehicle_fly, lang["vehicle fly. §"])
	end,
	feature_name = lang["Vehicle fly §"]
})

settings.add_setting({
	setting_name = "Repair vehicle #keybinding#", 
	setting = "off",
	func = function()
		kek_entity.repair_car(player.get_player_vehicle(player.player_id()), true)
		essentials.msg(lang["Hotkey:\\nRepaired vehicle. §"], 140, settings.in_use["Hotkeys #notifications#"])
	end,
	feature_name = lang["Repair vehicle §"]
})

settings.add_setting({
	setting_name = "Max vehicle #keybinding#", 
	setting = "off", 
	func = function() 
		kek_entity.max_car(player.get_player_vehicle(player.player_id()), false, true)
		essentials.msg(lang["Hotkey:\\nMaxed vehicle. §"], 140, settings.in_use["Hotkeys #notifications#"])
	end,
	feature_name = lang["Max vehicle §"]
})

settings.add_setting({
	setting_name = "Change vehicle used for vehicle stuff #keybinding#", 
	setting = "off",
	func = function()
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in which car to use for vehicle stuff. §"], "", 128, 0)
		if status == 2 then
			return
		end
		settings.in_use["Default vehicle"] = input:lower()
	end,
	feature_name = lang["Set vehicle §"]
})

settings.add_setting({
	setting_name = "Clear owned entities #keybinding#", 
	setting = "off",
	func = function()
		kek_entity.entity_manager:update()
		for Entity, _ in pairs(essentials.deep_copy(kek_entity.entity_manager.entities)) do
			if Entity ~= player.get_player_vehicle(player.player_id()) and kek_entity.get_control_of_entity(Entity, 200) then
				kek_entity.hard_remove_entity_and_its_attachments(Entity)
			end
		end
		essentials.msg(lang["Cleared owned entities. §"], 140, true)
	end,
	feature_name = lang["Clear entities §"]
})

settings.add_setting({
	setting_name = "Teleport into personal vehicle #keybinding#", 
	setting = "off",
	func = function()
		local Vehicle = 0
		if globals.get_player_personal_vehicle(player.player_id()) ~= 0 and not entity.is_entity_dead(globals.get_player_personal_vehicle(player.player_id())) then
			Vehicle = globals.get_player_personal_vehicle(player.player_id())
		elseif player.get_player_vehicle(player.player_id()) ~= 0 and not entity.is_entity_dead(player.get_player_vehicle(player.player_id())) then
			Vehicle = player.get_player_vehicle(player.player_id())
		end
		if not player.is_player_in_any_vehicle(player.player_id()) then
			ped.clear_ped_tasks_immediately(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver))
		end
		ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Vehicle, enums.vehicle_seats.driver)
		essentials.msg(lang["Hotkey:\\nTeleported into personal vehicle. §"], 140, settings.in_use["Hotkeys #notifications#"])
	end,
	feature_name = lang["Tp personal vehicle §"]
})

settings.add_setting({
	setting_name = "Send clipboard to chat #keybinding#", 
	setting = "off",
	func = function()
		essentials.send_message(utils.from_clipboard())
	end,
	feature_name = lang["Clipboard to chat §"]
})

settings.add_setting({
	setting_name = "Teleport forward #keybinding#", 
	setting = "off",
	func = function()
		local velocity <const> = entity.get_entity_velocity(essentials.get_most_relevant_entity(player.player_id()))
		local speed <const> = entity.get_entity_speed(essentials.get_most_relevant_entity(player.player_id()))
		kek_entity.teleport(
			essentials.get_most_relevant_entity(player.player_id()), 
			location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(essentials.get_most_relevant_entity(player.player_id()), 10), true)
		)
		if player.is_player_in_any_vehicle(player.player_id()) then
			vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()), speed)
		else
			entity.set_entity_velocity(essentials.get_most_relevant_entity(player.player_id()), velocity)
		end
		essentials.msg(lang["Hotkey:\\nTeleported forward. §"], 140, settings.in_use["Hotkeys #notifications#"])
	end,
	feature_name = lang["Teleport forward §"]
})

settings.toggle["Hotkeys"] = menu.add_feature(lang["Hotkey mode §"], "value_str", u.hotkey_settings.id, function(f)
	if f.on then
		local groups <const> = essentials.const({
			[0] = 0,
			[1] = 2
		})
		local hotkey_stuff = {}
		settings.hotkey_control_keys_update = true
		local group = groups[f.value]
		while f.on do
			system.yield(0)
			if settings.hotkey_control_keys_update or group ~= groups[f.value] then
				group = groups[f.value]
				hotkey_stuff = {}
				for _, properties in pairs(settings.general) do
					if properties.setting_name:find("#keybinding#", 1, true) and settings.in_use[properties.setting_name] ~= "off" then
						local temp <const> = {}
						if groups[f.value] == 0 then
							for hotkey in settings.in_use[properties.setting_name]:gmatch("([%w_%-%s]+)%+?") do
								temp[#temp + 1] = keys_and_input.get_keyboard_key_control_int_from_name(hotkey)
							end
						else
							for hotkey in settings.in_use[properties.setting_name]:gmatch("([%w_%-%s]+)%+?") do
								temp[#temp + 1] = keys_and_input.get_controller_key_control_int_from_name(hotkey)
							end
						end
						if #temp > 0 then
							hotkey_stuff[#hotkey_stuff + 1] = {keys = temp, func = properties.func}
						end
					end
				end
				table.sort(hotkey_stuff, function(a, b) return #a.keys > #b.keys end)
				hotkey_stuff = essentials.const_all(hotkey_stuff)
				settings.hotkey_control_keys_update = false
			end
			for i = 1, #hotkey_stuff do
				if keys_and_input.is_table_of_gta_keys_all_pressed(hotkey_stuff[i].keys, groups[f.value]) then
					hotkey_stuff[i].func()
					keys_and_input.do_table_of_gta_keys(hotkey_stuff[i].keys, groups[f.value], 550)
					while keys_and_input.is_table_of_gta_keys_all_pressed(hotkey_stuff[i].keys, groups[f.value]) do
						hotkey_stuff[i].func()
						system.yield(80)
						for i2 = 1, #hotkey_stuff do
							if #hotkey_stuff[i].keys < #hotkey_stuff[i2].keys and keys_and_input.is_table_of_gta_keys_all_pressed(hotkey_stuff[i2].keys, groups[f.value]) then
								goto out_of_loop
							end
						end
					end
					::out_of_loop::
				end
			end
		end
	end
end)
settings.valuei["Hotkey mode"] = settings.toggle["Hotkeys"]
settings.valuei["Hotkey mode"]:set_str_data({
	lang["keyboard §"],
	lang["controller §"]				
})

o.search_features = menu.add_feature(lang["Search §"], "parent", u.kekMenu, function(f)
	if f.child_count > 1 then
		for _, fake_feat in pairs(f.children) do
			if type(fake_feat.data) == "table" and type(fake_feat.data.real_feat) == "userdata" then
				if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
					fake_feat.on = fake_feat.data.real_feat.on
				end
				if fake_feat.value then
					fake_feat.value = fake_feat.data.real_feat.value
				end
				fake_feat.name = fake_feat.data.real_feat.name
			end
		end
	end
end)
o.search_features.data = essentials.const({
	feat_logic = function(...)
		local real_feat, fake_feat = ...
		if essentials.FEATURE_ID_MAP[fake_feat.type] == "action" then
			real_feat.on = true
		end
		if fake_feat.value then
			if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
				real_feat.on = true
				real_feat.value = fake_feat.value
				local real_value = real_feat.value
				local fake_value = fake_feat.value
				while fake_feat.on and real_feat.on do
					system.yield(0)
					if fake_feat.value ~= fake_value then
						real_feat.value = fake_feat.value
						fake_value = fake_feat.value
						real_value = fake_feat.value
					elseif real_feat.value ~= real_value then
						fake_feat.value = real_feat.value
						fake_value = real_feat.value
						real_value = real_feat.value
					end
				end
				fake_feat.on = false
				real_feat.on = false
			else
				real_feat.value = fake_feat.value
				if keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
					real_feat.on = true
				end
			end
		elseif essentials.FEATURE_ID_MAP[fake_feat.type] == "toggle" then
			real_feat.on = true
			while fake_feat.on and real_feat.on do
				system.yield(0)
			end
			real_feat.on = false
			fake_feat.on = false
		end
	end,
	player_feat_logic = function(...)
		local real_feat, 
		fake_feat,
		pid <const> = ...
		if essentials.FEATURE_ID_MAP[fake_feat.type] == "action" then
			menu.get_player_feature(real_feat.id).feats[pid].on = true
		end
		if fake_feat.value then
			if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
				menu.get_player_feature(real_feat.id).feats[pid].on = true
				menu.get_player_feature(real_feat.id).feats[pid].value = fake_feat.value
				local real_value = menu.get_player_feature(real_feat.id).feats[pid].value
				local fake_value = fake_feat.value
				while fake_feat.on and menu.get_player_feature(real_feat.id).feats[pid].on do
					system.yield(0)
					if fake_feat.value ~= fake_value then
						menu.get_player_feature(real_feat.id).feats[pid].value = fake_feat.value
						fake_value = fake_feat.value
						real_value = fake_feat.value
					elseif menu.get_player_feature(real_feat.id).feats[pid].value ~= real_value then
						fake_feat.value = menu.get_player_feature(real_feat.id).feats[pid].value
						fake_value = menu.get_player_feature(real_feat.id).feats[pid].value
						real_value = menu.get_player_feature(real_feat.id).feats[pid].value
					end
				end
				fake_feat.on = false
				menu.get_player_feature(real_feat.id).feats[pid].on = false
			else
				real_feat.value = fake_feat.value
				if keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
					real_feat.on = true
				end
			end
		elseif essentials.FEATURE_ID_MAP[fake_feat.type] == "toggle" then
			real_feat.on = true
			while fake_feat.on and real_feat.on do
				system.yield(0)
			end
			real_feat.on = false
			fake_feat.on = false
		end
	end,
	set_feat_properties = function(...)
		local real_feat <const>,
		fake_feat,
		real_feat_player_if_relevant <const> = ...
		if fake_feat.value then
			if essentials.FEATURE_ID_MAP[fake_feat.type]:find("str", 1, true) then
				fake_feat:set_str_data((real_feat_player_if_relevant or real_feat):get_str_data())
			else
				fake_feat.min = real_feat.min
				fake_feat.max = real_feat.max
				fake_feat.mod = real_feat.mod
			end
			fake_feat.value = real_feat.value
		end
		if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
			fake_feat.on = real_feat.on
		end
	end
})

menu.add_feature(lang["Search §"], "action", o.search_features.id, function()
	local input, status <const> = keys_and_input.get_input(lang["Type in name of a player or regular feature. §"], "", 128, 0)
	if status == 2 then
		return
	end
	input = input:lower()
	for _, fake_feat in pairs(o.search_features.children) do
		if fake_feat.data ~= "isn't searchable" then
			fake_feat.data = "isn't searchable"
			if fake_feat.type == 2048 and fake_feat.child_count > 0 then
				for _, child in pairs(fake_feat.children) do
					if child.data ~= "isn't searchable" then
						child.data = "isn't searchable"
						essentials.delete_feature(child.id)
					end
				end
			end
			essentials.delete_feature(fake_feat.id)
		end
	end
	local map <const> = essentials.const_all({
		feats = essentials.deep_copy(essentials.feats),
		player_feats = essentials.deep_copy(essentials.player_feats)
	})
	for type_of_feature, features in pairs(map) do
		for _, FEAT in pairs(features) do
			local real_feat
			if type_of_feature == "player_feats" then
				FEAT = menu.get_player_feature(FEAT)
				real_feat = FEAT.feats[0]
			else
				real_feat = FEAT
			end
			if real_feat.type ~= 2048
			and not real_feat.hidden
			and real_feat.data ~= "isn't searchable"
			and (not essentials.FEATURE_ID_MAP[real_feat.type]:find("str", 1, true) or FEAT:get_str_data())
			and real_feat.name:lower():find(input, 1, true) then
				if type_of_feature == "player_feats" then
					menu.add_feature(menu.get_player_feature(real_feat.id).feats[0].name, "parent", o.search_features.id, function(fake_feat)
						if fake_feat.child_count == 0 then
							for pid = 0, 31 do
								local feat_type = essentials.FEATURE_ID_MAP[menu.get_player_feature(real_feat.id).feats[pid].type]
								if feat_type:find("action", 1, true) and not feat_type:find("auto", 1, true) and feat_type ~= "action" then
									feat_type = "auto"..feat_type
								end
								local fake_feat = menu.add_feature(player.get_player_name(pid) or "", feat_type, fake_feat.id, function(fake_feat)
									o.search_features.data.player_feat_logic(menu.get_player_feature(real_feat.id).feats[pid], fake_feat, pid)
								end)
								fake_feat.hidden = not player.is_player_valid(pid)
								o.search_features.data.set_feat_properties(menu.get_player_feature(real_feat.id).feats[pid], fake_feat, menu.get_player_feature(real_feat.id))
							end
						else
							for pid, child in pairs(fake_feat.children) do
								child.hidden = not player.is_player_valid(pid - 1)
								if player.is_player_valid(pid - 1) then
									child.name = player.get_player_name(pid - 1)
								end
								if not essentials.FEATURE_ID_MAP[child.type]:find("action", 1, true) then
									child.on = menu.get_player_feature(real_feat.id).feats[pid - 1].on
								end
								if child.value then
									child.value = menu.get_player_feature(real_feat.id).feats[pid - 1].value
								end
							end
						end
					end)
				else
					local feat_type = essentials.FEATURE_ID_MAP[real_feat.type]
					if feat_type:find("action", 1, true) and not feat_type:find("auto", 1, true) and feat_type ~= "action" then
						feat_type = "auto"..feat_type
					end
					local fake_feat = menu.add_feature(real_feat.name, feat_type, o.search_features.id, function(fake_feat)
						o.search_features.data.feat_logic(real_feat, fake_feat)
					end)
					o.search_features.data.set_feat_properties(real_feat, fake_feat)
					fake_feat.data = real_feat
				end
			end
		end
	end
end).data = "isn't searchable"

for _, properties in pairs(settings.general) do
	if properties.setting_name:find("#keybinding#", 1, true) then
		settings.hotkey_features[#settings.hotkey_features + 1] = essentials.const({properties.feature_name, menu.add_feature(properties.feature_name..": ", "action_value_str", u.hotkey_settings.id, function(f)
			if f.value < 3 then
				keys_and_input.do_vk(10000, keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect"))
				local hotkey_table <const> = {}
				local time <const> = utils.time_ms() + 30000
				for _ = 1, f.value + 1 do
					essentials.msg(lang["Press key to set to hotkey. §"], 212, true)
					local keys
					if settings.valuei["Hotkey mode"].value == 1 then
						keys = keys_and_input.CONTROLLER_KEYS
					else
						keys = keys_and_input.KEYBOARD_KEYS
					end
					while time > utils.time_ms() do
						system.yield(0)
						for _, key in pairs(keys) do
							if controls.is_control_pressed(key.group_id, key.key_id) then
								keys_and_input.do_key(key.group_id, key.key_id, 15000)
								hotkey_table[#hotkey_table + 1] = key.name
								goto out_of_loop
							end
						end
					end
					::out_of_loop::
				end
				if #hotkey_table == f.value + 1 then
					settings.in_use[properties.setting_name] = table.concat(hotkey_table, "+")
					f.name = properties.feature_name..": "..table.concat(hotkey_table, "+")
					settings.hotkey_control_keys_update = true
					essentials.msg(lang["Changed §"].." "..properties.feature_name.." "..lang["to §"].." "..table.concat(hotkey_table, "+")..".", 212, true)
				else
					essentials.msg(lang["Hotkey change timed out or failed. §"], 6, true)
				end
			elseif f.value == 3 then
				settings.in_use[properties.setting_name] = "off"
				essentials.msg(lang["Turned off the hotkey:\\n §"].." "..properties.feature_name..".", 210, true)
				f.name = properties.feature_name..": "..lang["Turned off §"]
				settings.hotkey_control_keys_update = true
			end
		end), properties.setting_name})
		settings.hotkey_features[#settings.hotkey_features][2]:set_str_data({
			lang["1 key §"],
			lang["2 keys §"],
			lang["3 keys §"],
			lang["Turn off §"]
		})
	end
end

settings.initialize("scripts\\kek_menu_stuff\\keksettings.ini")

essentials.listeners["exit"]["main_exit"] = event.add_event_listener("exit", function()
	kek_entity.entity_manager:update()
	for Entity, _ in pairs(essentials.deep_copy(kek_entity.entity_manager.entities)) do
		if Entity ~= player.get_player_vehicle(player.player_id()) then
			ui.remove_blip(ui.get_blip_from_entity(Entity))
			if network.has_control_of_entity(Entity) and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
				entity.set_entity_as_mission_entity(Entity, false, true)
				entity.delete_entity(Entity)
			end
		end
	end
	for name, id_list in pairs(essentials.listeners) do
		for _, id in pairs(id_list) do
			event.remove_event_listener(name, id)
		end
	end
	for _, id in pairs(essentials.nethooks) do
		hook.remove_net_event_hook(id)
	end
end)

essentials.msg(lang["Successfully loaded Kek's menu. §"], 140, true)