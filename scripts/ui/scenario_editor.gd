## scenario_editor.gd
## Scenario editor controller
## Create, edit, and save custom scenarios

extends Control

# Signals
signal scenario_saved(scenario: Dictionary)
signal scenario_tested(scenario: Dictionary)
signal back_pressed()

# Nodes
@onready var name_edit: LineEdit = $Panel/VBoxContainer/NameEdit
@onready var description_edit: TextEdit = $Panel/VBoxContainer/DescriptionEdit
@onready var difficulty_spinbox: SpinBox = $Panel/VBoxContainer/DifficultySpinbox
@onready var time_limit_spinbox: SpinBox = $Panel/VBoxContainer/TimeLimitSpinbox

@onready var launch_sites_list: ItemList = $Panel/HBoxContainer/LaunchSitesPanel/LaunchSitesList
@onready var add_site_button: Button = $Panel/HBoxContainer/LaunchSitesPanel/AddSiteButton
@onready var remove_site_button: Button = $Panel/HBoxContainer/LaunchSitesPanel/RemoveSiteButton

@onready var cities_list: ItemList = $Panel/HBoxContainer/CitiesPanel/CitiesList
@onready var target_buttons: VBoxContainer = $Panel/HBoxContainer/CitiesPanel/TargetButtons

@onready var waves_container: VBoxContainer = $Panel/HBoxContainer/WavesPanel/WavesContainer
@onready var add_wave_button: Button = $Panel/HBoxContainer/WavesPanel/AddWaveButton

@onready var interceptors_spinbox_gbi: SpinBox = $Panel/VBoxContainer/InterceptorsPanel/GBISpinbox
@onready var interceptors_spinbox_thaad: SpinBox = $Panel/VBoxContainer/InterceptorsPanel/THAADSpinbox
@onready var interceptors_spinbox_patriot: SpinBox = $Panel/VBoxContainer/InterceptorsPanel/PatriotSpinbox

@onready var victory_cities_spinbox: SpinBox = $Panel/VBoxContainer/VictoryPanel/CitiesSavedSpinbox

@onready var validation_label: Label = $Panel/VBoxContainer/ValidationLabel

@onready var save_button: Button = $Panel/SaveButton
@onready var test_button: Button = $Panel/TestButton
@onready var back_button: Button = $Panel/BackButton

# Data
var current_scenario: Dictionary = {}
var launch_sites: Array[Dictionary] = []
var cities: Array[Dictionary] = []
var waves: Array[Dictionary] = []
var selected_targets: Array[String] = []


func _ready() -> void:
	# Connect buttons
	save_button.pressed.connect(_on_save)
	test_button.pressed.connect(_on_test)
	back_button.pressed.connect(_on_back)
	
	add_site_button.pressed.connect(_on_add_launch_site)
	remove_site_button.pressed.connect(_on_remove_launch_site)
	add_wave_button.pressed.connect(_on_add_wave)
	
	# Add new wave button for adding missiles
	var add_missile_button: Button = Button.new()
	add_missile_button.text = "Add Missiles"
	add_missile_button.pressed.connect(_on_add_missiles)
	
	# Load cities and launch sites
	load_cities()
	load_launch_sites()
	
	# Initialize empty scenario
	new_scenario()


func _on_add_missiles() -> void:
	"""Add missiles to selected wave"""
	AudioManager.play_click()
	# TODO: Open wave editor dialog
	# For now, add a simple missile
	if waves.is_empty():
		_on_add_wave()
	
	if not waves.is_empty():
		var last_wave: Dictionary = waves[-1]
		# Add a missile to the last wave
		if last_wave.has("missiles"):
			var origin: String = launch_sites[0].name if launch_sites.size() > 0 else "Unknown"
			var target: String = cities[0].name if cities.size() > 0 else "Unknown"
			last_wave.missiles.append({
				"origin": origin,
				"target": target,
				"type": "ICBM"
			})
			rebuild_waves_list()


