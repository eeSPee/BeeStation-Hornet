/*

BLOB/DRAGON HYBRID IDEA
Insipred by Carrion Game

Possibly midround antag, heretic finalspawn (alla lord of the night), or changeling superform. If you look at the game carrion, you know what it will look like.
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

FIRING MODES
	THROW ITEMS
	FIRE GUNS
ABILITIES
	DOWNSIZE
BIOMASS SUPPLIES - dropped with ability

THCHAT when downsizing, but not when harmed
GOBBLE WEAPONS
STAT

3 sized
	small - escape
		1 long ranged tentacle
	medium - hunting
		faster, medium ranged tentacles
	large - combat
		many medium range tentacles
	
Tentacle
	click push
	ctrlclick pull
	altclick grasp and throw

*/


/mob/living/simple_animal/hostile/shoggoth
	name = "hivebot"
	desc = "A small robot."
	speak_emote = list("states")
	friendly = "stares down"
	attacktext = "claws"
	deathmessage = "screeches as its wings turn to dust and it collapses on the floor, life estinguished."
	
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
	do_footstep = TRUE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	
	mob_biotypes = list(MOB_ROBOTIC)
	faction = list("neutral")
	
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
	
	see_in_dark = 8
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = .75, CLONE = 2, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 415
	
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	//butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)	
	
	
	var/growthcost = 200
	var/size = 2
	var/obj/item/held_item = null
	//hud_type

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
	return TRUE
	
/mob/living/simple_animal/hostile/shoggoth/proc/UpdateStats()	//change stats and sprite
	ventcrawler = VENTCRAWLER_NONE
	pass_flags = PASSTABLE
	armour_penetration = 0
	
	if (size == 1)
		ventcrawler = VENTCRAWLER_ALWAYS
		pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
		maxHealth = 85
		obj_damage = 10
		melee_damage = 25
		speed = 0
		move_to_delay = 1	
	if (size == 2)
		maxHealth = 85
		obj_damage = 20
		melee_damage = 30
		speed = 2
		move_to_delay = 2
	if (size == 3)
		maxHealth = 85
		obj_damage = 80
		melee_damage = 40
		armour_penetration = 20
		speed = 5
		move_to_delay = 4
	health = maxHealth
	
/mob/living/simple_animal/hostile/shoggoth/AttackingTarget()
	if(target == src)
		to_chat(src, "<span class='warning'>You almost bite yourself, but then decide against it.</span>")
		return
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
			if(do_after(src, 30, target = L))
				if (iscarbon(target))
					add_nutrition(100)
				else
					add_nutrition(50)				
				target.gib()
			return	
	. = ..()


/mob/living/simple_animal/hostile/shoggoth/proc/add_nutrition(nutrition_to_add = 0)	
	set_nutrition(min((nutrition + nutrition_to_add), get_max_nutrition()))
	if (nutrition_to_add > 0 && nutrition>=growthcost)
		Grow()

/mob/living/simple_animal/hostile/shoggoth/proc/get_max_nutrition() 
		return growthcost*1

/mob/living/simple_animal/hostile/shoggoth/Stat()
	if(..())

		if(!docile)
			stat(null, "Nutrition: [nutrition]/[get_max_nutrition()]")
		if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
			if(is_adult)
				stat(null, "You can reproduce!")
			else
				stat(null, "You can evolve!")

		if(stat == UNCONSCIOUS)
			stat(null,"You are knocked out by high levels of BZ!")
		else
			stat(null,"Power Level: [powerlevel]")
		stat("Held Item", held_item)


/mob/living/simple_animal/hostile/shoggoth/Shoot(atom/targeted_atom)

	//attack/shove
	
	//throw held item
	if (held_item != null)
		held_item.forceMove(drop_location())
		src.throw_at(held_item, 6+size*2, 1+size)
		held_item = null
		return
	
	if ( projectiletype == null )		
		if ( size == 1 )
			projectiletype = obj/item/projectile/eightacle/puny/retreat
			ranged_cooldown_time = 20
		else if ( size == 2 )
			projectiletype = obj/item/projectile/eightacle/repel
			ranged_cooldown_time = 5
		else if ( size == 3 )
			projectiletype = obj/item/projectile/eightacle/repel/strong
			ranged_cooldown_time = 2		
	var/proj = 	..()
	projectiletype = null	
	return proj

/mob/living/simple_animal/hostile/shoggoth/CtrlClickOn(atom/movable/A)
	//shoot, drags toward the target
	if ( size == 1 )
		projectiletype = obj/item/projectile/eightacle/puny/disarm
		ranged_cooldown_time = 20
	else if ( size == 2 )
		projectiletype = obj/item/projectile/eightacle/drag
		ranged_cooldown_time = 6
	else if ( size == 3 )
		projectiletype = obj/item/projectile/eightacle/drag/strong
		ranged_cooldown_time = 3	

/mob/living/simple_animal/hostile/shoggoth/AltClickOn(atom/movable/A)
	//shoot, but grabby tentacle
	if ( size == 1 )
		projectiletype = obj/item/projectile/eightacle/grasp/puny
		ranged_cooldown_time = 10
	else if ( size == 2 )
		projectiletype = obj/item/projectile/eightacle/grasp
		ranged_cooldown_time = 5
	else if ( size == 3 )
		projectiletype = obj/item/projectile/eightacle/grasp/strong
		ranged_cooldown_time = 2	


///mob/living/simple_animal/slime/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
//	return
	
/mob/living/simple_animal/hostile/shoggoth/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(Shrink())						
			//revise actions?
			
			//for(var/datum/action/innate/slime/reproduce/R in actions)
			//	R.Remove(src)
			//var/datum/action/innate/slime/evolve/E = new
			
			revive(full_heal = 1)
			return
	else
		if(held_item)
			held_item.forceMove(drop_location())
			held_item = null
	stat = DEAD
	return ..(true)	//always gib if size 1


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
	damage = 10
	
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

// > STRONG TENTACLES - REPEL <
/obj/item/projectile/eightacle/repel/strong
	range = 8
	damage = 20
	damage_type = BRUTE
	
// > MEH TENTACLES - DRAG <
/obj/item/projectile/eightacle/drag/strong
	range = 8
	damage = 20
	damage_type = BRUTE
	
// > STRONG TENTACLES - GRAB <
/obj/item/projectile/eightacle/grasp/strong
	range = 8
	damage = 15
	
// > STRONG TENTACLES - GRAB <
/obj/item/projectile/eightacle/grasp/puny
	range = 5
	damage = 5