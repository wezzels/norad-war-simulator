## main_menu.gd
## Main menu controller
## Handles menu button presses and navigation

extends Control

# Nodes
@onready var new_game_button: Button = $ButtonContainer/NewGameButton
@onready var campaign_button: Button = $ButtonContainer/CampaignButton
@onready var editor_button: Button = $ButtonContainer/EditorButton
@onready var continue_button: Button = $ButtonContainer/ContinueButton
@onready var multiplayer_button: Button = $ButtonContainer/MultiplayerButton
@onready var achievements_button: Button = $ButtonContainer/AchievementsButton
@onready var workshop_button: Button = $ButtonContainer/WorkshopButton
@onready var leaderboards_button: Button = $ButtonContainer/LeaderboardsButton
@onready var settings_button: Button = $ButtonContainer/SettingsButton
@onready var quit_button: Button = $ButtonContainer/QuitButton
@onready var version_label: Label = $Version

# Animation
const ANIMATION_DURATION: float = 0.3
const STAGGER_DELAY: float = 0.05


func _ready() -> void:
	# Apply button animations
	ButtonAnimations.setup_button(new_game_button)
	ButtonAnimations.setup_button(campaign_button)
	ButtonAnimations.setup_button(editor_button)
	ButtonAnimations.setup_button(continue_button)
	ButtonAnimations.setup_button(multiplayer_button)
	ButtonAnimations.setup_button(achievements_button)
	ButtonAnimations.setup_button(workshop_button)
	ButtonAnimations.setup_button(leaderboards_button)
	ButtonAnimations.setup_button(settings_button)
	ButtonAnimations.setup_button(quit_button)
	
	# Connect buttons
	new_game_button.pressed.connect(_on_new_game)
	campaign_button.pressed.connect(_on_campaign)
	editor_button.pressed.connect(_on_editor)
	continue_button.pressed.connect(_on_continue)
	multiplayer_button.pressed.connect(_on_multiplayer)
	achievements_button.pressed.connect(_on_achievements)
	workshop_button.pressed.connect(_on_workshop)
	leaderboards_button.pressed.connect(_on_leaderboards)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	
	# Check for saved game
	if not has_saved_game():
		continue_button.disabled = true
		continue_button.modulate = Color(0.5, 0.5, 0.5, 1.0)
	
	# Set version
	if version_label:
		version_label.text = "v0.5.0-alpha"
	
	# Animate buttons in
	_animate_buttons_in()
	
	# Focus first button
	new_game_button.grab_focus()
	
	# Play menu music
	AudioManager.play_music("menu", 2.0)


func _animate_buttons_in() -> void:
	"""Animate buttons sliding in from the side"""
	var buttons: Array[Button] = [
		new_game_button,
		campaign_button,
		editor_button,
		continue_button,
		multiplayer_button,
		settings_button,
		quit_button
	]
	
	for i: int in range(buttons.size()):
		var button: Button = buttons[i]
		var target_pos: Vector2 = button.position
		
		# Start from left side
		button.position.x -= 200.0
		button.modulate.a = 0.0
		
		# Animate to target
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_interval(i * STAGGER_DELAY)
		tween.tween_property(button, "position:x", target_pos.x + 200.0, ANIMATION_DURATION)
		tween.parallel().tween_property(button, "modulate:a", 1.0, ANIMATION_DURATION)


func _on_new_game() -> void:
	"""Start new game - show scenario selection"""
	AudioManager.play_click()
	
	# Go to scenario selection
	var main: Node = get_parent()
	if main.has_method("load_scenario_select"):
		main.load_scenario_select()


func _on_campaign() -> void:
	"""Start campaign mode"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main.has_method("load_campaign_menu"):
		main.load_campaign_menu()


func _on_editor() -> void:
	"""Open scenario editor"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main.has_method("load_scenario_editor"):
		main.load_scenario_editor()


func _on_continue() -> void:
	"""Continue saved game"""
	AudioManager.play_click()
	
	# TODO: Load saved game state
	var main: Node = get_parent()
	if main.has_method("load_game"):
		main.load_game("continue")


func _on_multiplayer() -> void:
	"""Open multiplayer menu"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main.has_method("load_multiplayer_menu"):
		main.load_multiplayer_menu()


func _on_achievements() -> void:
	"""Open achievements screen"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main.has_method("load_achievements"):
		main.load_achievements()


func _on_workshop() -> void:
	"""Open workshop browser"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main.has_method("load_workshop"):
		main.load_workshop()


func _on_leaderboards() -> void:
	"""Open leaderboards"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main.has_method("load_leaderboards"):
		main.load_leaderboards()


func _on_settings() -> void:
	"""Open settings menu"""
	AudioManager.play_click()
	
	# TODO: Show settings scene
	push_warning("Settings menu not yet implemented")


func _on_quit() -> void:
	"""Quit the game"""
	AudioManager.play_click()
	
	# Small delay for click sound
	await get_tree().create_timer(0.1).timeout
	
	var main: Node = get_parent()
	if main.has_method("quit_game"):
		main.quit_game()
	else:
		get_tree().quit()


func has_saved_game() -> bool:
	"""Check if a saved game exists"""
	return FileAccess.file_exists("user://savegame.save")