func load_cities() -> void:
	"""Load city data"""
	var file: FileAccess = FileAccess.open("res://data/cities.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			cities = json.data
			
			# Populate cities list
			for city: Dictionary in cities:
				cities_list.add_item(city.name, null, false)


func load_launch_sites() -> void:
	"""Load launch site data"""
	var file: FileAccess = FileAccess.open("res://data/launch_sites.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			launch_sites = json.data
			
			# Populate launch sites list
			for site: Dictionary in launch_sites:
				launch_sites_list.add_item(site.name, null, false)


func new_scenario() -> void:
	"""Create a new empty scenario"""
	current_scenario = {
		"id": "scenario_custom_%d" % Time.get_ticks_msec(),
		"name": "New Scenario",
		"description": "",
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
	
	waves.clear()
	selected_targets.clear()
	
	update_ui_from_scenario()
	validate_current_scenario()


func validate_current_scenario() -> void:
	"""Validate and update status"""
	current_scenario = update_scenario_from_ui()
	var validation: Dictionary = ScenarioManager.validate_scenario(current_scenario)
	update_validation_status(validation)


func load_scenario(scenario_id: String) -> bool:
	"""Load an existing scenario"""
	var file: FileAccess = FileAccess.open("res://data/scenarios/%s.json" % scenario_id, FileAccess.READ)
	if not file:
		return false
	
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	
	current_scenario = json.data
	waves = current_scenario.get("missile_waves", []).duplicate(true)
	
	update_ui_from_scenario()
	return true


func update_ui_from_scenario() -> void:
	"""Update UI elements from scenario data"""
	name_edit.text = current_scenario.get("name", "New Scenario")
	description_edit.text = current_scenario.get("description", "")
	difficulty_spinbox.value = current_scenario.get("difficulty", 1)
	
	var time_limit: Variant = current_scenario.get("time_limit")
	if time_limit:
		time_limit_spinbox.value = time_limit
		time_limit_spinbox.editable = true
	else:
		time_limit_spinbox.value = 0
	
	# Interceptors
	var interceptors: Dictionary = current_scenario.get("interceptors", {})
	interceptors_spinbox_gbi.value = interceptors.get("GBI", 44)
	interceptors_spinbox_thaad.value = interceptors.get("THAAD", 100)
	interceptors_spinbox_patriot.value = interceptors.get("Patriot", 200)
	
	# Victory conditions
	var victory: Dictionary = current_scenario.get("victory_conditions", {})
	victory_cities_spinbox.value = victory.get("cities_saved_min", 20)
	
	# Waves
	rebuild_waves_list()


func update_scenario_from_ui() -> Dictionary:
	"""Build scenario dictionary from UI"""
	var scenario: Dictionary = {
		"id": current_scenario.get("id", "scenario_custom_%d" % Time.get_ticks_msec()),
		"name": name_edit.text,
		"description": description_edit.text,
		"difficulty": int(difficulty_spinbox.value),
		"time_limit": time_limit_spinbox.value if time_limit_spinbox.value > 0 else null,
		"launch_sites": _get_selected_launch_sites(),
		"missile_waves": waves,
		"interceptors": {
			"GBI": int(interceptors_spinbox_gbi.value),
			"THAAD": int(interceptors_spinbox_thaad.value),
			"Patriot": int(interceptors_spinbox_patriot.value)
		},
		"victory_conditions": {
			"cities_saved_min": int(victory_cities_spinbox.value),
			"time_limit_seconds": time_limit_spinbox.value if time_limit_spinbox.value > 0 else null
		}
	}
	
	return scenario


func _get_selected_launch_sites() -> Array[Dictionary]:
	"""Get selected launch sites with missile counts"""
	var selected: Array[Dictionary] = []
	
	for i: int in range(launch_sites_list.item_count):
		if launch_sites_list.is_selected(i):
			selected.append({
				"name": launch_sites[i].name,
				"missiles": 1  # Default, would set per site
			})
	
	return selected


func _on_add_launch_site() -> void:
	"""Add a launch site to the scenario"""
	# Show site selection dialog
	# For now, select from available sites
	for i: int in range(launch_sites_list.item_count):
		if launch_sites_list.is_selected(i):
			return  # Already selected
	
	# Select first unselected site
	for i: int in range(launch_sites_list.item_count):
		if not launch_sites_list.is_selected(i):
			launch_sites_list.select(i, true)
			break


func _on_remove_launch_site() -> void:
	"""Remove selected launch site"""
	for i: int in range(launch_sites_list.item_count):
		if launch_sites_list.is_selected(i):
			launch_sites_list.select(i, false)


func _on_add_wave() -> void:
	"""Add a new missile wave"""
	var wave: Dictionary = {
		"time": waves.size() * 60,  # 60 second intervals
		"missiles": []
	}
	
	waves.append(wave)
	rebuild_waves_list()


func rebuild_waves_list() -> void:
	"""Rebuild the waves UI"""
	# Clear existing
	for child: Node in waves_container.get_children():
		if child.is_in_group("wave_item"):
			child.queue_free()
	
	# Add wave items
	for i: int in range(waves.size()):
		var wave: Dictionary = waves[i]
		var wave_label: Label = Label.new()
		wave_label.text = "Wave %d: %d missiles at T+%ds" % [i + 1, wave.missiles.size(), wave.time]
		wave_label.add_to_group("wave_item")
		waves_container.add_child(wave_label)


func add_missile_to_wave(wave_index: int, origin: String, target: String, missile_type: String = "ICBM") -> void:
	"""Add a missile to a wave"""
	if wave_index < 0 or wave_index >= waves.size():
		return
	
	waves[wave_index].missiles.append({
		"origin": origin,
		"target": target,
		"type": missile_type
	})
	
	rebuild_waves_list()


func _on_save() -> void:
	"""Save the scenario"""
	AudioManager.play_click()
	
	current_scenario = update_scenario_from_ui()
	
	# Validate before saving
	var validation: Dictionary = ScenarioManager.validate_scenario(current_scenario)
	update_validation_status(validation)
	
	if not validation.valid:
		print("Validation failed:")
		print(validation.report)
		# Show validation dialog
		# For now, just show in validation_label
		return
	
	# Save via ScenarioManager
	if ScenarioManager.save_scenario(current_scenario):
		scenario_saved.emit(current_scenario)
		validation_label.text = "✓ Scenario saved successfully"
		validation_label.modulate = Color(0.3, 1.0, 0.3)
	else:
		validation_label.text = "✗ Failed to save scenario"
		validation_label.modulate = Color(1.0, 0.3, 0.3)


func update_validation_status(validation: Dictionary) -> void:
	"""Update validation label with status"""
	if validation.errors.is_empty() and validation.warnings.is_empty():
		validation_label.text = "✓ Validation passed"
		validation_label.modulate = Color(0.3, 1.0, 0.3)
	elif validation.errors.is_empty():
		validation_label.text = "⚠ %d warnings" % validation.warnings.size()
		validation_label.modulate = Color(1.0, 1.0, 0.3)
	else:
		validation_label.text = "✗ %d errors, %d warnings" % [validation.errors.size(), validation.warnings.size()]
		validation_label.modulate = Color(1.0, 0.3, 0.3)


func _on_test() -> void:
	"""Test the scenario"""
	AudioManager.play_click()
	
	current_scenario = update_scenario_from_ui()
	
	# Validate
	var validation: Dictionary = ScenarioManager.validate_scenario(current_scenario)
	if not validation.valid:
		print("Validation failed:")
		print(validation.report)
		return
	
	# Save temp scenario
	var temp_path: String = "user://scenarios/_temp_test.json"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_scenario, "  "))
		file.close()
	
	scenario_tested.emit(current_scenario)


func _on_back() -> void:
	"""Go back to menu"""
	AudioManager.play_click()
	back_pressed.emit()


func get_scenario() -> Dictionary:
	"""Get current scenario"""
	return update_scenario_from_ui()