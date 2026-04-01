## scenario_manager.gd
## Manages built-in and custom scenarios
## Lists, loads, saves, and validates scenarios

extends Node


# Signals
signal scenarios_updated()

# Paths
const BUILTIN_SCENARIOS_PATH: String = "res://data/scenarios/"
const CUSTOM_SCENARIOS_PATH: String = "user://scenarios/"

# Cache
var builtin_scenarios: Array[Dictionary] = []
var custom_scenarios: Array[Dictionary] = []


func _ready() -> void:
	load_all_scenarios()


func load_all_scenarios() -> void:
	"""Load all built-in and custom scenarios"""
	builtin_scenarios = _load_scenarios_from_path(BUILTIN_SCENARIOS_PATH)
	custom_scenarios = _load_scenarios_from_path(CUSTOM_SCENARIOS_PATH)
	scenarios_updated.emit()


func _load_scenarios_from_path(path: String) -> Array[Dictionary]:
	"""Load all scenarios from a directory"""
	var scenarios: Array[Dictionary] = []
	
	var dir: DirAccess
	if path.begins_with("res://"):
		dir = DirAccess.open(path)
	else:
		# Ensure user directory exists
		DirAccess.make_dir_recursive_absolute(CUSTOM_SCENARIOS_PATH)
		dir = DirAccess.open(path)
	
	if not dir:
		return scenarios
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			var full_path: String = path.path_join(file_name)
			var scenario: Dictionary = load_scenario_file(full_path)
			if not scenario.is_empty():
				scenario["_path"] = full_path
				scenarios.append(scenario)
		file_name = dir.get_next()
	
	return scenarios


func load_scenario_file(path: String) -> Dictionary:
	"""Load a single scenario file"""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("Failed to parse scenario: %s" % path)
		return {}
	
	return json.data


func get_all_scenarios() -> Array[Dictionary]:
	"""Get all scenarios (built-in + custom)"""
	var all: Array[Dictionary] = []
	all.append_array(builtin_scenarios)
	all.append_array(custom_scenarios)
	return all


func get_builtin_scenarios() -> Array[Dictionary]:
	"""Get built-in scenarios only"""
	return builtin_scenarios.duplicate(true)


func get_custom_scenarios() -> Array[Dictionary]:
	"""Get custom scenarios only"""
	return custom_scenarios.duplicate(true)


func get_scenario_by_id(scenario_id: String) -> Dictionary:
	"""Find a scenario by ID"""
	for scenario: Dictionary in builtin_scenarios:
		if scenario.get("id", "") == scenario_id:
			return scenario.duplicate(true)
	
	for scenario: Dictionary in custom_scenarios:
		if scenario.get("id", "") == scenario_id:
			return scenario.duplicate(true)
	
	return {}


func save_scenario(scenario: Dictionary) -> bool:
	"""Save a custom scenario"""
	# Validate first
	var validator: RefCounted = ScenarioValidator.new()
	if not validator.validate(scenario):
		push_error("Scenario validation failed")
		print(validator.get_report())
		return false
	
	# Ensure custom directory exists
	DirAccess.make_dir_recursive_absolute(CUSTOM_SCENARIOS_PATH)
	
	# Generate filename
	var file_name: String = "%s.json" % scenario.get("id", "custom_%d" % Time.get_ticks_msec())
	var file_path: String = CUSTOM_SCENARIOS_PATH.path_join(file_name)
	
	# Remove internal fields
	var save_data: Dictionary = scenario.duplicate()
	save_data.erase("_path")
	
	# Write file
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: %s" % file_path)
		return false
	
	file.store_string(JSON.stringify(save_data, "  "))
	file.close()
	
	# Reload scenarios
	load_all_scenarios()
	
	print("Scenario saved: %s" % file_path)
	return true


func delete_scenario(scenario_id: String) -> bool:
	"""Delete a custom scenario"""
	var scenario: Dictionary = get_scenario_by_id(scenario_id)
	if scenario.is_empty():
		push_error("Scenario not found: %s" % scenario_id)
		return false
	
	var path: String = scenario.get("_path", "")
	if path.is_empty():
		push_error("Cannot delete built-in scenario")
		return false
	
	if not path.begins_with("user://"):
		push_error("Cannot delete built-in scenario")
		return false
	
	# Delete file
	var err: int = DirAccess.remove_absolute(path)
	if err != OK:
		push_error("Failed to delete scenario: %s" % path)
		return false
	
	# Reload scenarios
	load_all_scenarios()
	
	print("Scenario deleted: %s" % path)
	return true


func duplicate_scenario(scenario_id: String, new_name: String) -> Dictionary:
	"""Duplicate a scenario with a new name"""
	var original: Dictionary = get_scenario_by_id(scenario_id)
	if original.is_empty():
		return {}
	
	var duplicate: Dictionary = original.duplicate(true)
	duplicate.id = "%s_copy_%d" % [original.id, Time.get_ticks_msec()]
	duplicate.name = new_name
	
	return duplicate


func validate_scenario(scenario: Dictionary) -> Dictionary:
	"""Validate a scenario and return results"""
	var validator: RefCounted = ScenarioValidator.new()
	var valid: bool = validator.validate(scenario)
	
	return {
		"valid": valid,
		"errors": validator.get_errors(),
		"warnings": validator.get_warnings(),
		"report": validator.get_report()
	}


func get_scenario_count() -> Dictionary:
	"""Get count of scenarios by type"""
	return {
		"builtin": builtin_scenarios.size(),
		"custom": custom_scenarios.size(),
		"total": builtin_scenarios.size() + custom_scenarios.size()
	}


func create_new_scenario(name: String = "New Scenario") -> Dictionary:
	"""Create a new empty scenario"""
	return {
		"id": "scenario_custom_%d" % Time.get_ticks_msec(),
		"name": name,
		"description": "A custom scenario",
		"difficulty": 1,
		"time_limit": null,
		"launch_sites": [],
		"missile_waves": [],
		"interceptors": {
			"GBI": 44,
			"THAAD": 100,
			"Patriot": 200
		},
		"victory_conditions": {
			"cities_saved_min": 20,
			"time_limit_seconds": null
		}
	}