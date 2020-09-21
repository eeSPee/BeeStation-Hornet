/*

CARRION MOB

3 sized
	small - escape
	medium - hunting
	large - combat
	
Tentacle
	click push
	ctrlclick pull

*/


/mob/living/simple_animal/hostile/hivebot
	name = "hivebot"
	desc = "A small robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	gender = NEUTER
	mob_biotypes = list(MOB_ROBOTIC)
	health = 15
	maxHealth = 15
	armour_penetration = 40
	melee_damage = 40
	speed = 5
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler = VENTCRAWLER_ALWAYS
	see_in_dark = 8
	move_to_delay = 5	
	do_footstep = TRUE
	obj_damage = 80
	melee_damage = 35
	speak_emote = list("states")
	friendly = "stares down"
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	ranged = TRUE
	projectilesound = 'sound/weapons/gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet
	faction = list("neutral")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	deathmessage = "screeches as its wings turn to dust and it collapses on the floor, life estinguished."
	hardattacks = TRUE	
	//butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_NORMAL
	pull_force = MOVE_FORCE_NORMAL
	var/size = 2
		// 1 - escapist
		// 2 - hunter
		// 3 - fighter
	var/obj/item/voreditem

/mob/living/simple_animal/hostile/hivebot/Initialize()
	. = ..()	
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/spacedragon/repulse_action = new /obj/effect/proc_holder/spell/aoe_turf/repulse/spacedragon(src)
	repulse_action.action.Grant(src)
	mob_spell_list += repulse_action
	
	
/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	do_sparks(3, TRUE, src)
	..(1)
	
	
/mob/living/simple_animal/hostile/hivebot/proc/grow()
	return
	
/mob/living/simple_animal/hostile/hivebot/proc/shrink()
	return




/obj/item/projectile/tentacle
	name = "tentacle"
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/weapons/thudswoosh.ogg'
	var/chain
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it

/obj/item/projectile/tentacle/Initialize()
	source = loc
	. = ..()

/obj/item/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()

/obj/item/projectile/tentacle/proc/reset_throw(mob/living/carbon/human/H)
	return

/obj/item/projectile/tentacle/proc/tentacle_grab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		if(H.get_active_held_item() && !H.get_inactive_held_item())
			H.swap_hand()
		if(H.get_active_held_item())
			return
		C.grabbedby(H)
		C.grippedby(H, instant = TRUE) //instant aggro grab

/obj/item/projectile/tentacle/proc/tentacle_stab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		for(var/obj/item/I in H.held_items)
			if(I.is_sharp())
				C.visible_message("<span class='danger'>[H] impales [C] with [H.p_their()] [I.name]!</span>", "<span class='userdanger'>[H] impales you with [H.p_their()] [I.name]!</span>")
				C.apply_damage(I.force, BRUTE, BODY_ZONE_CHEST)
				H.do_item_attack_animation(C, used_item = I)
				H.add_mob_blood(C)
				playsound(get_turf(H),I.hitsound,75,1)
				return

/obj/item/projectile/tentacle/on_hit(atom/target, blocked = FALSE)
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(isitem(target))
		var/obj/item/I = target
		if(!I.anchored)
			to_chat(firer, "<span class='notice'>You pull [I] towards yourself.</span>")
			H.throw_mode_on()
			I.throw_at(H, 10, 2)
			. = BULLET_ACT_HIT

	else if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)//avoid double hits
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				var/firer_intent = INTENT_HARM
				var/mob/M = firer
				if(istype(M))
					firer_intent = M.a_intent
				switch(firer_intent)
					if(INTENT_HELP)
						C.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
						C.throw_at(get_step_towards(H,C), 8, 2)
						return BULLET_ACT_HIT

					if(INTENT_DISARM)
						var/obj/item/I = C.get_active_held_item()
						if(I)
							if(C.dropItemToGround(I))
								C.visible_message("<span class='danger'>[I] is yanked off [C]'s hand by [src]!</span>","<span class='userdanger'>A tentacle pulls [I] away from you!</span>")
								on_hit(I) //grab the item as if you had hit it directly with the tentacle
								return BULLET_ACT_HIT
							else
								to_chat(firer, "<span class='danger'>You can't seem to pry [I] off [C]'s hands!</span>")
								return BULLET_ACT_BLOCK
						else
							to_chat(firer, "<span class='danger'>[C] has nothing in hand to disarm!</span>")
							return BULLET_ACT_HIT

					if(INTENT_GRAB)
						C.visible_message("<span class='danger'>[L] is grabbed by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
						C.throw_at(get_step_towards(H,C), 8, 2, H, TRUE, TRUE, callback=CALLBACK(src, .proc/tentacle_grab, H, C))
						return BULLET_ACT_HIT

					if(INTENT_HARM)
						C.visible_message("<span class='danger'>[L] is thrown towards [H] by a tentacle!</span>","<span class='userdanger'>A tentacle grabs you and throws you towards [H]!</span>")
						C.throw_at(get_step_towards(H,C), 8, 2, H, TRUE, TRUE, callback=CALLBACK(src, .proc/tentacle_stab, H, C))
						return BULLET_ACT_HIT
			else
				L.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
				L.throw_at(get_step_towards(H,L), 8, 2)
				. = BULLET_ACT_HIT

/obj/item/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()