return PlaceObj('ModDef', {
	'title', "Smarter Drones",
	'description', "Improves Drone AI in small but crucial ways.\r\n\r\nFirst improvement:\r\n- when dumping Waste Rock, drones carry it to the closest available Dumping Site or pile (unlike round-robin in the base game). This is an enormous efficiency boost if you have more than one source of waste rock in range of one drone controller.\r\n\r\nCompatibility:\r\n- does not modify any game objects, so should be compatible with almost any mods, and can be added/removed to existing saves\r\n- modifies some functions in Drone and DroneControl classes, could break after game updates",
	'image', "preview.png",
	'last_changes', "Version bump for Sagan patch, no changes.",
	'id', "Yc1438O",
	'steam_id', "1358005563",
	'author', "casual",
	'version', 16,
	'lua_revision', 234560,
	'code', {"Code/Drone.lua","Code/DroneHub.lua"},
	'saved', 1538071283,
	'TagOther', true,
})