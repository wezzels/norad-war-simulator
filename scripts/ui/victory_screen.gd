## victory_screen.gd
## Shows when campaign is completed
## Displays final statistics and congratulations

extends Control

# Signals
signal return_to_menu()

# Nodes
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var stats_container: VBoxContainer = $Panel/VBoxContainer/StatsContainer
@onready var congratulations_label: Label = $Panel/VBoxContainer/CongratulationsLabel
@onready var menu_button: Button = $Panel/MenuButton


func _ready() -> void:
	menu_button.pressed.connect(_on_menu)


func setup(stats: Dictionary) -> void:
	"""Setup victory screen with final stats"""
	title_label.text = "CAMPAIGN COMPLETE"
	title_label.modulate = Color(1.0, 0.8, 0.0)  # Gold
	
	congratulations_label.text = "Congratulations, Commander!\nYou have defended humanity against nuclear annihilation."
	
	# Clear existing stats
	for child: Node in stats_container.get_children():
		child.queue_free()
	
	# Add final stats
	var stat_items: Array[Dictionary] = [
		{"name": "Missions Completed", "value": stats.get("missions_completed", 0)},
		{"name": "Total Missiles Intercepted", "value": stats.get("total_intercepted", 0)},
		{"name": "Cities Protected", "value": stats.get("cities_protected", 0)},
		{"name": "Tech Points Earned", "value": stats.get("tech_points", 0)},
		{"name": "Technologies Unlocked", "value": stats.get("techs_unlocked", 0)},
		{"name": "Play Time", "value": format_time(stats.get("playtime_seconds", 0))}
	]
	
	for item: Dictionary in stat_items:
		var label: Label = Label.new()
		label.text = "%s: %s" % [item.name, str(item.value)]
		stats_container.add_child(label)
	
	# Playtime in hours
	var playtime_hours: float = stats.get("playtime_seconds", 0) / 3600.0
	if playtime_hours >= 1.0:
		var time_label: Label = Label.new()
		time_label.text = "Total Play Time: %.1f hours" % playtime_hours
		time_label.modulate = Color(1.0, 1.0, 0.3)
		stats_container.add_child(time_label)


func format_time(seconds: float) -> String:
	"""Format seconds as HH:MM:SS"""
	var hours: int = int(seconds) / 3600
	var minutes: int = (int(seconds) % 3600) / 60
	var secs: int = int(seconds) % 60
	
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%d:%02d" % [minutes, secs]


func _on_menu() -> void:
	"""Return to main menu"""
	AudioManager.play_click()
	return_to_menu.emit()
	
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()