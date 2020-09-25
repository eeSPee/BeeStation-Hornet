/*

BLOB/DRAGON HYBRID IDEA
Insipred by Carrion Game

The main jist is, monstruous antag that can change its form to suit it's environment. Attacks people at range with tentacles. It can't heal directly like spess dragon, but fullheals when changing forms.
Has 3 forms:
	The small form can ventcrawl and stun people mostly.
	The medium form is good at hunting people and 1 on 1 combat.
	The largest form is the slowest and hardest to maintain. Good at fighting multiple people.

Besides it's basic attacks, it has 3 ranged attacks
	Basic tentacle deals knockback
	Shift Click tentacle is good at draging people around
	Ctrl Click is a ranged grasp/throw.
	Tentacles change in strength depending on size

Oh yea, working on a code where it can pick up weapons and fire them back at people.
It can change form.

*/


/mob/living/simple_animal/hostile/shoggoth	//SIMPLE ANIMAL?!
	name = "shoggoth"
	desc = "Your mind fills with dread as it tries to comprehend what it's looking at."
	speak_emote = list("unleashes a sound resembling")
	friendly = "stares down"
	attacktext = "gores"
	deathmessage = "unleashes a horrifying scream, as its many tentacles squirm and swirl. Even though some of its parts still move, you can tell it's finally dead."
	
	attack_sound = 'sound/weapons/bladeslice.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	projectilesound = 'sound/weapons/gunshot.ogg'
	
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	
	gender = NEUTER
	ranged = TRUE
	check_friendly_fire = 1	
	hardattacks = FALSE	
	do_footstep = FALSE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	
	//default mob_biotypes = list(MOB_ROBOTIC)
	faction = list("nether")
	
	health = 100
	maxHealth = 100
	armour_penetration = 40
	obj_damage = 5
	melee_damage = 35
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler = VENTCRAWLER_ALWAYS
	speed = 5
	move_to_delay = 5	
	projectiletype = /obj/item/projectile/hivebotbullet
	rapid = 0
	rapid_fire_delay = 3
	
	see_in_dark = 8
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = .75, CLONE = 2, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 415
	
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	//butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)	
	
	//morph copypaste
	var/morphed = FALSE
	var/atom/movable/form = null
	var/morph_time = 0
	var/static/list/blacklist_typecache = typecacheof(list(
	/obj/screen,
	/obj/singularity,
	/mob/living/simple_animal/hostile/morph,
	/obj/effect))
	
	var/growthcost = 200
	var/size = 2
	var/obj/item/held_item = null
	var/tentacleselect = FALSE

/mob/living/simple_animal/hostile/shoggoth/Initialize()
	. = ..()		
	UpdateStats()
	//init actions
	
	//var/obj/effect/proc_holder/spell/aoe_turf/repulse/spacedragon/repulse_action = new /obj/effect/proc_holder/spell/aoe_turf/repulse/spacedragon(src)
	//repulse_action.action.Grant(src)
	//mob_spell_list += repulse_action
	
/mob/living/simple_animal/hostile/shoggoth/proc/Grow()
	if ( stat == DEAD || size >= 3 || nutrition<growthcost )
		return FALSE
	size += 1
	add_nutrition( - growthcost)
	UpdateStats()
	return TRUE
	
/mob/living/simple_animal/hostile/shoggoth/proc/Shrink()
	if ( stat == DEAD || size <= 1 )
		return FALSE
	size -= 1
	UpdateStats()
	new /obj/effect/gibspawner/generic(src.loc)
	return TRUE
	
/mob/living/simple_animal/hostile/shoggoth/proc/UpdateStats()	//change stats and sprite
	restore()	//return to original form
	ventcrawler = VENTCRAWLER_NONE
	pass_flags = PASSTABLE
	armour_penetration = 0
	speed = 
	blacklist_typecache = typecacheof(list(
	/obj/screen,
	/obj/singularity,
	/mob/living/simple_animal/hostile/morph,
	/obj/effect))
		
	if (size == 1)
		ventcrawler = VENTCRAWLER_ALWAYS
		pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
		maxHealth = 85
		obj_damage = 10
		melee_damage = 25
		speed = -0.5
		move_to_delay = 3	
		blacklist_typecache = typecacheof(list(
		/obj/screen,
		/obj/singularity,
		/mob/living,	//Size 1 cannot morph into living creatures
		/obj/effect))
	if (size == 2)
		maxHealth = 85
		obj_damage = 20
		melee_damage = 30
		speed = 0
		move_to_delay = 5
	if (size == 3)
		maxHealth = 85
		obj_damage = 30
		melee_damage = 40
		armour_penetration = 25
		move_to_delay = 6
	health = maxHealth
	ranged_cooldown = world.time + 5 //hard reset tentacle time
	
