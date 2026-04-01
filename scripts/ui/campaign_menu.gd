## campaign_menu.gd
## Campaign selection menu
## Shows mission progress and tech tree

extends Control

# Signals
signal mission_selected(mission_index: int)
signal back_pressed()

# Nodes
@onready var mission_list: ItemList = $Panel/HBoxContainer/MissionsPanel/VBox/MissionList
@onready var tech_list: ItemList = $Panel/HBoxContainer/TechTreePanel/VBox/TechList
@onready var tech_points_label: Label = $Panel/HBoxContainer/TechTreePanel/VBox/TechPointsLabel
@onready var progress_label: Label = $ProgressLabel
@onready var back_button: Button = $ButtonContainer/BackButton
@onready var start_button: Button = $ButtonContainer/StartButton


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	start_button.pressed.connect(_on_start)
	mission_list.item_selected.connect(_on_mission_selected)
	mission_list.item_activated.connect(_on_mission_activated)
	
	start_button.disabled = true
	
	load_campaign()


func load_campaign() -> void:
	"""Load campaign data and populate UI"""
	populate_missions()
	populate_tech_tree()
	update_progress()


func populate_missions() -> void:
	"""Populate mission list"""
	mission_list.clear()
	
	for i: int in range(CampaignManager.MISSIONS.size()):
		var mission: Dictionary = CampaignManager.MISSIONS[i]
		var can_play: bool = CampaignManager.can_play_mission(i)
		var is_current: bool = i == CampaignManager.current_mission
		var is_completed: bool = i in CampaignManager.completed_missions
		
		var text: String = mission.get("name", "Mission %d" % (i + 1))
		
		if is_completed:
			text = "✓ " + text
		elif is_current:
			text = "► " + text
		else:
			text = "   " + text
		
		mission_list.add_item(text)
		
		# Color based on status
		if is_completed:
			mission_list.set_item_custom_fg_color(i, Color(0.3, 1.0, 0.3))
		elif can_play:
			mission_list.set_item_custom_fg_color(i, Color(1.0, 1.0, 1.0))
		else:
			mission_list.set_item_custom_fg_color(i, Color(0.5, 0.5, 0.5))
			mission_list.set_item_selectable(i, false)


func populate_tech_tree() -> void:
	"""Populate tech tree"""
	tech_list.clear()
	
	var tech_points: int = CampaignManager.campaign_data.get("tech_points", 0)
	tech_points_label.text = "Tech Points: %d" % tech_points
	
	# Show available techs
	var available: Array[Dictionary] = CampaignManager.get_available_techs()
	
	# Add unlocked techs first
	for tech_id: String in CampaignManager.unlocked_techs:
		var tech: Dictionary = CampaignManager.TECH_TREE.get(tech_id, {})
		tech_list.add_item("✓ " + tech.get("name", tech_id))
		tech_list.set_item_custom_fg_color(tech_list.get_item_count() - 1, Color(0.3, 1.0, 0.3))
	
	# Add available techs
	for tech: Dictionary in available:
		var text: String = "%s (Cost: %d)" % [tech.name, tech.cost]
		tech_list.add_item(text)
		
		# Can afford?
		if tech.cost <= tech_points:
			tech_list.set_item_custom_fg_color(tech_list.get_item_count() - 1, Color(1.0, 1.0, 0.3))
		else:
			tech_list.set_item_custom_fg_color(tech_list.get_item_count() - 1, Color(0.5, 0.5, 0.5))


func update_progress() -> void:
	"""Update progress label"""
	var progress: Dictionary = CampaignManager.get_progress()
	progress_label.text = "Mission %d / %d | Completed: %d | Tech Points: %d" % [
		progress.current_mission + 1,
		progress.total_missions,
		progress.completed,
		progress.tech_points
	]


func _on_mission_selected(index: int) -> void:
	"""Mission selected in list"""
	AudioManager.play_click()
	
	var can_play: bool = CampaignManager.can_play_mission(index)
	start_button.disabled = not can_play
	
	if not can_play:
		start_button.text = "Locked"
	elif index in CampaignManager.completed_missions:
		start_button.text = "Replay"
	else:
		start_button.text = "Start Mission"


func _on_mission_activated(index: int) -> void:
	"""Mission double-clicked"""
	if CampaignManager.can_play_mission(index):
		_on_start()


func _on_start() -> void:
	"""Start selected mission"""
	AudioManager.play_click()
	
	var selected: Array = mission_list.get_selected_items()
	if selected.is_empty():
		return
	
	var index: int = selected[0]
	
	# Start mission briefing
	var main: Node = get_parent()
	if main and main.has_method("show_mission_briefing"):
		main.show_mission_briefing(index)
	else:
		# Direct start
		CampaignManager.start_mission(index)
		mission_selected.emit(index)


func _on_back() -> void:
	"""Go back to main menu"""
	AudioManager.play_click()
	back_pressed.emit()


func get_selected_mission() -> int:
	"""Get selected mission index"""
	var selected: Array = mission_list.get_selected_items()
	if selected.is_empty():
		return -1
	return selected[0]