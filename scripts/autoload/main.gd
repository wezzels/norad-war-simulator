## main.gd
## Root scene script
## Handles scene transitions and initial loading

extends Node

# Scenes
const MENU_SCENE: PackedScene = preload("res://scenes/main_menu.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game.tscn")
const SCENARIO_SELECT_SCENE: PackedScene = preload("res://scenes/scenario_select.tscn")
const SCENARIO_EDITOR_SCENE: PackedScene = preload("res://scenes/scenario_editor.tscn")

# Scenes loaded dynamically (to avoid preload errors during export)
var multiplayer_menu_scene: PackedScene = null
var lobby_menu_scene: PackedScene = null
var achievements_scene: PackedScene = null
var workshop_scene: PackedScene = null
var leaderboard_scene: PackedScene = null

# Current scene
var current_scene: Node = null

# Selected scenario
var selected_scenario: String = "tutorial"


func _ready() -> void:
	# Load menu by default
	load_menu()
	
	# Print version
	print("NORAD War Simulator v0.5.0-alpha")
	print("Godot %s" % Engine.get_version_info().string)


func load_menu() -> void:
	"""Load the main menu"""
	change_scene(MENU_SCENE)


func load_campaign_menu() -> void:
	"""Load campaign menu"""
	change_scene(preload("res://scenes/campaign_menu.tscn"))
	
	await get_tree().process_frame
	
	var campaign_menu: Node = current_scene
	if campaign_menu and campaign_menu.has_signal("mission_selected"):
		campaign_menu.mission_selected.connect(_on_campaign_mission_selected)
		campaign_menu.back_pressed.connect(load_menu)


func show_mission_briefing(mission_index: int) -> void:
	"""Show mission briefing screen"""
	var mission: Dictionary = CampaignManager.get_mission(mission_index)
	if mission.is_empty():
		return
	
	change_scene(preload("res://scenes/mission_briefing.tscn"))
	
	await get_tree().process_frame
	
	var briefing: Node = current_scene
	if briefing and briefing.has_method("set_mission"):
		briefing.set_mission(mission)
		briefing.mission_started.connect(_on_mission_started.bind(mission_index))
		briefing.back_pressed.connect(load_campaign_menu)


func _on_campaign_mission_selected(mission_index: int) -> void:
	"""Handle mission selection from campaign"""
	show_mission_briefing(mission_index)


func _on_mission_started(mission_index: int) -> void:
	"""Start a campaign mission"""
	load_game("campaign_%d" % mission_index)


func load_scenario_select() -> void:
	"""Load scenario selection"""
	change_scene(SCENARIO_SELECT_SCENE)
	
	await get_tree().process_frame
	
	var select: Node = current_scene
	if select and select.has_signal("scenario_selected"):
		select.scenario_selected.connect(_on_scenario_selected)
		select.back_pressed.connect(load_menu)


func _on_scenario_selected(scenario_id: String) -> void:
	"""Handle scenario selection"""
	load_game(scenario_id)


func load_scenario_editor() -> void:
	"""Load scenario editor"""
	change_scene(SCENARIO_EDITOR_SCENE)


func load_multiplayer_menu() -> void:
	"""Load multiplayer menu"""
	# Load dynamically to avoid preload errors
	if multiplayer_menu_scene == null:
		multiplayer_menu_scene = load("res://scenes/multiplayer_menu.tscn")
	
	change_scene(multiplayer_menu_scene)
	
	await get_tree().process_frame
	
	var mp_menu: Node = current_scene
	if mp_menu and mp_menu.has_signal("back_pressed"):
		# Back is handled by the menu itself
		pass


func load_lobby() -> void:
	"""Load game lobby"""
	if lobby_menu_scene == null:
		lobby_menu_scene = load("res://scenes/lobby_menu.tscn")
	
	change_scene(lobby_menu_scene)
	
	await get_tree().process_frame
	
	var lobby: Node = current_scene
	if lobby and lobby.has_signal("game_started"):
		lobby.game_started.connect(_on_multiplayer_game_started)


func _on_multiplayer_game_started() -> void:
	"""Start multiplayer game"""
	load_game("multiplayer")


func load_achievements() -> void:
	"""Load achievements screen"""
	if achievements_scene == null:
		achievements_scene = load("res://scenes/achievements_screen.tscn")
	
	change_scene(achievements_scene)
	
	await get_tree().process_frame
	
	var achievements: Node = current_scene
	if achievements and achievements.has_signal("back_pressed"):
		achievements.back_pressed.connect(load_menu)


func load_workshop() -> void:
	"""Load workshop browser"""
	if workshop_scene == null:
		workshop_scene = load("res://scenes/workshop_browser.tscn")
	
	change_scene(workshop_scene)
	
	await get_tree().process_frame
	
	var workshop: Node = current_scene
	if workshop and workshop.has_signal("back_pressed"):
		workshop.back_pressed.connect(load_menu)


func load_leaderboards() -> void:
	"""Load leaderboard screen"""
	if leaderboard_scene == null:
		leaderboard_scene = load("res://scenes/leaderboard_screen.tscn")
	
	change_scene(leaderboard_scene)


func load_game(scenario: String = "tutorial") -> void:
	"""Load the game scene with a scenario"""
	selected_scenario = scenario
	change_scene(GAME_SCENE)
	
	# Wait for scene to be ready
	await get_tree().process_frame
	
	# Start scenario
	var game_controller: Node = current_scene.get_node_or_null("GameController")
	if game_controller and game_controller.has_method("start_scenario"):
		game_controller.start_scenario(scenario)


func change_scene(new_scene: PackedScene) -> void:
	"""Change to a new scene"""
	if current_scene:
		current_scene.queue_free()
	
	current_scene = new_scene.instantiate()
	add_child(current_scene)


func quit_game() -> void:
	"""Quit the game"""
	# Save settings
	Settings.save_settings()
	
	# Quit
	get_tree().quit()