/mob/living/simple_animal/hostile/shoggoth/AttackingTarget()
	if(target == src)
		to_chat(src, "<span class='warning'>You almost bite yourself, but then decide against it.</span>")
		return
	if(istype(target, /obj/structure/shoggothbiomass))	//Special hack, consume biomass
		var/obj/structure/shoggothbiomass/biomass = target
		if(do_after(src, 20, target = biomass))
			add_nutrition(growthcost)	
			biomass.deconstruct(FALSE)
	if(isitem(target))
		var/obj/item/I = target
		if(I.loc != src && I.w_class <= WEIGHT_CLASS_HUGE )
			to_chat(firer, "<span class='notice'>You pull [I] towards yourself.</span>")
			I.transferItemToLoc( src )
			held_item = I
	if(istype(target, /turf/closed/wall))
		if (size == 1)	// size dependent
			return
		var/turf/closed/wall/thewall = target
		to_chat(src, "<span class='warning'>You begin tearing through the wall...</span>")
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		var/timetotear = 100-20*size
		if(istype(target, /turf/closed/wall/r_wall))		
			if (size < 3)
				return
			timetotear = 120
		if(do_after(src, timetotear, target = thewall))
			if(istype(thewall, /turf/open))
				return
			thewall.dismantle_wall(1)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		return
	if(isliving(target)) 
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(src, "<span class='warning'>You begin to swallow [L] whole...</span>")			
			if (iscarbon(target))
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					if (H.wear_suit && H.head && istype(H.wear_suit, /obj/item/clothing) && istype(H.head, /obj/item/clothing))
						var/obj/item/clothing/CS = H.wear_suit
						//var/obj/item/clothing/CH = H.head
						if (CS.clothing_flags & THICKMATERIAL)
							//CANNOT CHEW THROUGH A HARDSUIT
							to_chat(src, "<span class='warning'>[H] is wearing strong body protection that your teeth cannot pierce.</span>")
							//so continue
						else if(do_after(src, 40, target = L))
							add_nutrition(100)				
							L.gib()
				else
				if(do_after(src, 20, target = L))
					add_nutrition(50)				
					L.gib()
			else
				if(do_after(src, 10, target = L))
					add_nutrition(20)				
					L.gib()
			return	
	..()


/mob/living/simple_animal/hostile/shoggoth/proc/add_nutrition(nutrition_to_add = 0)	
	set_nutrition(min((nutrition + nutrition_to_add), get_max_nutrition()))
	if (nutrition_to_add > 0 && nutrition>=growthcost)
		Grow()

/mob/living/simple_animal/hostile/shoggoth/proc/get_max_nutrition() 
		return growthcost*2

/mob/living/simple_animal/hostile/shoggoth/Shoot(atom/targeted_atom)
	//if I am grasping on a mob, throw it towards that direction
	var/mob/living/throwable_mob = pulling
	if(!throwable_mob.buckled)
		stop_pulling()			
		var/turf/start_T = get_turf(loc) 
		var/turf/end_T = get_turf(targeted_atom)
		
		if(start_T && end_T)
			log_combat(src, throwable_mob, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")		
			visible_message("<span class='danger'>[src] throws [throwable_mob].</span>", \
							"<span class='danger'>You throw [throwable_mob].</span>")
			log_message("has thrown [throwable_mob]", LOG_ATTACK)
			newtonian_move(get_dir(target, src))
			throwable_mob.safe_throw_at(target, 8, 2, src, null, null, null, move_force)
			return
	
	//if I am holding an item...
	if (held_item != null)
		var//obj/item/gun/heldgun = held_item
		if (heldgun!=null && heldgun.can_shoot() && heldgun.can_trigger_gun(src) )
			//try to shoot it
			heldgun.shoot_live_shot(scr,0,targeted_atom)
		else
			//try to throw it
			held_item.forceMove(drop_location())
			src.throw_at(held_item, 6+size*2, 1+size)
			held_item = null
		return
	//otherwise, attack with tentacles
	if ( tentacleselect == FALSE )		
		if ( size == 1 )
			projectiletype = obj/item/projectile/eightacle/puny/retreat
			ranged_cooldown_time = 40
		else if ( size == 2 )
			projectiletype = obj/item/projectile/eightacle/repel
			ranged_cooldown_time = 20
		else if ( size == 3 )
			projectiletype = obj/item/projectile/eightacle/repel/strong
			ranged_cooldown_time = 130	
			rapid = 6
	
	tentacleselect = FALSE	
	return ..()

/mob/living/simple_animal/hostile/shoggoth/CtrlClickOn(atom/movable/A)	//a tentacle that pulls the creature towards the self
	//shoot, drags toward the target
	tentacleselect=TRUE
	if ( size == 1 )
		projectiletype = obj/item/projectile/eightacle/puny/disarm
		ranged_cooldown_time = 40
	else if ( size == 2 )
		projectiletype = obj/item/projectile/eightacle/drag
		ranged_cooldown_time = 20
	else if ( size == 3 )
		projectiletype = obj/item/projectile/eightacle/drag/strong
		ranged_cooldown_time = 100
		rapid = 3

/mob/living/simple_animal/hostile/shoggoth/AltClickOn(atom/movable/A)	//single, grabbing tentacle
	//shoot, but grabby tentacle
	tentacleselect=TRUE
		ranged_cooldown_time = 20
	if ( size == 1 )
		projectiletype = obj/item/projectile/eightacle/grasp/puny
	else if ( size == 2 )
		projectiletype = obj/item/projectile/eightacle/grasp
	else if ( size == 3 )
		projectiletype = obj/item/projectile/eightacle/grasp/strong

/mob/living/simple_animal/hostile/shoggoth/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)//There's no escaping this one, pal
		if(Shrink())						
			//revive(full_heal = 1)
			return	
	if(held_item)
		held_item.forceMove(drop_location())
		held_item = null
	return ..()	


