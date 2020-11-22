/datum/action/changeling/fakedeath
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE
	var/revive_ready = FALSE
	var/revive_mend_cost = 10
	var/revive_spent_dna = 0

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fakedeath/sting_action(mob/living/user)
	..()
	if(revive_ready)
		INVOKE_ASYNC(src, .proc/revive, user)
		revive_ready = FALSE
		name = "Reviving Stasis"
		desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
		button_icon_state = "fake_death"
		UpdateButtonIcon()
		chemical_cost = 15
		to_chat(user, "<span class='notice'>We have revived ourselves.</span>")
	else
		to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
		revive_spent_dna = 0
		user.fakedeath("changeling") //play dead
		user.update_stat()
		user.update_mobility()
		addtimer(CALLBACK(src, .proc/ready_to_regenerate, user), LING_FAKEDEATH_TIME, TIMER_UNIQUE)
	return TRUE

/datum/action/changeling/fakedeath/proc/revive(mob/living/user)
	if(!user || !istype(user))
		return
	user.cure_fakedeath("changeling")
	user.revive(full_heal = TRUE)
	user.regenerate_organs()

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(user?.mind)
		var/datum/antagonist/changeling/C = user.mind.has_antag_datum(/datum/antagonist/changeling)
		if(C?.purchasedpowers)
			to_chat(user, "<span class='notice'>We are ready to revive.</span>")
			name = "Revive"
			desc = "We arise once more."
			button_icon_state = "revive"
			UpdateButtonIcon()
			chemical_cost = 0
			revive_ready = TRUE

/datum/action/changeling/fakedeath/can_sting(mob/living/user)
	if (!revive_ready)
		if(HAS_TRAIT_FROM(user, TRAIT_DEATHCOMA, "changeling"))
			to_chat(user, "<span class='warning'>We are already reviving.</span>")
			return
		if(!user.stat) //Confirmation for living changelings if they want to fake their death
			switch(alert("Are we sure we wish to fake our own death?",,"Yes", "No"))
				if("No")
					return
	if(HAS_TRAIT(user, TRAIT_HUSK))
		var/datum/antagonist/changeling/dedun = user.mind.has_antag_datum(/datum/antagonist/changeling)
		if (dedun.chem_charges>=revive_mend_cost)
			to_chat(user, "<span class='notice'>You spend [revive_mend_cost] chemicals to repair your DNA!.</span>")
			dedun.chem_charges-=revive_mend_cost
			revive_spent_dna += revive_mend_cost
			if (revive_spent_dna<100)
				return
		else
			to_chat(user, "<span class='warning'>You need [revive_mend_cost] chemicals to repair your DNA!.</span>")
			return
	return ..()
