/datum/gang_item
	var/name
	var/item_path
	var/cost
	var/spawn_msg
	var/category
	var/list/gang_whitelist = list()
	var/list/gang_blacklist = list()
	var/id

/datum/gang_item/proc/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, gangtool))
		return FALSE
	var/real_cost = get_cost(user, gang, gangtool)
	if(!spawn_item(user, gang, gangtool))
		gang.adjust_influence(-real_cost)
		to_chat(user, "<span class='notice'>You bought \the [name].</span>")
		return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool) // If this returns anything other than null, something fucked up and influence won't lower.
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	else
		return TRUE
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return gang && (gang.influence >= get_cost(user, gang, gangtool)) && can_see(user, gang, gangtool)

/datum/gang_item/proc/can_see(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return TRUE

/datum/gang_item/proc/get_cost(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return cost

/datum/gang_item/proc/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return "([get_cost(user, gang, gangtool)] Influence)"

/datum/gang_item/proc/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return name

/datum/gang_item/proc/get_extra_info(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return

///////////////////
//Essential Gang Tools
///////////////////

/datum/gang_item/essentials
	category = "Purchase Essential Items:"

/datum/gang_item/essentials/gangtool
	id = "gangtool"
	cost = 20

/datum/gang_item/essentials/gangtool/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/item_type
	if(gang)
		item_type = /obj/item/device/gangtool/spare/lt
		if(gang.leaders.len < MAX_LEADERS_GANG)
			to_chat(user, "<span class='notice'><b>Gangtools</b> allow you to promote a gangster to be your Lieutenant, enabling them to recruit and purchase items like you. Simply have them register the gangtool. You may promote up to [MAX_LEADERS_GANG-gang.leaders.len] more Lieutenants.</span>")
	else
		item_type = /obj/item/device/gangtool/spare
	var/obj/item/device/gangtool/spare/tool = new item_type(user.loc)
	user.put_in_hands(tool)

/datum/gang_item/essentials/gangtool/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang && (gang.leaders.len < gang.max_leaders))
		return "Promote a Gangster"
	return "Spare Gangtool"

/datum/gang_item/essentials/spraycan
	name = "Territory Spraycan"
	id = "spraycan"
	cost = 5
	item_path = /obj/item/toy/crayon/spraycan/gang

/datum/gang_item/essentials/spraycan/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/O = new item_path(user.loc, gang)
	user.put_in_hands(O)


/datum/gang_item/essentials/pen
	name = "Recruitment Pen"
	id = "pen"
	cost = 30
	item_path = /obj/item/pen/gang
	spawn_msg = "<span class='notice'>More <b>recruitment pens</b> will allow you to recruit gangsters faster. Only gang leaders can recruit with pens.</span>"

/datum/gang_item/essentials/pen/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(..())
		gangtool.free_pen = FALSE
		return TRUE
	return FALSE

/datum/gang_item/essentials/pen/get_cost(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool?.free_pen)
		return 0
	return ..()

/datum/gang_item/essentials/pen/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool?.free_pen)
		return "(GET ONE FREE)"
	return ..()

///////////////////
//CLOTHING
///////////////////

/datum/gang_item/clothing
	category = "Purchase Gang Clothes (Only the jumpsuit and suit give you added influence):"

/datum/gang_item/clothing/basic
	name = "Gang Uniform"
	id = "under"
	cost = 2
	
/datum/gang_item/clothing/basic/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/uniform_box = new ()
	
	new gang.outfit(uniform_box)
	new gang.suit(uniform_box)
	new gang.hat(uniform_box)	
	
	to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence")
	return TRUE

/datum/gang_item/clothing/armor
	name = "Gang Armored Outerwear"
	id = "suit"
	cost = 100

/datum/gang_item/clothing/armor/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/armor_box = new ()
	
	var/obj/item/suit/suit = new gang.suit(armor_box)
	suit.armor = suit.armor.setRating(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
	suit.desc += " Tailored for the [gang.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
	
	var/obj/item/head/hat = new gang.hat(armor_box)
	hat.armor = hat.armor.setRating(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
	hat.desc += " Tailored for the [gang.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
	
	to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence")
	return TRUE

/datum/gang_item/clothing/armor
	name = "Gang Armored Outerwear"
	id = "suit"
	cost = 100

/datum/gang_item/clothing/armor/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/armor_box = new ()
	
	var/obj/item/suit/suit = new gang.suit(armor_box)
	suit.clothing_flags |= STOPSPRESSUREDAMAGE | THICKMATERIAL
	suit.cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	suit.heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	suit.min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	suit.max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	suit.desc += " Tailored for the [gang.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
	
	var/obj/item/head/hat = new gang.hat(armor_box)
	hat.clothing_flags |= STOPSPRESSUREDAMAGE | THICKMATERIAL
	hat.cold_protection = HEAD
	hat.heat_protection = HEAD
	hat.min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	hat.max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	hat.desc += " Tailored for the [gang.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
	
	to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence")
	return TRUE

/datum/gang_item/clothing/mask
	name = "Golden Death Mask"
	id = "mask"
	cost = 30
	item_path = /obj/item/clothing/mask/gskull

/obj/item/clothing/mask/gskull
	name = "golden death mask"
	icon_state = "gskull"
	desc = "Strike terror, and envy, into the hearts of your enemies."

/datum/gang_item/clothing/shoes
	name = "Bling Boots"
	id = "boots"
	cost = 30
	item_path = /obj/item/clothing/shoes/gang

/obj/item/clothing/shoes/gang
	name = "blinged-out boots"
	desc = "Stand aside peasants."
	icon_state = "bling"

/datum/gang_item/clothing/neck
	name = "Gold Necklace"
	id = "necklace"
	cost = 15
	item_path = /obj/item/clothing/neck/necklace/dope

/datum/gang_item/clothing/hands
	name = "Decorative Brass Knuckles"
	id = "hand"
	cost = 30
	item_path = /obj/item/clothing/gloves/gang

/obj/item/clothing/gloves/gang
	name = "braggadocio's brass knuckles"
	desc = "Purely decorative, don't find out the hard way."
	icon_state = "knuckles"
	w_class = 3

/datum/gang_item/clothing/belt
	name = "Badass Belt"
	id = "belt"
	cost = 15
	item_path = /obj/item/storage/belt/military/gang

/obj/item/storage/belt/military/gang
	name = "badass belt"
	icon_state = "gangbelt"
	item_state = "gang"
	desc = "The belt buckle simply reads 'BAMF'."

///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Purchase Weapons:"

/datum/gang_item/weapon/ammo

/datum/gang_item/weapon/shuriken
	name = "Shuriken"
	id = "shuriken"
	cost = 100
	item_path = /obj/item/throwing_star
	
obj/item/storage/box/shuriken_box
	name = "Shuriken Box"
	
obj/item/storage/box/shuriken_box/populate_contents()
	new /obj/item/throwing_star()
	new /obj/item/throwing_star()
	new /obj/item/throwing_star()

/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	id = "switchblade"
	cost = 50
	item_path = /obj/item/switchblade

/datum/gang_item/weapon/pistol
	name = "10mm Pistol"
	id = "pistol"
	cost = 300
	item_path = /obj/item/gun/ballistic/automatic/pistol

/datum/gang_item/weapon/ammo/pistol_ammo
	name = "10mm Ammo"
	id = "pistol_ammo"
	cost = 30
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/gang_item/weapon/uzi
	name = "Uzi SMG"
	id = "uzi"
	cost = 300
	item_path = /obj/item/gun/ballistic/automatic/mini_uzi

/datum/gang_item/weapon/ammo/uzi_ammo
	name = "Uzi Ammo"
	id = "uzi_ammo"
	cost = 30
	item_path = /obj/item/ammo_box/magazine/uzim9mm

/datum/gang_item/weapon/laser
	name = "Laser Gun"
	id = "laser"
	cost = 300
	item_path/obj/item/gun/energy/laser/retro

///////////////////
//EQUIPMENT
///////////////////

/datum/gang_item/equipment
	category = "Purchase Support Equipment:"

/datum/gang_item/equipment/emp
	name = "EMP Grenade"
	id = "EMP"
	cost = 5
	item_path = /obj/item/grenade/empgrenade

/datum/gang_item/equipment/c4
	name = "C4 Explosive"
	id = "c4"
	cost = 10
	item_path = /obj/item/grenade/plastic/c4

/datum/gang_item/equipment/synthflesh
	name = "Healing Cigs"
	id = "synthflesh"
	cost = 10
	item_path = /obj/item/storage/fancy/cigarettes/cigpack_syndicate

/datum/gang_item/equipment/drugs
	name = "Drug Supply"
	id = "drugs"
	cost = 20
	item_path = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	
/datum/gang_item/equipment/drugs/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/O	
	switch (rand(1,10))
		if (1)
			O = new /obj/item/storage/pill_bottle/lsd(user.loc)
		if (2)
			O = new /obj/item/storage/pill_bottle/happy(user.loc)
		if (3)
			O = new /obj/item/storage/pill_bottle/zoom(user.loc)
		if (4)
			O = new /obj/item/storage/pill_bottle/aranesp(user.loc)
		if (5)
			O = new /obj/item/storage/pill_bottle/happiness(user.loc)
		if (6)
			O = new /obj/item/storage/pill_bottle/psicodine(user.loc)
		if (7)
			O = new /obj/item/storage/pill_bottle/psicodine(user.loc)
		if (8)
			O = new /obj/item/reagent_containers/food/snacks/grown/cannabis(user.loc)
		if (9)
			O = new /obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow(user.loc)
		if (10)
			O = new /obj/item/reagent_containers/food/snacks/grown/cannabis/white(user.loc)	
	if (O)
		user.put_in_hands(O)

/datum/gang_item/equipment/aids
	name = "Battlefield Aid Kit"
	id = "aids"
	cost = 120
	item_path = /obj/item/storage/firstaid/shifty/battle

/datum/gang_item/equipment/hangover
	name = "Bad Trip Kit"
	id = "aids"
	cost = 120
	item_path = /obj/item/storage/firstaid/shifty/hangover
	
/obj/item/storage/firstaid/shifty
	name = "shifty medkit"
	desc = "A shifty medkit."
	icon_state = "bezerk"

/obj/item/storage/firstaid/shifty/battle/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/silver_sulf = 3,
		/obj/item/reagent_containers/pill/patch/styptic = 3,
		/obj/item/reagent_containers/medspray/synthflesh = 1,
		/obj/item/reagent_containers/hypospray/medipen = 2)
	generate_items_inside(items_inside,src)
	
/obj/item/storage/firstaid/shifty/hangover/PopulateContents()
	var/static/items_inside = list(
		/obj/item/storage/pill_bottle/charcoal = 1,
		/obj/item/reagent_containers/syringe/calomel = 1,
		/obj/item/reagent_containers/hypospray/medipen = 2,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/datum/gang_item/equipment/mulah
	name = "Space Cash (1000cr)"
	id = "mulah"
	cost = 1000
	item_path = /obj/item/stack/spacecash/c1000

/datum/gang_item/equipment/reinforce
	name = "Call Reinforcments"
	id = "reinforce"
	cost = 500
	item_path = /obj/item/antag_spawner/gangster
	spawn_msg = "<span class='notice'>The <b>implant breaker</b> is a single-use device that destroys all implants within the target before trying to recruit them to your gang. Also works on enemy gangsters.</span>"

/datum/gang_item/equipment/implant_breaker	//RENAME
	name = "Implant Breaker"
	id = "implant_breaker"
	cost = 50
	item_path = /obj/item/implanter/gang
	spawn_msg = "<span class='notice'>The <b>implant breaker</b> is a single-use device that destroys all implants within the target before trying to recruit them to your gang. Also works on enemy gangsters.</span>"

/datum/gang_item/equipment/implant_breaker/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/O = new item_path(user.loc, gang)
	user.put_in_hands(O)