// ------------------------
// - TENTACLE PROJECTILES -
// ------------------------

/obj/item/projectile/eightacle	//default class, handles visual and behavior
	name = "tentacle"
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 20
	damage_type = BRUTE
	range = 6
	hitsound = 'sound/weapons/thudswoosh.ogg'
	var/throwstrength = 3
	var/throwrange = 4
	var/chain

/obj/item/projectile/eightacle/Initialize()
	source = loc
	. = ..()

/obj/item/projectile/eightacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()

/obj/item/projectile/eightacle/proc/reset_throw(mob/living/carbon/human/H)
	return

/obj/item/projectile/eightacle/Destroy()
	qdel(chain)
	source = null
	return ..()
		
// > PUNY TENTACLES <
/obj/item/projectile/eightacle/puny
	range = 10
	damage = 8
	damage_type = BRUTE
	throwstrength = 2
	throwrange = 3

// > PUNY TENTACLES - SHOVE <
/obj/item/projectile/eightacle/puny/retreat
	damage = 10
	
//deals puny brute damage, and knocks the target away
/obj/item/projectile/eightacle/puny/retreat/on_hit(atom/target, blocked = FALSE)	
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)
			if(iscarbon(L))					
				var/mob/living/carbon/C = L
				C.apply_damage(damage, damage_type, BODY_ZONE_CHEST)
				// ??? PUSHED AWAY
				C.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
				C.throw_at(get_step_away(H,C), throwrange, throwstrength)
				return BULLET_ACT_HIT
	
// > PUNY TENTACLES - DISABLE <
/obj/item/projectile/eightacle/puny/disarm
	damage = 40
	damage_type = STAMINA
	
//deals some stamina damage damage, and knocks the target down
/obj/item/projectile/eightacle/puny/disarm/on_hit(atom/target, blocked = FALSE)	
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(isliving(target))
		var/mob/living/L = target	
		// ??? SLIPPED LEGS + DROP WEAPON
		L.Knockdown(5)
		if(iscarbon(L))			
			var/mob/living/carbon/C = L
			C.apply_damage(damage, damage_type, BODY_ZONE_CHEST)
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

// > MEH TENTACLES - REPEL <
/obj/item/projectile/eightacle/repel
	
//apply damage, knockback
/obj/item/projectile/eightacle/repel/on_hit(atom/target, blocked = FALSE)
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK	
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)
			if(iscarbon(L))					
				var/mob/living/carbon/C = L
				C.apply_damage(damage, damage_type, BODY_ZONE_CHEST)
				C.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
				C.throw_at(get_step_away(H,C), throwrange, throwstrength)
				return BULLET_ACT_HIT

// > MEH TENTACLES - DRAG <
/obj/item/projectile/eightacle/drag
	
//apply damage, knockback
/obj/item/projectile/eightacle/drag/on_hit(atom/target, blocked = FALSE)	
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)
			if(iscarbon(L))					
				var/mob/living/carbon/C = L
				C.apply_damage(damage, damage_type, BODY_ZONE_CHEST)
				C.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
				C.throw_at(get_step_towards(H,C), throwrange, throwstrength)
				return BULLET_ACT_HIT

