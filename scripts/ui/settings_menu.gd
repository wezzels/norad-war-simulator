## settings_menu.gd
## Settings menu for graphics, audio, and gameplay
## Loads and saves settings via Settings autoload

extends Control

# Nodes
@onready var fullscreen_check: CheckBox = $TabContainer/Graphics/FullscreenCheck
@onready var vsync_check: CheckBox = $TabContainer/Graphics/VSyncCheck
@onready var msaa_option: OptionButton = $TabContainer/Graphics/MSAAOption
@onready var shadows_check: CheckBox = $TabContainer/Graphics/ShadowsCheck

@onready var master_slider: HSlider = $TabContainer/Audio/MasterSlider
@onready var sfx_slider: HSlider = $TabContainer/Audio/SFXSlider
@onready var music_slider: HSlider = $TabContainer/Audio/MusicSlider

@onready var speed_slider: HSlider = $TabContainer/Gameplay/SpeedSlider
@onready var contrails_check: CheckBox = $TabContainer/Gameplay/ContrailsCheck
@onready var auto_intercept_check: CheckBox = $TabContainer/Gameplay/AutoInterceptCheck
@onready var difficulty_option: OptionButton = $TabContainer/Gameplay/DifficultyOption

@onready var apply_button: Button = $ButtonContainer/ApplyButton
@onready var reset_button: Button = $ButtonContainer/ResetButton
@onready var back_button: Button = $ButtonContainer/BackButton


func _ready() -> void:
	# Setup options
	_setup_options()
	
	# Load current settings
	_load_settings()
	
	# Setup button animations
	ButtonAnimations.setup_button(apply_button)
	ButtonAnimations.setup_button(reset_button)
	ButtonAnimations.setup_button(back_button)
	
	# Connect buttons
	apply_button.pressed.connect(_on_apply)
	reset_button.pressed.connect(_on_reset)
	back_button.pressed.connect(_on_back)
	
	# Connect sliders
	master_slider.value_changed.connect(_on_master_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)


func _setup_options() -> void:
	"""Setup option buttons"""
	# MSAA options
	msaa_option.add_item("Off")
	msaa_option.add_item("2x")
	msaa_option.add_item("4x")
	msaa_option.add_item("8x")
	
	# Difficulty options
	difficulty_option.add_item("Easy")
	difficulty_option.add_item("Normal")
	difficulty_option.add_item("Hard")
	difficulty_option.add_item("Expert")


func _load_settings() -> void:
	"""Load settings from Settings autoload"""
	# Graphics
	fullscreen_check.button_pressed = Settings.graphics.get("fullscreen", false)
	vsync_check.button_pressed = Settings.graphics.get("vsync", true)
	
	var msaa: int = Settings.graphics.get("anti_aliasing", 2)
	msaa_option.selected = _msaa_to_index(msaa)
	
	shadows_check.button_pressed = Settings.graphics.get("shadows", true)
	
	# Audio
	master_slider.value = Settings.audio.get("master_volume", 1.0)
	sfx_slider.value = Settings.audio.get("sfx_volume", 1.0)
	music_slider.value = Settings.audio.get("music_volume", 0.8)
	
	# Gameplay
	speed_slider.value = Settings.gameplay.get("speed_default", 1.0)
	contrails_check.button_pressed = Settings.gameplay.get("show_contrails", true)
	auto_intercept_check.button_pressed = Settings.gameplay.get("auto_intercept", false)
	
	var difficulty: String = Settings.gameplay.get("difficulty", "normal")
	difficulty_option.selected = _difficulty_to_index(difficulty)


func _save_settings() -> void:
	"""Save settings"""
	# Graphics
	Settings.graphics.fullscreen = fullscreen_check.button_pressed
	Settings.graphics.vsync = vsync_check.button_pressed
	Settings.graphics.anti_aliasing = _index_to_msaa(msaa_option.selected)
	Settings.graphics.shadows = shadows_check.button_pressed
	
	# Audio
	Settings.audio.master_volume = master_slider.value
	Settings.audio.sfx_volume = sfx_slider.value
	Settings.audio.music_volume = music_slider.value
	
	# Gameplay
	Settings.gameplay.speed_default = speed_slider.value
	Settings.gameplay.show_contrails = contrails_check.button_pressed
	Settings.gameplay.auto_intercept = auto_intercept_check.button_pressed
	Settings.gameplay.difficulty = _index_to_difficulty(difficulty_option.selected)
	
	Settings.save_settings()
	Settings.apply_settings()


func _msaa_to_index(msaa: int) -> int:
	"""Convert MSAA value to index"""
	match msaa:
		0: return 0
		2: return 1
		4: return 2
		8: return 3
		_: return 2


func _index_to_msaa(index: int) -> int:
	"""Convert index to MSAA value"""
	match index:
		0: return 0
		1: return 2
		2: return 4
		3: return 8
		_: return 4


func _difficulty_to_index(difficulty: String) -> int:
	"""Convert difficulty string to index"""
	match difficulty.to_lower():
		"easy": return 0
		"normal": return 1
		"hard": return 2
		"expert": return 3
		_: return 1


func _index_to_difficulty(index: int) -> String:
	"""Convert index to difficulty string"""
	match index:
		0: return "easy"
		1: return "normal"
		2: return "hard"
		3: return "expert"
		_: return "normal"


func _on_master_changed(value: float) -> void:
	"""Update master volume in real-time"""
	AudioManager.set_master_volume(value)


func _on_sfx_changed(value: float) -> void:
	"""Update SFX volume in real-time"""
	AudioManager.set_sfx_volume(value)


func _on_music_changed(value: float) -> void:
	"""Update music volume in real-time"""
	AudioManager.set_music_volume(value)


func _on_apply() -> void:
	"""Apply settings"""
	AudioManager.play_click()
	_save_settings()


func _on_reset() -> void:
	"""Reset to defaults"""
	AudioManager.play_click()
	Settings.reset_to_defaults()
	_load_settings()


func _on_back() -> void:
	"""Go back to main menu"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()
	else:
		queue_free()