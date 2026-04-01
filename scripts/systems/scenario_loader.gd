## scenario_loader.gd
## Loads and manages game scenarios
## Parses JSON scenario files and initializes game state

extends Node


# Signals
signal scenario_loaded(scenario: Dictionary)
signal wave_started(wave_index: int)
signal scenario_complete()

# Loaded scenario
var current_scenario: Dictionary = {}
var current_wave: int = 0
var wave_timer: float = 0.0
var scenario_active: bool = false


func load_scenario(scenario_name: String) -> bool:
	"""Load a scenario from JSON file"""
	var path: String = "res://data/scenarios/%s.json" % scenario_name
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Scenario not found: %s" % scenario_name)
		return false
	
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	var error: int = json.parse(json_string)
	
	if error != OK:
		push_error("Failed to parse scenario: %s" % scenario_name)
		return false
	
	current_scenario = json.data
	current_wave = 0
	wave_timer = 0.0
	scenario_active = false
	
	scenario_loaded.emit(current_scenario)
	return true


func start_scenario() -> void:
	"""Start the loaded scenario"""
	if current_scenario.is_empty():
		push_error("No scenario loaded")
		return
	
	# Reset game state
	GameState.reset_state()
	
	# Set initial DEFCON
	if current_scenario.has("initial_defcon"):
		GameState.set_defcon(current_scenario.initial_defcon)
	else:
		GameState.set_defcon(3)  # Default
	
	# Initialize interceptor counts
	if current_scenario.has("interceptors"):
		# Would set up interceptor inventory
		pass
	
	# Start scenario
	scenario_active = true
	
	# Process first wave (time 0)
	if current_scenario.has("missile_waves") and current_scenario.missile_waves.size() > 0:
		process_wave(0)


func _process(delta: float) -> void:
	if not scenario_active:
		return
	
	# Update wave timer
	wave_timer += delta * GameState.speed_multiplier
	
	# Check for next wave
	if current_scenario.has("missile_waves"):
		var waves: Array = current_scenario.missile_waves
		for i: int in range(waves.size()):
			var wave: Dictionary = waves[i]
			var wave_time: float = wave.get("time", 0.0)
			
			# Check if this wave should start
			if wave_time <= wave_timer and i > current_wave:
				process_wave(i)
				current_wave = i
		
		# Check if all waves complete
		if current_wave >= waves.size() - 1:
			# All waves launched, check for completion
			if GameState.missiles.is_empty() and GameState.interceptors.is_empty():
				end_scenario()


func process_wave(wave_index: int) -> void:
	"""Process a missile wave"""
	var wave: Dictionary = current_scenario.missile_waves[wave_index]
	
	wave_started.emit(wave_index)
	
	# Launch missiles in wave
	if wave.has("missiles"):
		for missile: Dictionary in wave.missiles:
			var origin: String = missile.get("origin", "")
			var target: String = missile.get("target", "")
			var type: String = missile.get("type", "ICBM")
			
			GameState.launch_missile(origin, target, type)
	
	# Random missiles (for WW3 scenario)
	elif wave.has("missiles_count"):
		var count: int = wave.missiles_count
		var targets: String = wave.get("targets", "random")
		
		# Would generate random targets
		# For now, placeholder
		push_warning("Random missiles not yet implemented")


func end_scenario() -> void:
	"""End scenario and check victory conditions"""
	scenario_active = false
	
	# Check victory
	var victory: bool = false
	if current_scenario.has("victory_conditions"):
		var conditions: Dictionary = current_scenario.victory_conditions
		var cities_saved_min: int = conditions.get("cities_saved_min", 0)
		
		# Calculate cities saved (total - hit)
		var total_cities: int = 23  # From cities.json
		var cities_hit: int = GameState.stats.cities_hit
		var cities_saved: int = total_cities - cities_hit
		
		if cities_saved >= cities_saved_min:
			victory = true
	
	scenario_complete.emit()
	
	# Would show victory/defeat screen
	if victory:
		push_message("VICTORY", "Mission complete!")
	else:
		push_message("DEFEAT", "Mission failed!")


func push_message(title: String, message: String) -> void:
	"""Show a message to the player"""
	# Would show UI message
	print("[%s] %s" % [title, message])


func get_scenario_info() -> Dictionary:
	"""Get info about current scenario"""
	return {
		"id": current_scenario.get("id", ""),
		"name": current_scenario.get("name", ""),
		"description": current_scenario.get("description", ""),
		"difficulty": current_scenario.get("difficulty", 1),
		"wave": current_wave,
		"total_waves": current_scenario.get("missile_waves", []).size(),
		"active": scenario_active
	}


func list_scenarios() -> Array[Dictionary]:
	"""List all available scenarios"""
	var scenarios: Array[Dictionary] = []
	var dir: DirAccess = DirAccess.open("res://data/scenarios/")
	
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var path: String = "res://data/scenarios/%s" % file_name
				var file: FileAccess = FileAccess.open(path, FileAccess.READ)
				if file:
					var json: JSON = JSON.new()
					if json.parse(file.get_as_text()) == OK:
						scenarios.append({
							"id": json.data.get("id", ""),
							"name": json.data.get("name", ""),
							"difficulty": json.data.get("difficulty", 1)
						})
			file_name = dir.get_next()
	
	return scenarios