// > MEH TENTACLES - GRAB <
/obj/item/projectile/eightacle/grasp
	nodamage = TRUE
	damage = 20	//paralyze time
	
//apply damage, knockback
/obj/item/projectile/eightacle/grasp/on_hit(atom/target, blocked = FALSE)	
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(isitem(target))
		var/obj/item/I = target
		if(I.loc != src && I.w_class <= WEIGHT_CLASS_HUGE )
			to_chat(firer, "<span class='notice'>You pull [I] towards yourself.</span>")
			I.transferItemToLoc( src )
			held_item = I
			. = BULLET_ACT_HIT
	else if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)
			if(iscarbon(L))					
				var/mob/living/carbon/C = L
				//NO LONGER C.apply_damage(damage, damage_type, BODY_ZONE_CHEST)
				C.Paralyze(damage)
				C.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
				C.grabbedby(src)
				C.grippedby(src, instant = TRUE) //instant aggro grab
				return BULLET_ACT_HIT
	
	//Spiderman code
	if(src.anchored)
		return
	A.visible_message("<span class='danger'>[A] is snagged by [firer]'s hook!</span>")
	new /datum/forced_movement(src, get_turf(target), 2, TRUE)
	return BULLET_ACT_HIT

// > STRONG TENTACLES - REPEL <
/obj/item/projectile/eightacle/repel/strong
	range = 8
	damage = 20
	damage_type = BRUTE
	spread = 10
	
// > MEH TENTACLES - DRAG <
/obj/item/projectile/eightacle/drag/strong
	range = 8
	damage = 20
	damage_type = BRUTE
	spread = 20
	
// > STRONG TENTACLES - GRAB <
/obj/item/projectile/eightacle/grasp/strong
	range = 8
	damage = 40
	
// > STRONG TENTACLES - GRAB <
/obj/item/projectile/eightacle/grasp/puny
	range = 5
	damage = 10
	
//ABILITIES

/datum/action/shoggoth_biomass
	name = "Augmented Eyesight"
	desc = "Creates more light sensing rods in our eyes, allowing our vision to penetrate most blocking objects."
	helptext = "Grants us x-ray vision. We will become a lot more vulnerable to flash-based devices while x-ray vision is active."
	button_icon_state = "slimesplit"
	
/datum/action/shoggoth_biomass/Activate()
	var/mob/living/simple_animal/hostile/shoggoth/monster = owner
	to_chat(monster, "<span class='info'>We are attempting to replicate ourselves. We will need to stand still until the process is complete.</span>")
	if(!monster.Shrink())
		to_chat(monster, "<span class='warning'>TOO SMALL TOO SHRINK!</span>")
	else 
		var/obj/structure/shoggothbiomass/biomass = new(monster.loc)
		
/obj/structure/shoggothbiomass
	name = "gelatinous mound"
	desc = "A mound of jelly-like substance encasing something inside."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "gelmound"

/obj/structure/shoggothbiomass/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/effect/gibspawner/generic(get_turf(src))
	qdel(src)
	
//MORPH COPYPASTA

/mob/living/simple_animal/hostile/shoggoth/ShiftClickOn(atom/movable/A)
	if(morph_time <= world.time && !stat)
		if(A == src)
			restore()
			return
		if(istype(A) && allowed(A))
			assume(A)
	else
		to_chat(src, "<span class='warning'>Your chameleon skin is still repairing itself!</span>")
		..()
		
/mob/living/simple_animal/hostile/shoggoth/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(A, blacklist_typecache) && (isobj(A) || ismob(A))

/mob/living/simple_animal/hostile/shoggoth/proc/assume(atom/movable/target)	
	if(size == 3)
		to_chat(src, "<span class='warning'>We won't be fooling anyone!</span>")
	if(morphed)
		//to_chat(src, "<span class='warning'>You must restore to your original form first!</span>")
		restore(TRUE)
	morphed = TRUE
	form = target

	visible_message("<span class='warning'>[src] suddenly twists and changes shape, becoming a copy of [target]!</span>", \
					"<span class='notice'>You twist your body and assume the form of [target].</span>")
	appearance = target.appearance
	copy_overlays(target)
	alpha = max(alpha, 150)
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)
	density = target.density

	//Morphed is weaker
	morph_time = world.time + MORPH_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we're an object honest
	return

/mob/living/simple_animal/hostile/shoggoth/proc/restore(var/skiptext = FALSE)
	morphed = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	maptext = null
	density = initial(density)
	
	if (skiptext)
		visible_message("<span class='warning'>[src] suddenly collapses in on itself, dissolving into a pile of green flesh!</span>", \
					"<span class='notice'>You reform to your normal body.</span>")

	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()