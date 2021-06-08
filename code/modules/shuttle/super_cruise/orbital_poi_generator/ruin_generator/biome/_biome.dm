//	---- BIOMES GENERATION FOR RUINS ---

/datum/biome
	var/name = "biome"
	var/structure_damage_prob = 0
	var/floor_break_prob = 0
	
	// - ATMOSPHERE -
	var/trash_chance = 0
	var/list/floortrash = list()		
	var/lamp_chance = 0
	var/list/directional_walltrash = list()	
	var/wall_chance = 0
	var/list/nondirectional_walltrash = list()
	
	// - MOBS -
	var/mob_chance = 0
	var/list/mob_list = list()		