// -----------------
// < DEFAULT STOCK >
// -----------------

/obj/item/gun/energy/custom
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'

	weapon_weight = WEAPON_LIGHT
	trigger_guard = TRIGGER_GUARD_NORMAL
	
	burst_size = 1
	fire_rate = 2.5
	fire_delay = 0
	firing_burst = 1
	spread = 10
	dual_wield_spread = 24
	randomspread = 1

	can_flashlight = TRUE
		
	var/disassembled = TRUE
	var/obj/item/payload/payloadA
	var/obj/item/mechanism/mechanism
	//firing pin
	//power cell
	var/multiplePayloads = FALSE
	var/obj/item/payload/payloadB
	
/obj/item/gun/energy/custom/Initialize()
	..()
	if (cell)
		QDEL_NULL(cell)
	
/obj/item/gun/energy/custom/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot
	
/obj/item/gun/energy/custom/proc/tryassemble(mob/living/user)
	ammo_type = list(/obj/item/ammo_casing/energy)
	disassembled = FALSE
	return TRUE
	
/obj/item/gun/energy/custom/recharge_newshot(no_cyborg_drain)
	if (!ammo_type || !cell || disassembled)
		return
	if(!chambered)
		var/obj/item/ammo_casing/energy/AC = GetAmmoType()
		if(cell.charge >= AC.e_cost)
			chambered = AC
			
			chambered.range_mult = mechanism.range_mult
			chambered.damage_mult = mechanism.damage_mult
			//CUSTOMIZE CHAMBER ????????????????????
			
			if(!chambered.BB)
				chambered.newshot()
	
/obj/item/gun/energy/custom/proc/canacceptpart(obj/item/part)
	return TRUE

/obj/item/gun/energy/custom/attack_self(mob/living/user as mob)
	if (disassembled)
		//unload all parts and start over
		payload.forceMove(loc)
		payload.gun_remove(user)
		
		mechanism.forceMove(loc)
		mechanism.gun_remove(user)
		
		cell.forceMove(loc)
		cell=null
		
		pin.forceMove(loc)
		pin=null
		
	return

/obj/item/gun/energy/custom/proc/GetAmmoType()
	return ammo_type[select]
	
//ATTACK SCREWDRIVER ACT
	//CHECK ALL PARTS
	
// -------------------
// < DEFAULT PAYLOAD >
// -------------------

/obj/item/payload
	name = "electronic firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one."
	icon = 'icons/obj/device.dmi'
	icon_state = "firing_pin"
	item_state = "pen"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("poked")
	var/obj/item/gun/energy/custom/parent
	var/obj/item/ammo_casing/casting = obj/item/ammo_casing/energy/custom
	
/obj/item/payload/New(newloc)
	..()
	if(istype(newloc, /obj/item/gun/energy/custom))
		gun = newloc

/obj/item/payload/proc/get_casing()
	return casting
	
/obj/item/payload/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(istype(target, /obj/item/gun/energy/custom))
			var/obj/item/gun/energy/custom/G = target
			if(!G.canacceptpart(src) )
				to_chat(user, "<span class ='notice'>[src] cannot fit into [G].</span>")
			else if (!G.disassembled)
				to_chat(user, "<span class ='notice'>[G] cannot be modified.</span>")
				return
			else if(!G.payload)
				if(!user.temporarilyRemoveItemFromInventory(src))
					return
				gun_insert(user, G)
				to_chat(user, "<span class ='notice'>You insert [src] into [G].</span>")
			else
				to_chat(user, "<span class ='notice'>This firearm already has a firing pin installed.</span>")

/obj/item/payload/proc/gun_insert(mob/living/user, obj/item/gun/G)
	gun = G
	forceMove(gun)
	gun.payload = src
	return

/obj/item/payload/proc/gun_remove(mob/living/user)
	gun.payload = null
	gun = null
	return

// >>> AMMO <<<

/obj/item/ammo_casing/energy/custom
	projectile_type = obj/item/projectile/beam/laser
	e_cost = 100	//always constant
	pellets = 0
	variance = 0
	var/damage_mult = 1
	var/range_mult = 1
	
/obj/item/ammo_casing/energy/custom/proc/newshot() 
	if(!BB)
		BB = new projectile_type(src, src)
		BB.damage = BB.damage * damage_mult
		BB.range = BB.range * range_mult
		
// ---------------------
// < DEFAULT MECHANISM >
// ---------------------

/obj/item/mechanism
	name = "electronic firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one."
	icon = 'icons/obj/device.dmi'
	icon_state = "firing_pin"
	item_state = "pen"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("poked")
	var/obj/item/gun/energy/custom/parent
	
	var/damage_mult = 1
	var/range_mult = 1
	var/frate_mult = 1
	var/fcost_mult = 1
	
/obj/item/mechanism/New(newloc)
	..()
	if(istype(newloc, /obj/item/gun/energy/custom))
		gun = newloc
	
/obj/item/mechanism/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(istype(target, /obj/item/gun/energy/custom))
			var/obj/item/gun/energy/custom/G = target
			if(!G.canacceptpart(src) )
				to_chat(user, "<span class ='notice'>[src] cannot fit into [G].</span>")
			else if (!G.disassembled)
				to_chat(user, "<span class ='notice'>[G] cannot be modified.</span>")
				return
			else if(!G.mechanism)
				if(!user.temporarilyRemoveItemFromInventory(src))
					return
				gun_insert(user, G)
				to_chat(user, "<span class ='notice'>You insert [src] into [G].</span>")
			else
				to_chat(user, "<span class ='notice'>This firearm already has a firing pin installed.</span>")

/obj/item/mechanism/proc/gun_insert(mob/living/user, obj/item/gun/G)
	gun = G
	forceMove(gun)
	gun.mechanism = src
	return

/obj/item/mechanism/proc/gun_remove(mob/living/user)
	gun.mechanism = null
	gun = null
	return

		
// ----------------
// < DEFAULT CORE >
// ----------------

/obj/item/stock_parts/cell/gun_core
	name = "gun core"
	desc = "A standard power cell, commonly seen in high-end portable microcomputers or low-end laptops."
	icon = 'icons/obj/module.dmi'
	icon_state = "cell_mini"
	w_class = WEIGHT_CLASS_TINY
	maxcharge = 1000
	
/obj/item/stock_parts/cell/gun_core/New(newloc)
	..()
	if(istype(newloc, /obj/item/gun/energy/custom))
		gun = newloc
	
/obj/item/stock_parts/cell/gun_core/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(istype(target, /obj/item/gun/energy/custom))
			var/obj/item/gun/energy/custom/G = target
			if(!G.canacceptpart(src) )
				to_chat(user, "<span class ='notice'>[src] cannot fit into [G].</span>")
			else if (!G.disassembled)
				to_chat(user, "<span class ='notice'>[G] cannot be modified.</span>")
				return
			else if(!G.cell)
				if(!user.temporarilyRemoveItemFromInventory(src))
					return
				gun_insert(user, G)
				to_chat(user, "<span class ='notice'>You insert [src] into [G].</span>")
			else
				to_chat(user, "<span class ='notice'>This firearm already has a firing pin installed.</span>")

/obj/item/stock_parts/cell/gun_core/proc/gun_insert(mob/living/user, obj/item/gun/G)
	gun = G
	forceMove(gun)
	gun.cell = src
	return

/obj/item/stock_parts/cell/gun_core/proc/gun_remove(mob/living/user)
	gun.cell = null
	gun = null
	return