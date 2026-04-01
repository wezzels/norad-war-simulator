## game_controller.gd
## Main game controller
## Manages game loop, spawns missiles, handles input

extends Node3D

# Nodes
@onready var globe: GlobeRenderer = $Globe
@onready var camera: Camera3D = $Camera
@onready var missile_container: Node3D = $MissileContainer
@onready var hud: CanvasLayer = $HUD

# Scenario
var scenario_loader: ScenarioLoader
var scenario_active: bool = false

# Missile scene
const MissileScene: PackedScene = preload("res://scenes/missile.tscn")


func _ready() -> void:
	# Create scenario loader
	scenario_loader = ScenarioLoader.new()
	add_child(scenario_loader)
	
	# Create detection manager
	var detection_manager: Node = DetectionManager.new()
	detection_manager.name = "DetectionManager"
	add_child(detection_manager)
	
	# Connect signals
	scenario_loader.scenario_loaded.connect(_on_scenario_loaded)
	scenario_loader.wave_started.connect(_on_wave_started)
	scenario_loader.scenario_complete.connect(_on_scenario_complete)
	
	GameState.missile_launched.connect(_on_missile_launched)
	GameState.detonation_detected.connect(_on_detonation)
	
	# For testing, load tutorial scenario
	# Uncomment to auto-start:
	# start_scenario("tutorial")


func _process(delta: float) -> void:
	# Handle keyboard shortcuts
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
		return  # Don't process other inputs while pausing
	
	# If paused, don't process game logic
	if GameState.paused:
		return
	
	# Speed controls
	if Input.is_key_pressed(KEY_MINUS):
		GameState.set_speed(max(0.1, GameState.speed_multiplier - 0.5))
	if Input.is_key_pressed(KEY_EQUAL):
		GameState.set_speed(min(100.0, GameState.speed_multiplier + 0.5))
	
	# Number keys for quick speed
	for i: int in range(1, 10):
		if Input.is_key_pressed(KEY_0 + i):
			GameState.set_speed(float(i))
			break
	if Input.is_key_pressed(KEY_0):
		GameState.set_speed(1.0)
	
	# Debug: launch test missile with Space
	if Input.is_key_pressed(KEY_SPACE) and not scenario_active:
		launch_test_missile()


func start_scenario(scenario_name: String) -> void:
	"""Start a scenario"""
	scenario_loader.load_scenario(scenario_name)
	scenario_loader.start_scenario()
	scenario_active = true


func toggle_pause() -> void:
	"""Toggle pause state and show pause menu"""
	if GameState.paused:
		GameState.resume()
		# Remove pause menu if exists
		var pause_menu: Node = get_node_or_null("PauseMenu")
		if pause_menu:
			pause_menu.queue_free()
	else:
		GameState.pause()
		# Show pause menu
		var pause_menu: Node = preload("res://scenes/pause_menu.tscn").instantiate()
		pause_menu.name = "PauseMenu"
		add_child(pause_menu)


func launch_test_missile() -> void:
	"""Launch a test missile for debugging"""
	var sites: Array = load_json("res://data/launch_sites.json")
	var cities: Array = load_json("res://data/cities.json")
	
	if sites.is_empty() or cities.is_empty():
		return
	
	var site: Dictionary = sites[randi() % sites.size()]
	var city: Dictionary = cities[randi() % cities.size()]
	
	GameState.launch_missile(site.name, city.name, "ICBM")


func spawn_missile(missile_data: Dictionary) -> void:
	"""Spawn a missile in the 3D scene"""
	var missile: Node3D = MissileScene.instantiate()
	missile.initialize(missile_data)
	missile_container.add_child(missile)
	
	# Draw trajectory on globe
	var origin_coords: Dictionary = get_site_coords(missile_data.origin)
	var target_coords: Dictionary = get_city_coords(missile_data.target)
	
	globe.draw_trajectory(
		origin_coords.lat, origin_coords.lon,
		target_coords.lat, target_coords.lon
	)


