extends Control

# Nodes
@onready var scenario_list: VBoxContainer = $Panel/ScrollContainer/ScenarioList
@onready var back_button: Button = $Panel/BackButton
@onready var start_button: Button = $Panel/StartButton
@onready var description_label: Label = $Panel/DescriptionPanel/DescriptionLabel
@onready var difficulty_label: Label = $Panel/DescriptionPanel/DifficultyLabel
@onready var new_button: Button = $Panel/NewButton

# Available scenarios
var selected_scenario: String = ""


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	start_button.pressed.connect(_on_start)
	new_button.pressed.connect(_on_new)
	start_button.disabled = true
	
	# Connect to ScenarioManager
	ScenarioManager.scenarios_updated.connect(_on_scenarios_updated)
	
	load_scenarios()


func _on_scenarios_updated() -> void:
	"""Reload scenarios when updated"""
	load_scenarios()


func load_scenarios() -> void:
	"""Load available scenarios from ScenarioManager"""
	# Clear existing buttons
	for child: Node in scenario_list.get_children():
		child.queue_free()
	
	# Add header for built-in scenarios
	var builtin_label: Label = Label.new()
	builtin_label.text = "--- Built-in Scenarios ---"
	builtin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scenario_list.add_child(builtin_label)
	
	# Get scenarios from manager
	var all_scenarios: Array[Dictionary] = ScenarioManager.get_all_scenarios()
	
	# Separate built-in and custom
	for scenario: Dictionary in all_scenarios:
		var button: Button = Button.new()
		button.text = scenario.get("name", "Unknown")
		button.toggle_mode = true
		
		# Style based on difficulty
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.3)
		style.border_color = get_difficulty_color(scenario.get("difficulty", 1))
		style.set_border_width_all(2)
		button.add_theme_stylebox_override("normal", style)
		
		button.pressed.connect(_on_scenario_button_pressed.bind(scenario.id))
		scenario_list.add_child(button)
	
	# Add custom scenarios section if any exist
	var custom: Array[Dictionary] = ScenarioManager.get_custom_scenarios()
	if not custom.is_empty():
		var custom_label: Label = Label.new()
		custom_label.text = "--- Custom Scenarios ---"
		custom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scenario_list.add_child(custom_label)
		
		for scenario: Dictionary in custom:
			var button: Button = Button.new()
			button.text = scenario.get("name", "Custom") + " [Custom]"
			button.toggle_mode = true
			
			var style: StyleBoxFlat = StyleBoxFlat.new()
			style.bg_color = Color(0.15, 0.25, 0.15)
			style.border_color = get_difficulty_color(scenario.get("difficulty", 1))
			style.set_border_width_all(2)
			button.add_theme_stylebox_override("normal", style)
			
			button.pressed.connect(_on_scenario_button_pressed.bind(scenario.id))
			scenario_list.add_child(button)


func get_difficulty_color(difficulty: int) -> Color:
	"""Get color for difficulty level"""
	match difficulty:
		1: return Color(0.3, 0.8, 0.3)  # Green - Easy
		2: return Color(0.8, 0.8, 0.3)  # Yellow - Medium
		3: return Color(0.8, 0.5, 0.3)  # Orange - Hard
		4: return Color(0.8, 0.3, 0.3)  # Red - Expert
		_: return Color(0.5, 0.5, 0.5)


func _on_scenario_button_pressed(scenario_id: String) -> void:
	"""Handle scenario button press"""
	AudioManager.play_click()
	
	# Update selection
	selected_scenario = scenario_id
	start_button.disabled = false
	
	# Find scenario info from manager
	var scenario: Dictionary = ScenarioManager.get_scenario_by_id(scenario_id)
	if not scenario.is_empty():
		description_label.text = scenario.get("description", "No description")
		difficulty_label.text = "Difficulty: " + get_difficulty_text(scenario.get("difficulty", 1))
	
	# Update button states
	for child: Node in scenario_list.get_children():
		var button: Button = child as Button
		if button:
			button.button_pressed = (button.text == get_scenario_name(scenario_id))


func get_scenario_name(scenario_id: String) -> String:
	"""Get scenario name from ID"""
	var scenario: Dictionary = ScenarioManager.get_scenario_by_id(scenario_id)
	return scenario.get("name", scenario_id)


func get_difficulty_text(difficulty: int) -> String:
	"""Get difficulty text"""
	match difficulty:
		1: return "Easy"
		2: return "Medium"
		3: return "Hard"
		4: return "Expert"
		_: return "Unknown"


func _on_back() -> void:
	"""Back button pressed"""
	AudioManager.play_click()
	back_pressed.emit()


func _on_start() -> void:
	"""Start button pressed"""
	AudioManager.play_click()
	
	if selected_scenario.is_empty():
		return
	
	scenario_selected.emit(selected_scenario)


func _on_new() -> void:
	"""New scenario button pressed"""
	AudioManager.play_click()
	
	# Open editor with new scenario
	var main: Node = get_parent()
	if main and main.has_method("load_scenario_editor"):
		main.load_scenario_editor()


func select_scenario(scenario_id: String) -> void:
	"""Programmatically select a scenario"""
	selected_scenario = scenario_id
	_on_scenario_button_pressed(scenario_id)