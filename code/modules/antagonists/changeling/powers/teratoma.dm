/datum/action/changeling/teratoma
	name = "Birth Teratoma"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem"
	helptext = "The tumor will not be loyal to us or our cause. Costs two changeling absorptions"
	button_icon_state = "spread_infestation"
	needs_button = FALSE
	dna_cost = 2
	req_absorbs = 3

/datum/action/changeling/teratoma/on_purchase(mob/user, is_respec)
	..()
	var/datum/action/changeling/control_teratoma/S2 = new
	if(!changeling.has_sting(S2))
		S2.Grant(user)
		changeling.purchasedpowers+=S2
	var/datum/action/changeling/spawn_teratoma/S1 = new
	if(!changeling.has_sting(S1))
		S1.Grant(user)
		S1.directive_ability = S2
		changeling.purchasedpowers+=S1

/datum/action/changeling/teratoma/Remove(mob/user)
	for(var/p in changeling.purchasedpowers)
		var/datum/action/changeling/otherpower = p
		if(istype(otherpower, /datum/action/changeling/spawn_teratoma) || istype(otherpower, /datum/action/changeling/control_teratoma))
			changeling.purchasedpowers -= otherpower
			otherpower.Remove(changeling.owner.current)
	..()
	
/datum/action/changeling/spawn_teratoma
	name = "Birth Teratoma"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem"
	helptext = "The tumor will not be loyal to us or our cause. Costs two changeling absorptions"
	button_icon_state = "spread_infestation"
	chemical_cost = 60
	dna_cost = -1
	var/directive_ability

//Reskinned monkey - teratoma, will burst out of the host, with the objective to cause chaos.
/datum/action/changeling/spawn_teratoma/sting_action(mob/user)
	..()
	if(create_teratoma(user))
		var/mob/living/U = user
		playsound(user.loc, 'sound/effects/blobattack.ogg', 50, 1)
		U.spawn_gibs()
		user.visible_message("<span class='danger'>Something horrible bursts out of [user]'s chest!</span>", \
								"<span class='danger'>Living teratoma bursts out of your chest!</span>", \
								"<span class='hear'>You hear flesh tearing!</span>", COMBAT_MESSAGE_RANGE)
	return FALSE		//create_teratoma() handles the chemicals anyway so there is no reason to take them again

/datum/action/changeling/spawn_teratoma/proc/create_teratoma(mob/user)
	var/datum/antagonist/changeling/c = user.mind.has_antag_datum(/datum/antagonist/changeling)
	c.chem_charges -= chemical_cost				//I'm taking your chemicals hostage!
	var/turf/A = get_turf(user)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as a living teratoma?", ROLE_TERATOMA, null, ROLE_TERATOMA, 5 SECONDS) //players must answer rapidly
	if(!LAZYLEN(candidates)) //if we got at least one candidate, they're teratoma now
		to_chat(usr, "<span class='warning'>You fail at creating a tumor. Perhaps you should try again later?</span>")
		c.chem_charges += chemical_cost				//If it fails we want to refund the chemicals
		return FALSE
	var/mob/living/carbon/monkey/tumor/T = new /mob/living/carbon/monkey/tumor(A)
	var/mob/dead/observer/C = pick(candidates)
	T.key = C.key
	var/datum/antagonist/teratoma/antag_datum = new
	if (antag_datum)
		var/datum/objective/chaos/C = new
		if (directive_ability)
			C.directive = directive_ability.directive
		C.update_explanation_text()
		antag_datum.add_objective(C)
	T.mind.add_antag_datum(antag_datum)
	to_chat(T, "<span='notice'>You burst out from [user]'s chest!</span>")
	SEND_SOUND(T, sound('sound/effects/blobattack.ogg'))
	return TRUE
	
/datum/action/changeling/control_teratoma
	name = "Set Directive"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem"
	helptext = "The tumor will not be loyal to us or our cause. Costs two changeling absorptions"
	button_icon_state = "spread_infestation"
	chemical_cost = 0
	dna_cost = -1
	var/directive = ""

/datum/action/changeling/control_teratoma/sting_action(mob/living/user)
	directive = stripped_input(S, "Enter the new directive", "Create directive", "[directive]")
	message_admins("[ADMIN_LOOKUPFLW(owner)] set teratoma directives to: '[directive]'.")
	log_game("[key_name(owner)] set teratoma directives to: '[directive]'.")
	return TRUE