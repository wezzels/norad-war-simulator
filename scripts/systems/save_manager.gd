## save_manager.gd
## Save and load game state
## Handles scenarios, progress, and settings persistence

extends Node


# Save paths
const SAVE_DIR: String = "user://saves/"
const SETTINGS_FILE: String = "user://settings.cfg"
const PROGRESS_FILE: String = "user://progress.json"

# Save slots
const MAX_SLOTS: int = 10

# Signals
signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)
signal autosave_triggered()


func _ready() -> void:
	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func save_game(slot: int = 0) -> bool:
	"""Save current game state to a slot"""
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("Invalid save slot: %d" % slot)
		return false
	
	var save_data: Dictionary = {
		"version": "0.1.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"scenario": GameState.current_scenario,
		"game_state": _extract_game_state(),
		"statistics": GameState.stats.duplicate(true),
		"settings": _extract_settings()
	}
	
	var file_path: String = "%sslot_%d.save" % [SAVE_DIR, slot]
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if not file:
		push_error("Failed to open save file: %s" % file_path)
		save_completed.emit(slot, false)
		return false
	
	var json_string: String = JSON.stringify(save_data, "  ")
	file.store_string(json_string)
	file.close()
	
	print("Game saved to slot %d" % slot)
	save_completed.emit(slot, true)
	return true


func load_game(slot: int = 0) -> bool:
	"""Load game state from a slot"""
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("Invalid save slot: %d" % slot)
		return false
	
	var file_path: String = "%sslot_%d.save" % [SAVE_DIR, slot]
	
	if not FileAccess.file_exists(file_path):
		push_error("Save file not found: %s" % file_path)
		load_completed.emit(slot, false)
		return false
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open save file: %s" % file_path)
		load_completed.emit(slot, false)
		return false
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		push_error("Failed to parse save file")
		load_completed.emit(slot, false)
		return false
	
	var save_data: Dictionary = json.data
	
	# Validate version
	if save_data.get("version", "0.0.0") != "0.1.0":
		push_warning("Save version mismatch: %s" % save_data.version)
	
	# Restore game state
	_restore_game_state(save_data.game_state)
	GameState.stats = save_data.statistics
	
	# Load scenario
	if save_data.has("scenario") and not save_data.scenario.is_empty():
		GameState.current_scenario = save_data.scenario
	
	print("Game loaded from slot %d" % slot)
	load_completed.emit(slot, true)
	return true


func _extract_game_state() -> Dictionary:
	"""Extract current game state for saving"""
	return {
		"paused": GameState.paused,
		"speed_multiplier": GameState.speed_multiplier,
		"current_defcon": GameState.current_defcon,
		"simulation_time": GameState.simulation_time,
		"missiles": GameState.missiles.duplicate(true),
		"interceptors": GameState.interceptors.duplicate(true),
		"detonations": GameState.detonations.duplicate(true),
		"alerts": GameState.alerts.duplicate(true)
	}


func _restore_game_state(state: Dictionary) -> void:
	"""Restore game state from save data"""
	GameState.paused = state.get("paused", false)
	GameState.speed_multiplier = state.get("speed_multiplier", 1.0)
	GameState.current_defcon = state.get("current_defcon", 3)
	GameState.simulation_time = state.get("simulation_time", 0.0)
	GameState.missiles = state.get("missiles", [])
	GameState.interceptors = state.get("interceptors", [])
	GameState.detonations = state.get("detonations", [])
	GameState.alerts = state.get("alerts", [])


func _extract_settings() -> Dictionary:
	"""Extract settings for saving"""
	return {
		"graphics": Settings.graphics.duplicate(true),
		"audio": Settings.audio.duplicate(true),
		"gameplay": Settings.gameplay.duplicate(true)
	}


func get_save_slots() -> Array[Dictionary]:
	"""Get list of all save slots with metadata"""
	var slots: Array[Dictionary] = []
	
	for i: int in range(MAX_SLOTS):
		var file_path: String = "%sslot_%d.save" % [SAVE_DIR, i]
		var slot_info: Dictionary = {
			"slot": i,
			"empty": true,
			"timestamp": "",
			"scenario": ""
		}
		
		if FileAccess.file_exists(file_path):
			var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var json: JSON = JSON.new()
				if json.parse(file.get_as_text()) == OK:
					var data: Dictionary = json.data
					slot_info.empty = false
					slot_info.timestamp = data.get("timestamp", "")
					slot_info.scenario = data.get("scenario", {}).get("name", "Unknown")
				file.close()
		
		slots.append(slot_info)
	
	return slots


func delete_save(slot: int) -> bool:
	"""Delete a save file"""
	if slot < 0 or slot >= MAX_SLOTS:
		return false
	
	var file_path: String = "%sslot_%d.save" % [SAVE_DIR, slot]
	
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		return true
	
	return false


func quick_save() -> bool:
	"""Quick save to slot 0"""
	return save_game(0)


func quick_load() -> bool:
	"""Quick load from slot 0"""
	return load_game(0)


func autosave() -> void:
	"""Auto-save to special autosave slot"""
	var success: bool = save_game(99)  # Reserved for autosave
	if success:
		print("Autosave completed")
		autosave_triggered.emit()


## Progress tracking (achievements, unlocks, etc.)
func save_progress() -> bool:
	"""Save player progress (scenarios completed, etc.)"""
	var progress: Dictionary = load_progress()
	
	# Update progress
	progress["last_played"] = Time.get_datetime_string_from_system()
	progress["total_playtime"] = progress.get("total_playtime", 0) + 1  # Would track actual time
	progress["scenarios_completed"] = progress.get("scenarios_completed", [])
	
	var file: FileAccess = FileAccess.open(PROGRESS_FILE, FileAccess.WRITE)
	if not file:
		return false
	
	file.store_string(JSON.stringify(progress, "  "))
	file.close()
	return true


func load_progress() -> Dictionary:
	"""Load player progress"""
	if not FileAccess.file_exists(PROGRESS_FILE):
		return {
			"scenarios_completed": [],
			"achievements": [],
			"total_playtime": 0,
			"statistics": {
				"missiles_intercepted": 0,
				"cities_saved": 0,
				"scenarios_played": 0
			}
		}
	
	var file: FileAccess = FileAccess.open(PROGRESS_FILE, FileAccess.READ)
	if not file:
		return {}
	
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	
	return json.data


func mark_scenario_completed(scenario_id: String) -> void:
	"""Mark a scenario as completed"""
	var progress: Dictionary = load_progress()
	var completed: Array = progress.get("scenarios_completed", [])
	
	if not completed.has(scenario_id):
		completed.append(scenario_id)
		progress["scenarios_completed"] = completed
		save_progress()


func is_scenario_completed(scenario_id: String) -> bool:
	"""Check if a scenario has been completed"""
	var progress: Dictionary = load_progress()
	return progress.get("scenarios_completed", []).has(scenario_id)


func get_completed_scenarios() -> Array:
	"""Get list of completed scenario IDs"""
	var progress: Dictionary = load_progress()
	return progress.get("scenarios_completed", [])