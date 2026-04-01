## audio_manager.gd
## Audio manager with real sound effects
## Manages sound effects and music playback

extends Node

# Audio buses
var master_bus: int
var sfx_bus: int
var music_bus: int

# Music player
var music_player: AudioStreamPlayer

# Sound effect players (pool)
var sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 16

# Currently loaded sounds
var loaded_sounds: Dictionary = {}

# Music tracks
const MUSIC_TRACKS: Dictionary = {
	"menu": "res://audio/music/menu_theme.ogg",
	"game_ambient": "res://audio/music/game_ambient.ogg",
	"crisis": "res://audio/music/crisis.ogg"
}

# Sound effect paths
const SFX_PATHS: Dictionary = {
	"alert_warning": "res://audio/sfx/alert_warning.wav",
	"alert_critical": "res://audio/sfx/alert_critical.wav",
	"launch": "res://audio/sfx/launch.wav",
	"intercept": "res://audio/sfx/intercept.wav",
	"detonation": "res://audio/sfx/detonation.wav",
	"click": "res://audio/sfx/click.wav",
	"hover": "res://audio/sfx/hover.wav",
	"defcon_change": "res://audio/sfx/defcon_change.wav"
}


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
	
	# Preload sounds
	preload_sounds()


func preload_sounds() -> void:
	"""Preload all sound effects"""
	for sound_name: String in SFX_PATHS:
		var path: String = SFX_PATHS[sound_name]
		if FileAccess.file_exists(path):
			var stream: AudioStream = load(path)
			if stream:
				loaded_sounds[sound_name] = stream
		else:
			# Use generated sound if file doesn't exist
			var generator: RefCounted = AudioStreamGenerator.new()
			generator.mix_rate = 44100
			loaded_sounds[sound_name] = generator


func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	"""Play a sound effect by name"""
	if not loaded_sounds.has(sound_name):
		push_warning("Sound not found: %s" % sound_name)
		return
	
	var stream: AudioStream = loaded_sounds[sound_name]
	
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


func play_music(track_name: String, fade_in: float = 1.0) -> void:
	"""Play a music track with optional fade in"""
	var path: String = MUSIC_TRACKS.get(track_name, "")
	
	if path.is_empty():
		push_warning("Music track not found: %s" % track_name)
		return
	
	if not FileAccess.file_exists(path):
		push_warning("Music file not found: %s" % path)
		return
	
	var stream: AudioStream = load(path)
	
	# Fade out current music
	if music_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_in)
		await tween.finished
	
	music_player.stream = stream
	music_player.volume_db = -40.0 if fade_in > 0 else 0.0
	music_player.play()
	
	# Fade in new music
	if fade_in > 0:
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", 0.0, fade_in)


func stop_music(fade_out: float = 1.0) -> void:
	"""Stop current music with fade out"""
	if not music_player.playing:
		return
	
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
	"""Play alert klaxon"""
	play_sfx("alert_warning", -3.0)


func play_launch() -> void:
	"""Play missile launch sound"""
	play_sfx("launch", -5.0)


func play_intercept() -> void:
	"""Play intercept explosion"""
	play_sfx("intercept", -5.0)


func play_detonation() -> void:
	"""Play nuclear detonation"""
	play_sfx("detonation", -3.0)


func play_click() -> void:
	"""Play UI click"""
	play_sfx("click", -10.0)


func play_hover() -> void:
	"""Play UI hover"""
	play_sfx("hover", -15.0)


func play_defcon_change() -> void:
	"""Play DEFCON level change"""
	play_sfx("defcon_change", -5.0)