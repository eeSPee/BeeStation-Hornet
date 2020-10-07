//	------------------------
//	>> MODULE AND UPGRADE <<
//	------------------------

/obj/item/robot_module/alien
	name = "Adaptive"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/analyzer,
		)
	emag_modules = list(/obj/item/melee/transforming/energy/sword/cyborg)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/abstraction_crystal,
		/obj/item/clockwork/replica_fabricator,
		/obj/item/stack/tile/brass/cyborg,
		/obj/item/twohanded/clockwork/brass_spear)
	moduleselect_icon = "standard"
	hat_offset = -3

/obj/item/borg/upgrade/transform/alien
	name = "borg module picker (Adaptive)"
	desc = "Allows you to to turn a cyborg into a clown, honk."
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/alien

//	---------------------------
//	>> ADAPTIVE MODULES BASE <<
//	---------------------------

/obj/item/borg/upgrade/adaptation
	name = "Speciality Module"
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	module_type = /obj/item/robot_module/alien
	var/point_cost = 1
	var/addmodules = list()

/obj/item/borg/upgrade/adaptation/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)	
		if (R.adaption_points + point_cost <= 5)	//Hard coded limit
			return FALSE
	
		for(var/obj/item/borg/upgrade/adaptation/SPEC in R.upgrades)
			if (SPEC == src)	//modules already present
				to_chat(user, "<span class='warning'>This unit is already equipped with a [src].</span>")
				return FALSE
	
		R.adaption_points = R.adaption_points + point_cost
		for(var/module in src.addmodules)
			var/item = locate(module) in R
			if (!item)
				item = new(R.module)
				R.module.basic_modules += item
				R.module.add_module(item, FALSE, TRUE)
	return .

/obj/item/borg/upgrade/adaptation/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)		
		R.adaption_points = R.adaption_points + point_cost
		//Remove existing modules indiscriminately
		for(var/module in src.addmodules)
			var/item = locate(module) in R
			if (item)
				R.module.remove_module(item, TRUE)
	return .

//	------------------------------
//	>> ADAPTIVE MODULES MEDICAL <<
//	------------------------------

/obj/item/borg/upgrade/adaptation/chemistry
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe
		)
		
/obj/item/borg/upgrade/adaptation/surgery
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/organ_storage
		)
		
/obj/item/borg/upgrade/adaptation/paramedic
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/reagent_containers/borghypo/epi,
		)
		
//	----------------------------------
//	>> ADAPTIVE MODULES ENGINEERING <<
//	----------------------------------
		
/obj/item/borg/upgrade/adaptation/construction_walls
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/iron/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/lightreplacer/cyborg,
		)
		
/obj/item/borg/upgrade/adaptation/construction_floors
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/pipe_dispenser,
		/obj/item/analyzer,
		/obj/item/t_scanner,
		/obj/item/stack/cable_coil/cyborg,
		)
		
/obj/item/borg/upgrade/adaptation/tools
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/borg/sight/meson,
		)
		
//	------------------------------------
//	>> ADAPTIVE MODULES CROWD CONTROL <<
//	------------------------------------
		
/obj/item/borg/upgrade/adaptation/melee
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/reagent_containers/spray/pepper,
		)
		
/obj/item/borg/upgrade/adaptation/ranged
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/projectile_dampen,
		)
		
//	------------------------------
//	>> ADAPTIVE MODULES SERVICE <<
//	------------------------------
		
/obj/item/borg/upgrade/adaptation/cleaning
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/melee/flyswatter,
		/obj/item/paint/paint_remover,
		)
		
/obj/item/borg/upgrade/adaptation/janitor
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/soap/nanotrasen,
		/obj/item/mop/cyborg,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/reagent_containers/spray/cyborg_drying,
		)
		
/obj/item/borg/upgrade/adaptation/artistic
	name = "XXX"
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	point_cost = 1
	addmodules = list(
		/obj/item/paint/anycolor,
		/obj/item/instrument/piano_synth,
		/obj/item/toy/crayon/spraycan/borg,
		)