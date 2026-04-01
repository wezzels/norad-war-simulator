## achievements_screen.gd
## Displays Steam achievements and stats
## Shows progress and unlock status

extends Control

# Nodes
@onready var achievement_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/AchievementList
@onready var stats_container: GridContainer = $PanelContainer/VBoxContainer/Stats/StatsGrid
@onready var back_button: Button = $PanelContainer/VBoxContainer/BackButton
@onready var progress_label: Label = $PanelContainer/VBoxContainer/Progress
@onready var overall_progress: ProgressBar = $PanelContainer/VBoxContainer/OverallProgress


func _ready() -> void:
	# Setup button animations
	ButtonAnimations.setup_button(back_button)
	
	# Connect
	back_button.pressed.connect(_on_back)
	
	# Populate achievements
	_populate_achievements()
	_populate_stats()
	_update_progress()


func _populate_achievements() -> void:
	"""Populate achievement list"""
	# Clear existing
	for child: Node in achievement_list.get_children():
		child.queue_free()
	
	# Add achievements
	for id: String in SteamManager.achievements:
		var achievement: Dictionary = SteamManager.achievements[id]
		
		# Skip secret achievements if not unlocked
		if achievement.get("secret", false) and not achievement.unlocked:
			var placeholder: HBoxContainer = _create_achievement_row({
				"name": "???",
				"desc": "Hidden achievement",
				"unlocked": false
			})
			achievement_list.add_child(placeholder)
			continue
		
		var row: HBoxContainer = _create_achievement_row(achievement)
		achievement_list.add_child(row)


func _create_achievement_row(achievement: Dictionary) -> HBoxContainer:
	"""Create an achievement row"""
	var row: HBoxContainer = HBoxContainer.new()
	
	# Icon (placeholder)
	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTER
	# Would load actual icon: icon.texture = load("res://assets/achievements/%s.png" % id)
	row.add_child(icon)
	
	# Info container
	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	
	# Name
	var name_label: Label = Label.new()
	name_label.text = achievement.name
	if not achievement.unlocked:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	info.add_child(name_label)
	
	# Description
	var desc_label: Label = Label.new()
	desc_label.text = achievement.desc
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info.add_child(desc_label)
	
	# Status
	var status: Label = Label.new()
	status.text = "✓" if achievement.unlocked else "○"
	status.add_theme_color_override("font_color", Color.GREEN if achievement.unlocked else Color.GRAY)
	status.custom_minimum_size = Vector2(40, 0)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(status)
	
	return row


func _populate_stats() -> void:
	"""Populate stats display"""
	# Clear existing
	for child: Node in stats_container.get_children():
		child.queue_free()
	
	# Stats to display
	var display_stats: Array[Dictionary] = [
		{"key": "missiles_intercepted", "label": "Missiles Intercepted"},
		{"key": "cities_saved", "label": "Cities Saved"},
		{"key": "cities_lost", "label": "Cities Lost"},
		{"key": "missions_completed", "label": "Missions Completed"},
		{"key": "campaigns_completed", "label": "Campaigns Completed"},
		{"key": "multiplayer_wins", "label": "Multiplayer Wins"},
		{"key": "play_time_hours", "label": "Play Time (hours)"}
	]
	
	for stat: Dictionary in display_stats:
		var key: String = stat.key
		var label: String = stat.label
		var value = SteamManager.stats.get(key, 0)
		
		# Label
		var stat_label: Label = Label.new()
		stat_label.text = label + ":"
		stats_container.add_child(stat_label)
		
		# Value
		var stat_value: Label = Label.new()
		stat_value.text = str(value)
		stat_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_container.add_child(stat_value)


func _update_progress() -> void:
	"""Update overall progress"""
	var progress: Dictionary = SteamManager.get_achievement_progress()
	
	progress_label.text = "Achievements: %d / %d (%.1f%%)" % [progress.unlocked, progress.total, progress.percent]
	overall_progress.max_value = progress.total
	overall_progress.value = progress.unlocked


func _on_back() -> void:
	"""Go back"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()
	else:
		queue_free()