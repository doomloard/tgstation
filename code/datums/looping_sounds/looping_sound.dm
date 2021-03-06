/*
	list/atom/output_atoms

	mid_sounds		(list or soundfile)		Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	mid_length		(num)					The length to wait between playing mid_sounds

	start_sound		(soundfile)				Played before starting the mid_sounds loop
	start_length	(num)					How long to wait before starting the main loop after playing start_sound

	end_sound		(soundfile)				The sound played after the main loop has concluded

	chance			(num)					Chance per loop to play a mid_sound
	volume			(num)					Sound output volume
	muted			(bool)					Private. Used to stop the sound loop.
	max_loops		(num)					The max amount of loops to run for.
*/
/datum/looping_sound
	var/list/atom/output_atoms
	var/mid_sounds
	var/mid_length
	var/start_sound
	var/start_length
	var/end_sound
	var/chance
	var/volume
	var/muted = TRUE
	var/max_loops

/datum/looping_sound/New(list/_output_atoms, start_immediately=FALSE)
	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")
		return

	if(_output_atoms)
		output_atoms = _output_atoms
	else
		output_atoms = list()

	if(start_immediately)
		start()

/datum/looping_sound/Destroy()
	stop()
	output_atoms = null
	return ..()

/datum/looping_sound/proc/start()
	if(!muted)
		return
	muted = FALSE
	on_start()

/datum/looping_sound/proc/stop()
	if(muted)
		return
	muted = TRUE

/datum/looping_sound/proc/sound_loop(looped=0)
	if(muted || (max_loops && looped > max_loops))
		on_stop(looped)
		return
	if(!chance || prob(chance))
		play(get_sound(looped))
	addtimer(CALLBACK(src, .proc/sound_loop, ++looped), mid_length)

/datum/looping_sound/proc/play(soundfile)
	var/list/atoms_cache = output_atoms
	for(var/i in 1 to atoms_cache.len)
		var/atom/thing = atoms_cache[i]
		playsound(thing, soundfile, volume)

/datum/looping_sound/proc/get_sound(looped, _mid_sounds)
	if(!_mid_sounds)
		. = mid_sounds
	else
		. = _mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pickweight(.)

/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound)
		play(start_sound)
		start_wait = start_length
	addtimer(CALLBACK(src, .proc/sound_loop), start_wait)

/datum/looping_sound/proc/on_stop(looped)
	if(end_sound)
		play(end_sound)