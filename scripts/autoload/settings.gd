## settings.gd
## User settings manager
## Handles graphics, audio, and gameplay settings

extends Node

# Settings file path
const SETTINGS_PATH: String = "user://settings.cfg"

# Settings
var graphics: Dictionary = {
	"fullscreen": false,
	"window_width": 1920,
	"window_height": 1080,
	"vsync": true,
	"anti_aliasing": 2,
	"shadows": true,
	"bloom": true
}

var audio: Dictionary = {
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"music_volume": 0.8,
	"voice_volume": 1.0
}

var gameplay: Dictionary = {
	"speed_default": 1.0,
	"speed_max": 100.0,
	"show_contrails": true,
	"show_coverage_circles": true,
	"auto_intercept": false,
	"difficulty": "normal"
}

var network: Dictionary = {
	"player_name": "Commander",
	"server_port": 7777,
	"max_players": 4
}


func _ready() -> void:
	load_settings()


func load_settings() -> bool:
	"""Load settings from file"""
	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(SETTINGS_PATH)
	
	if error != OK:
		# File doesn't exist, use defaults
		return false
	
	# Graphics
	for key in graphics:
		graphics[key] = config.get_value("graphics", key, graphics[key])
	
	# Audio
	for key in audio:
		audio[key] = config.get_value("audio", key, audio[key])
	
	# Gameplay
	for key in gameplay:
		gameplay[key] = config.get_value("gameplay", key, gameplay[key])
	
	# Network
	for key in network:
		network[key] = config.get_value("network", key, network[key])
	
	apply_settings()
	return true


func save_settings() -> bool:
	"""Save settings to file"""
	var config: ConfigFile = ConfigFile.new()
	
	# Graphics
	for key in graphics:
		config.set_value("graphics", key, graphics[key])
	
	# Audio
	for key in audio:
		config.set_value("audio", key, audio[key])
	
	# Gameplay
	for key in gameplay:
		config.set_value("gameplay", key, gameplay[key])
	
	# Network
	for key in network:
		config.set_value("network", key, network[key])
	
	var error: int = config.save(SETTINGS_PATH)
	return error == OK


func apply_settings() -> void:
	"""Apply settings to engine"""
	# Graphics
	if graphics.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(graphics.window_width, graphics.window_height))
	
	# VSync
	if graphics.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Anti-aliasing
	match graphics.anti_aliasing:
		0: ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
		1: ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 2)
		2: ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 4)
		_: ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 8)
	
	# Audio
	var master_bus: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(audio.master_volume))
	
	var sfx_bus: int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(audio.sfx_volume))
	
	var music_bus: int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(audio.music_volume))


func set_graphics_setting(key: String, value: Variant) -> void:
	"""Set a graphics setting"""
	graphics[key] = value
	apply_settings()
	save_settings()


func set_audio_setting(key: String, value: float) -> void:
	"""Set an audio setting"""
	audio[key] = value
	apply_settings()
	save_settings()


func set_gameplay_setting(key: String, value: Variant) -> void:
	"""Set a gameplay setting"""
	gameplay[key] = value
	save_settings()


func set_network_setting(key: String, value: Variant) -> void:
	"""Set a network setting"""
	network[key] = value
	save_settings()


func reset_to_defaults() -> void:
	"""Reset all settings to defaults"""
	graphics = {
		"fullscreen": false,
		"window_width": 1920,
		"window_height": 1080,
		"vsync": true,
		"anti_aliasing": 2,
		"shadows": true,
		"bloom": true
	}
	
	audio = {
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 0.8,
		"voice_volume": 1.0
	}
	
	gameplay = {
		"speed_default": 1.0,
		"speed_max": 100.0,
		"show_contrails": true,
		"show_coverage_circles": true,
		"auto_intercept": false,
		"difficulty": "normal"
	}
	
	network = {
		"player_name": "Commander",
		"server_port": 7777,
		"max_players": 4
	}
	
	apply_settings()
	save_settings()