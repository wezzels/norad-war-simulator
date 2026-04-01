## scenario_validator.gd
## Validates scenario files for correctness
## Ensures all required fields and references exist

extends Node


# Validation result
var errors: Array[String] = []
var warnings: Array[String] = []


func validate(scenario: Dictionary) -> bool:
	"""Validate a scenario dictionary"""
	errors.clear()
	warnings.clear()
	
	# Check required fields
	_validate_required_fields(scenario)
	
	# Check references
	_validate_references(scenario)
	
	# Check values
	_validate_values(scenario)
	
	return errors.is_empty()


func _validate_required_fields(scenario: Dictionary) -> void:
	"""Check all required fields exist"""
	var required: Array[String] = [
		"id", "name", "description", "difficulty",
		"launch_sites", "missile_waves", "interceptors"
	]
	
	for field: String in required:
		if not scenario.has(field):
			errors.append("Missing required field: %s" % field)
		elif scenario[field] == null or (scenario[field] is String and scenario[field].is_empty()):
			errors.append("Field cannot be empty: %s" % field)


func _validate_references(scenario: Dictionary) -> void:
	"""Check all references to data files are valid"""
	var launch_sites: Array = load_json("res://data/launch_sites.json")
	var cities: Array = load_json("res://data/cities.json")
	
	var valid_sites: Array[String] = []
	for site: Dictionary in launch_sites:
		valid_sites.append(site.name)
	
	var valid_cities: Array[String] = []
	for city: Dictionary in cities:
		valid_cities.append(city.name)
	
	# Check launch sites
	for site_ref: Dictionary in scenario.get("launch_sites", []):
		var site_name: String = site_ref.get("name", "")
		if site_name not in valid_sites:
			errors.append("Invalid launch site: %s" % site_name)
	
	# Check missile waves
	for wave: Dictionary in scenario.get("missile_waves", []):
		if wave.has("missiles"):
			for missile: Dictionary in wave.missiles:
				var origin: String = missile.get("origin", "")
				var target: String = missile.get("target", "")
				
				if origin not in valid_sites:
					errors.append("Invalid missile origin: %s" % origin)
				
				if target not in valid_cities:
					errors.append("Invalid missile target: %s" % target)


func _validate_values(scenario: Dictionary) -> void:
	"""Check values are in valid ranges"""
	# Difficulty
	var difficulty: int = scenario.get("difficulty", 1)
	if difficulty < 1 or difficulty > 4:
		errors.append("Difficulty must be 1-4, got: %d" % difficulty)
	
	# Time limit
	var time_limit: Variant = scenario.get("time_limit")
	if time_limit != null and time_limit is int:
		if time_limit < 0:
			errors.append("Time limit cannot be negative")
		elif time_limit > 0 and time_limit < 60:
			warnings.append("Time limit less than 60 seconds may be too short")
	
	# Interceptors
	var interceptors: Dictionary = scenario.get("interceptors", {})
	for type: String in ["GBI", "THAAD", "Patriot"]:
		var count: int = interceptors.get(type, 0)
		if count < 0:
			errors.append("Interceptor count cannot be negative: %s" % type)
		elif count > 1000:
			warnings.append("Very high interceptor count: %s = %d" % [type, count])
	
	# Victory conditions
	var victory: Dictionary = scenario.get("victory_conditions", {})
	var cities_saved: int = victory.get("cities_saved_min", 0)
	if cities_saved < 0:
		errors.append("cities_saved_min cannot be negative")
	elif cities_saved > 23:
		warnings.append("cities_saved_min (%d) exceeds total cities (23)" % cities_saved)
	
	# Missile count vs victory condition
	var total_missiles: int = 0
	for wave: Dictionary in scenario.get("missile_waves", []):
		if wave.has("missiles"):
			total_missiles += wave.missiles.size()
		elif wave.has("missiles_count"):
			total_missiles += wave.missiles_count
	
	if total_missiles > 23 - cities_saved:
		warnings.append("Scenario may be impossible: %d missiles, need %d cities saved" % [total_missiles, cities_saved])


func load_json(path: String) -> Array:
	"""Load JSON data from file"""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return []
	
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return []
	
	return json.data


func get_errors() -> Array[String]:
	"""Get all validation errors"""
	return errors.duplicate()


func get_warnings() -> Array[String]:
	"""Get all validation warnings"""
	return warnings.duplicate()


func has_errors() -> bool:
	"""Check if there are any errors"""
	return not errors.is_empty()


func get_report() -> String:
	"""Get formatted validation report"""
	var report: String = "Scenario Validation Report\n"
	report += "========================\n\n"
	
	if errors.is_empty() and warnings.is_empty():
		report += "✓ Scenario is valid\n"
		return report
	
	if not errors.is_empty():
		report += "ERRORS:\n"
		for error: String in errors:
			report += "  ✗ %s\n" % error
		report += "\n"
	
	if not warnings.is_empty():
		report += "WARNINGS:\n"
		for warning: String in warnings:
			report += "  ⚠ %s\n" % warning
	
	return report