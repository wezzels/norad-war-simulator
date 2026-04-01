## audio_placeholder.gd
## Placeholder audio system for development
## Generates simple beep/sine sounds instead of loading files

extends Node

# Audio bus indices
var master_bus: int
var sfx_bus: int
var music_bus: int

# Generated sounds cache
var generated_sounds: Dictionary = {}

# Audio players
var sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 16
var music_player: AudioStreamPlayer


func _ready() -> void:
	# Get bus indices
	master_bus = AudioServer.get_bus_index("Master")
	sfx_bus = AudioServer.get_bus_index("SFX")
	music_bus = AudioServer.get_bus_index("Music")
	
	# Create buses if they don't exist
	if sfx_bus == -1:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "SFX")
		sfx_bus = 1
	
	if music_bus == -1:
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "Music")
		music_bus = 2
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX pool
	for i: int in range(SFX_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_pool.append(player)
	
	# Generate placeholder sounds
	_generate_sounds()


func _generate_sounds() -> void:
	"""Generate simple placeholder sounds"""
	# Alert klaxon - two-tone beep
	generated_sounds["alert_warning"] = _generate_beep(440.0, 0.15, 2)
	generated_sounds["alert_critical"] = _generate_beep(880.0, 0.1, 3)
	
	# Launch sound - rising tone
	generated_sounds["launch"] = _generate_sweep(200.0, 800.0, 0.5)
	
	# Intercept - short burst
	generated_sounds["intercept"] = _generate_beep(1200.0, 0.05, 1)
	
	# Detonation - rumble
	generated_sounds["detonation"] = _generate_rumble(0.5)
	
	# UI sounds
	generated_sounds["click"] = _generate_beep(1000.0, 0.02, 1)
	generated_sounds["hover"] = _generate_beep(800.0, 0.01, 1)
	generated_sounds["select"] = _generate_beep(600.0, 0.05, 1)
	
	# DEFCON change
	generated_sounds["defcon_up"] = _generate_beep(400.0, 0.1, 2)
	generated_sounds["defcon_down"] = _generate_beep(300.0, 0.1, 2)


func _generate_beep(frequency: float, duration: float, count: int = 1) -> AudioStreamGenerator:
	"""Generate a simple beep sound"""
	var stream: AudioStreamGenerator = AudioStreamGenerator.new()
	stream.mix_rate = 44100.0
	
	# Store params for playback
	stream.set_meta("frequency", frequency)
	stream.set_meta("duration", duration)
	stream.set_meta("count", count)
	
	return stream


func _generate_sweep(start_freq: float, end_freq: float, duration: float) -> AudioStreamGenerator:
	"""Generate a frequency sweep"""
	var stream: AudioStreamGenerator = AudioStreamGenerator.new()
	stream.mix_rate = 44100.0
	
	stream.set_meta("sweep_start", start_freq)
	stream.set_meta("sweep_end", end_freq)
	stream.set_meta("duration", duration)
	stream.set_meta("is_sweep", true)
	
	return stream


func _generate_rumble(duration: float) -> AudioStreamGenerator:
	"""Generate a low rumble"""
	var stream: AudioStreamGenerator = AudioStreamGenerator.new()
	stream.mix_rate = 44100.0
	
	stream.set_meta("rumble", true)
	stream.set_meta("duration", duration)
	
	return stream


func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	"""Play a sound effect by name"""
	if not generated_sounds.has(sound_name):
		push_warning("Sound not found: %s" % sound_name)
		return
	
	var stream: AudioStream = generated_sounds[sound_name]
	
	# Find available player
	var player: AudioStreamPlayer = null
	for p: AudioStreamPlayer in sfx_pool:
		if not p.playing:
			player = p
			break
	
	if not player:
		player = sfx_pool[0]
	
	player.stream = stream
	player.volume_db = volume_db
	player.play()


func _play_generator_sound(player: AudioStreamPlayer) -> void:
	"""Actually generate and play the sound from generator"""
	var stream: AudioStreamGenerator = player.stream
	if not stream:
		return
	
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	if not playback:
		player.play()
		playback = player.get_stream_playback()
	
	if not playback:
		return
	
	var sample_rate: int = 44100
	var is_sweep: bool = stream.get_meta("is_sweep", false)
	var is_rumble: bool = stream.get_meta("rumble", false)
	var frequency: float = stream.get_meta("frequency", 440.0)
	var duration: float = stream.get_meta("duration", 0.1)
	var count: int = stream.get_meta("count", 1)
	
	var frames: int = int(duration * sample_rate)
	
	if is_rumble:
		# Generate low frequency rumble with noise
		for i: int in range(frames):
			var t: float = float(i) / float(frames)
			var noise: float = randf_range(-0.3, 0.3)
			var low_freq: float = 50.0 + 20.0 * sin(t * PI)
			var sample: float = sin(t * low_freq * TAU) * 0.5 + noise
			playback.push_frame(Vector2(sample, sample))
	elif is_sweep:
		# Generate frequency sweep
		var start_freq: float = stream.get_meta("sweep_start", 200.0)
		var end_freq: float = stream.get_meta("sweep_end", 800.0)
		for i: int in range(frames):
			var t: float = float(i) / float(frames)
			var freq: float = lerp(start_freq, end_freq, t)
			var sample: float = sin(t * freq * TAU) * (1.0 - t)
			playback.push_frame(Vector2(sample, sample))
	else:
		# Generate beep with count
		for c: int in range(count):
			for i: int in range(frames):
				var t: float = float(i) / float(frames)
				var sample: float = sin(t * frequency * TAU) * (1.0 - t * 0.5)
				playback.push_frame(Vector2(sample, sample))
			
			# Small gap between beeps
			for i: int in range(int(0.02 * sample_rate)):
				playback.push_frame(Vector2.ZERO)


func play_music(track_name: String, fade_in: float = 1.0) -> void:
	"""Play music track (placeholder - just plays silence)"""
	# TODO: Implement actual music when tracks are available
	music_player.stop()


func stop_music(fade_out: float = 1.0) -> void:
	"""Stop music"""
	if music_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_out)
		await tween.finished
		music_player.stop()


func set_master_volume(volume: float) -> void:
	"""Set master volume (0.0 to 1.0)"""
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(volume))


func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 to 1.0)"""
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(volume))


func set_music_volume(volume: float) -> void:
	"""Set music volume (0.0 to 1.0)"""
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(volume))


# Convenience methods for common game events
func play_alert() -> void:
	play_sfx("alert_warning", -3.0)


func play_launch() -> void:
	play_sfx("launch", -5.0)


func play_intercept() -> void:
	play_sfx("intercept", -5.0)


func play_detonation() -> void:
	play_sfx("detonation", -3.0)


func play_click() -> void:
	play_sfx("click", -10.0)


func play_hover() -> void:
	play_sfx("hover", -15.0)