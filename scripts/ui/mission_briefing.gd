## mission_briefing.gd
## Displays mission briefing before gameplay
## Shows objectives, unlocks, and start button

extends Control

# Signals
signal mission_started()
signal back_pressed()

# Nodes
@onready var mission_title: Label = $Panel/VBoxContainer/TitleLabel
@onready var mission_number: Label = $Panel/VBoxContainer/MissionNumber
@onready var description_label: Label = $Panel/VBoxContainer/DescriptionLabel
@onready var briefing_text: TextEdit = $Panel/VBoxContainer/BriefingEdit
@onready var objectives_label: Label = $Panel/VBoxContainer/ObjectivesLabel
@onready var unlocks_container: VBoxContainer = $Panel/VBoxContainer/UnlocksContainer
@onready var start_button: Button = $Panel/StartButton
@onready var back_button: Button = $Panel/BackButton

# Mission data
var current_mission: Dictionary = {}


func _ready() -> void:
	start_button.pressed.connect(_on_start)
	back_button.pressed.connect(_on_back)


func setup(mission: Dictionary) -> void:
	"""Setup the briefing screen with mission data"""
	current_mission = mission
	
	mission_title.text = mission.get("name", "Unknown Mission")
	mission_number.text = "Mission %d" % (CampaignManager.current_mission + 1)
	description_label.text = mission.get("description", "")
	briefing_text.text = mission.get("briefing", "No briefing available.")
	
	# Set objectives based on scenario
	var scenario_id: String = mission.get("scenario", "")
	objectives_label.text = _get_objectives_text(scenario_id)
	
	# Show unlocks
	_show_unlocks(mission.get("unlocks", []))
	
	# Show tech points
	var tech_points: int = mission.get("tech_points", 1)
	var tech_label: Label = unlocks_container.get_node_or_null("TechPointsLabel")
	if tech_label:
		tech_label.text = "Tech Points on Success: %d" % tech_points


func _get_objectives_text(scenario_id: String) -> String:
	"""Get objectives for a scenario"""
	var scenario: Dictionary = ScenarioManager.get_scenario_by_id(scenario_id)
	
	if scenario.is_empty():
		return "• Intercept all incoming missiles\n• Protect cities from destruction"
	
	var objectives: String = "• "
	
	var victory: Dictionary = scenario.get("victory_conditions", {})
	var cities_needed: int = victory.get("cities_saved_min", 20)
	var total_cities: int = 23
	
	objectives += "Save at least %d of %d cities" % [cities_needed, total_cities]
	
	# Add time limit if present
	var time_limit: Variant = victory.get("time_limit_seconds")
	if time_limit != null and time_limit > 0:
		var minutes: int = int(time_limit) / 60
		objectives += "\n• Complete within %d minutes" % minutes
	
	return objectives


func _show_unlocks(unlocks: Array) -> void:
	"""Show tech unlocks for this mission"""
	# Clear existing
	for child: Node in unlocks_container.get_children():
		if child.name != "TechPointsLabel":
			child.queue_free()
	
	# Add unlocks
	if unlocks.is_empty():
		var no_unlocks: Label = Label.new()
		no_unlocks.text = "No tech unlocks"
		no_unlocks.modulate = Color(0.7, 0.7, 0.7)
		unlocks_container.add_child(no_unlocks)
	else:
		for tech_id: String in unlocks:
			var tech: Dictionary = CampaignManager.TECH_TREE.get(tech_id, {})
			var tech_label: Label = Label.new()
			tech_label.text = "🔓 " + tech.get("name", tech_id)
			tech_label.modulate = Color(0.3, 1.0, 0.3)
			unlocks_container.add_child(tech_label)
	
	# Add tech points label
	var tech_points: int = current_mission.get("tech_points", 1)
	var tech_points_label: Label = Label.new()
	tech_points_label.name = "TechPointsLabel"
	tech_points_label.text = "Tech Points on Success: %d" % tech_points
	tech_points_label.modulate = Color(1.0, 1.0, 0.3)
	unlocks_container.add_child(tech_points_label)


func _on_start() -> void:
	"""Start the mission"""
	AudioManager.play_click()
	
	# Load the scenario
	var scenario_id: String = current_mission.get("scenario", "")
	
	# Start game with scenario
	var main: Node = get_parent()
	if main and main.has_method("load_game"):
		main.load_game(scenario_id)
	
	mission_started.emit()


func _on_back() -> void:
	"""Go back to campaign menu"""
	AudioManager.play_click()
	back_pressed.emit()