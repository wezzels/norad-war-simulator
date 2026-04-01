## wave_editor.gd
## Dialog for editing individual missile waves
## Allows setting time, origin, targets, and missile types

extends Control

# Signals
signal wave_saved(wave: Dictionary)
signal cancelled()

# Nodes
@onready var time_spinbox: SpinBox = $Panel/VBoxContainer/TimeContainer/TimeSpinbox
@onready var origin_option: OptionButton = $Panel/VBoxContainer/OriginContainer/OriginOption
@onready var targets_list: ItemList = $Panel/VBoxContainer/TargetsContainer/TargetsList
@onready var type_option: OptionButton = $Panel/VBoxContainer/TypeContainer/TypeOption
@onready var count_spinbox: SpinBox = $Panel/VBoxContainer/CountContainer/CountSpinbox
@onready var random_checkbox: CheckBox = $Panel/VBoxContainer/RandomContainer/RandomCheckbox
@onready var save_button: Button = $Panel/SaveButton
@onready var cancel_button: Button = $Panel/CancelButton

# Data
var launch_sites: Array[Dictionary] = []
var cities: Array[Dictionary] = []
var current_wave: Dictionary = {}
var wave_index: int = -1


func _ready() -> void:
	# Connect buttons
	save_button.pressed.connect(_on_save)
	cancel_button.pressed.connect(_on_cancel)
	
	# Load data
	load_launch_sites()
	load_cities()
	
	# Populate type options
	type_option.add_item("ICBM")
	type_option.add_item("IRBM")
	type_option.add_item("SRBM")


func load_launch_sites() -> void:
	"""Load launch site options"""
	var file: FileAccess = FileAccess.open("res://data/launch_sites.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			launch_sites = json.data
			
			origin_option.clear()
			for site: Dictionary in launch_sites:
				origin_option.add_item(site.name)


func load_cities() -> void:
	"""Load city options for targets"""
	var file: FileAccess = FileAccess.open("res://data/cities.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			cities = json.data
			
			targets_list.clear()
			for city: Dictionary in cities:
				targets_list.add_item(city.name)


func setup_new_wave() -> void:
	"""Setup for creating a new wave"""
	current_wave = {
		"time": 0,
		"missiles": []
	}
	wave_index = -1
	
	time_spinbox.value = 0
	origin_option.select(0)
	count_spinbox.value = 1
	random_checkbox.button_pressed = false
	
	# Clear target selection
	for i: int in range(targets_list.item_count):
		targets_list.select(i, false)


func setup_edit_wave(wave_data: Dictionary, index: int) -> void:
	"""Setup for editing existing wave"""
	current_wave = wave_data.duplicate(true)
	wave_index = index
	
	time_spinbox.value = wave_data.get("time", 0)
	
	# Select origin if missiles exist
	if wave_data.missiles.size() > 0:
		var origin: String = wave_data.missiles[0].origin
		for i: int in range(origin_option.item_count):
			if origin_option.get_item_text(i) == origin:
				origin_option.select(i)
				break
	
	# Clear and select targets
	for i: int in range(targets_list.item_count):
		targets_list.select(i, false)
	
	# Check random
	random_checkbox.button_pressed = wave_data.has("missiles_count")


func _on_save() -> void:
	"""Save the wave"""
	AudioManager.play_click()
	
	var wave: Dictionary = {
		"time": int(time_spinbox.value)
	}
	
	if random_checkbox.button_pressed:
		# Random missiles
		wave["missiles_count"] = int(count_spinbox.value)
		wave["targets"] = "random"
	else:
		# Specific missiles
		wave["missiles"] = []
		var origin: String = origin_option.get_item_text(origin_option.selected)
		var missile_type: String = type_option.get_item_text(type_option.selected)
		
		# Get selected targets
		var selected_targets: Array[String] = []
		for i: int in range(targets_list.item_count):
			if targets_list.is_selected(i):
				selected_targets.append(cities[i].name)
		
		# Add missiles for each target
		for target: String in selected_targets:
			wave["missiles"].append({
				"origin": origin,
				"target": target,
				"type": missile_type
			})
	
	current_wave = wave
	wave_saved.emit(wave)
	hide()


func _on_cancel() -> void:
	"""Cancel editing"""
	AudioManager.play_click()
	cancelled.emit()
	hide()


func get_wave() -> Dictionary:
	"""Get the current wave"""
	return current_wave


func get_wave_index() -> int:
	"""Get the wave index (for editing)"""
	return wave_index