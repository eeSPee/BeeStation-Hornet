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
		/obj/item/extinguisher
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
	desc = "If you read this, contact admins for a complimentary antag token, and never speak of it again."
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	module_type = /obj/item/robot_module/alien
	var/point_cost = 1
	var/addmodules = list()

/obj/item/borg/upgrade/adaptation/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)	
		if (R.adaption_points + point_cost <= 3)	//Hard coded limit
			return FALSE
	
		for(var/obj/item/borg/upgrade/adaptation/SPEC in R.upgrades)
			if (SPEC == src)	//modules already present
				to_chat(user, "<span class='warning'>This unit is already equipped with a [src].</span>")
				return FALSE

			//in case of different module, change entirely
			SPEC.deactivate(R, user)
			R.upgrades -= SPEC
			qdel(SPEC)


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
		//Remove existing modules indiscriminately
		for(var/module in src.addmodules)
			var/item = locate(module) in R
			if (item)
				R.module.remove_module(item, TRUE)

//	----------------------------------
//	>> ADAPTIVE MODULES ENGINEERING <<
//	----------------------------------