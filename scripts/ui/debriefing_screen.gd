## debriefing_screen.gd
## Shows mission results after completion
## Displays statistics, unlocks, and rewards

extends Control

# Signals
signal continue_pressed()
signal retry_pressed()

# Nodes
@onready var result_label: Label = $Panel/VBoxContainer/ResultLabel
@onready var stats_container: VBoxContainer = $Panel/VBoxContainer/StatsContainer
@onready var unlocks_container: VBoxContainer = $Panel/VBoxContainer/UnlocksContainer
@onready var tech_points_label: Label = $Panel/VBoxContainer/TechPointsLabel
@onready var continue_button: Button = $Panel/ContinueButton
@onready var retry_button: Button = $Panel/RetryButton

# Mission data
var mission_success: bool = false
var mission_data: Dictionary = {}


func _ready() -> void:
	continue_button.pressed.connect(_on_continue)
	retry_button.pressed.connect(_on_retry)


func setup(success: bool, stats: Dictionary, mission: Dictionary) -> void:
	"""Setup the debriefing screen with results"""
	mission_success = success
	mission_data = mission
	
	# Set result
	if success:
		result_label.text = "MISSION COMPLETE"
		result_label.modulate = Color(0.3, 1.0, 0.3)
		continue_button.text = "Continue"
	else:
		result_label.text = "MISSION FAILED"
		result_label.modulate = Color(1.0, 0.3, 0.3)
		continue_button.text = "Return to Menu"
	
	# Show statistics
	show_stats(stats)
	
	# Show unlocks if successful
	if success:
		show_unlocks(mission.get("unlocks", []))
		show_tech_points(mission.get("tech_points", 1))
	else:
		hide_unlocks()


func show_stats(stats: Dictionary) -> void:
	"""Show mission statistics"""
	# Clear existing
	for child: Node in stats_container.get_children():
		child.queue_free()
	
	# Add stats
	var stat_items: Array[Dictionary] = [
		{"name": "Missiles Intercepted", "value": stats.get("missiles_intercepted", 0)},
		{"name": "Cities Saved", "value": stats.get("cities_saved", 0)},
		{"name": "Cities Hit", "value": stats.get("cities_hit", 0)},
		{"name": "Detonations", "value": stats.get("detonations", 0)},
		{"name": "Time", "value": format_time(stats.get("time_seconds", 0))},
		{"name": "Lowest DEFCON", "value": stats.get("min_defcon", 5)}
	]
	
	for item: Dictionary in stat_items:
		var label: Label = Label.new()
		label.text = "%s: %s" % [item.name, str(item.value)]
		
		# Color based on stat
		if item.name == "Cities Hit" and item.value > 0:
			label.modulate = Color(1.0, 0.5, 0.3)
		elif item.name == "Cities Saved" and item.value > 0:
			label.modulate = Color(0.3, 1.0, 0.3)
		
		stats_container.add_child(label)


func show_unlocks(unlocks: Array) -> void:
	"""Show tech unlocks"""
	# Clear existing
	for child: Node in unlocks_container.get_children():
		if child.name != "UnlocksLabel":
			child.queue_free()
	
	if unlocks.is_empty():
		var no_unlocks: Label = Label.new()
		no_unlocks.text = "No new tech unlocked"
		no_unlocks.modulate = Color(0.7, 0.7, 0.7)
		unlocks_container.add_child(no_unlocks)
		return
	
	for tech_id: String in unlocks:
		var tech: Dictionary = CampaignManager.TECH_TREE.get(tech_id, {})
		var label: Label = Label.new()
		label.text = "🔓 " + tech.get("name", tech_id)
		label.modulate = Color(0.3, 1.0, 0.3)
		unlocks_container.add_child(label)


func show_tech_points(points: int) -> void:
	"""Show tech points earned"""
	tech_points_label.text = "Tech Points Earned: +%d" % points
	tech_points_label.modulate = Color(1.0, 1.0, 0.3)


func hide_unlocks() -> void:
	"""Hide unlocks section"""
	for child: Node in unlocks_container.get_children():
		child.queue_free()
	
	var fail_label: Label = Label.new()
	fail_label.text = "Retry to earn tech points"
	fail_label.modulate = Color(0.7, 0.7, 0.7)
	unlocks_container.add_child(fail_label)
	
	tech_points_label.text = "Tech Points: +0"


func format_time(seconds: float) -> String:
	"""Format seconds as MM:SS"""
	var minutes: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [minutes, secs]


func _on_continue() -> void:
	"""Continue button pressed"""
	AudioManager.play_click()
	continue_pressed.emit()


func _on_retry() -> void:
	"""Retry button pressed"""
	AudioManager.play_click()
	retry_pressed.emit()