func get_site_coords(name: String) -> Dictionary:
	"""Get coordinates for a launch site"""
	var sites: Array = load_json("res://data/launch_sites.json")
	for site: Dictionary in sites:
		if site.name == name:
			return {"lat": site.lat, "lon": site.lon}
	return {"lat": 0.0, "lon": 0.0}


func get_city_coords(name: String) -> Dictionary:
	"""Get coordinates for a city"""
	var cities: Array = load_json("res://data/cities.json")
	for city: Dictionary in cities:
		if city.name == name:
			return {"lat": city.lat, "lon": city.lon}
	return {"lat": 0.0, "lon": 0.0}


func _on_scenario_loaded(scenario: Dictionary) -> void:
	print("Loaded scenario: %s" % scenario.name)


func _on_wave_started(wave_index: int) -> void:
	print("Wave %d started" % (wave_index + 1))


func _on_scenario_complete() -> void:
	scenario_active = false
	print("Scenario complete!")


func _on_missile_launched(missile_data: Dictionary) -> void:
	spawn_missile(missile_data)
	AudioManager.play_launch()


func _on_detonation(detonation: Dictionary) -> void:
	AudioManager.play_detonation()
	globe.highlight_city(detonation.city)


func load_json(path: String) -> Array:
	"""Load JSON data from file"""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return []
	
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		return []
	
	return json.data

func on_game_complete(success: bool) -> void:
	"""Handle game completion for campaign integration"""
	var stats: Dictionary = {
		"missiles_intercepted": GameState.stats.missiles_intercepted,
		"cities_saved": 23 - GameState.stats.cities_hit,
		"cities_hit": GameState.stats.cities_hit,
		"detonations": GameState.stats.detonations_detected,
		"time_seconds": GameState.simulation_time,
		"min_defcon": GameState.current_defcon
	}
	
	# Report to campaign manager if in campaign
	CampaignManager.complete_mission(success)
	
	# Record statistics
	Statistics.record_game(scenario_loader.current_scenario.get("id", ""), {
		"completed": success,
		"missiles_intercepted": stats.missiles_intercepted,
		"cities_saved": stats.cities_saved,
		"cities_hit": stats.cities_hit,
		"detonations": stats.detonations,
		"time_seconds": stats.time_seconds,
		"min_defcon": stats.min_defcon,
		"interceptors_used": {
			"GBI": DefenseManager.inventory.GBI.total - DefenseManager.inventory.GBI.available,
			"THAAD": DefenseManager.inventory.THAAD.total - DefenseManager.inventory.THAAD.available,
			"Patriot": DefenseManager.inventory.Patriot.total - DefenseManager.inventory.Patriot.available
		}
	})
	
	# Show debriefing screen
	var debriefing: Node = preload("res://scenes/debriefing_screen.tscn").instantiate()
	debriefing.setup(success, stats, scenario_loader.current_scenario)
	debriefing.continue_pressed.connect(_on_debriefing_continue)
	debriefing.retry_pressed.connect(_on_debriefing_retry)
	add_child(debriefing)


func _on_debriefing_continue() -> void:
	"""Continue from debriefing"""
	# Check if campaign is complete
	if CampaignManager.is_campaign_complete():
		show_victory_screen()
		return
	
	# Return to campaign menu
	var main: Node = get_parent()
	if main and main.has_method("load_campaign_menu"):
		main.load_campaign_menu()
	else:
		main.load_menu()


func _on_debriefing_retry() -> void:
	"""Retry the mission"""
	# Restart current scenario
	if scenario_loader.current_scenario.has("id"):
		start_scenario(scenario_loader.current_scenario.id)


func show_victory_screen() -> void:
	"""Show victory screen when campaign is complete"""
	var victory: Node = preload("res://scenes/victory_screen.tscn").instantiate()
	victory.setup(CampaignManager.get_final_stats())
	victory.return_to_menu.connect(_on_victory_return)
	add_child(victory)


func _on_victory_return() -> void:
	"""Return to main menu after victory"""
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()
