## pause_menu.gd
## Pause menu controller
## Handles save/load/quit operations

extends Control

# Nodes
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var save_button: Button = $Panel/VBoxContainer/SaveButton
@onready var load_button: Button = $Panel/VBoxContainer/LoadButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

@onready var save_panel: PanelContainer = $SavePanel
@onready var load_panel: PanelContainer = $LoadPanel
@onready var save_slots_container: VBoxContainer = $SavePanel/VBoxContainer/ScrollContainer/SaveSlots
@onready var load_slots_container: VBoxContainer = $LoadPanel/VBoxContainer/ScrollContainer/LoadSlots

# State
var selected_slot: int = -1


func _ready() -> void:
	# Connect buttons
	resume_button.pressed.connect(_on_resume)
	save_button.pressed.connect(_on_save)
	load_button.pressed.connect(_on_load)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	
	$SavePanel/VBoxContainer/BackButton.pressed.connect(_on_save_back)
	$LoadPanel/VBoxContainer/BackButton.pressed.connect(_on_load_back)
	
	# Hide sub-panels
	save_panel.visible = false
	load_panel.visible = false
	
	# Pause game
	GameState.pause()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_resume()


func _on_resume() -> void:
	"""Resume game"""
	AudioManager.play_click()
	GameState.resume()
	queue_free()


func _on_save() -> void:
	"""Show save panel"""
	AudioManager.play_click()
	_populate_save_slots()
	save_panel.visible = true
	load_panel.visible = false


func _on_load() -> void:
	"""Show load panel"""
	AudioManager.play_click()
	_populate_load_slots()
	load_panel.visible = true
	save_panel.visible = false


func _on_settings() -> void:
	"""Open settings (TODO)"""
	AudioManager.play_click()
	push_warning("Settings not implemented in pause menu")


func _on_quit() -> void:
	"""Quit to main menu"""
	AudioManager.play_click()
	GameState.resume()
	
	# Return to main menu
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _populate_save_slots() -> void:
	"""Populate save slots"""
	# Clear existing slots
	for child: Node in save_slots_container.get_children():
		child.queue_free()
	
	# Get save slots
	var slots: Array[Dictionary] = SaveManager.get_save_slots()
	
	for i: int in range(slots.size()):
		var slot_info: Dictionary = slots[i]
		var button: Button = Button.new()
		
		if slot_info.empty:
			button.text = "Slot %d - Empty" % i
		else:
			button.text = "Slot %d - %s (%s)" % [i, slot_info.scenario, slot_info.timestamp]
		
		button.pressed.connect(_on_save_slot_pressed.bind(i))
		save_slots_container.add_child(button)


func _populate_load_slots() -> void:
	"""Populate load slots"""
	# Clear existing slots
	for child: Node in load_slots_container.get_children():
		child.queue_free()
	
	# Get save slots
	var slots: Array[Dictionary] = SaveManager.get_save_slots()
	
	for i: int in range(slots.size()):
		var slot_info: Dictionary = slots[i]
		
		if slot_info.empty:
			continue
		
		var button: Button = Button.new()
		button.text = "Slot %d - %s (%s)" % [i, slot_info.scenario, slot_info.timestamp]
		button.pressed.connect(_on_load_slot_pressed.bind(i))
		load_slots_container.add_child(button)


func _on_save_slot_pressed(slot: int) -> void:
	"""Save to selected slot"""
	AudioManager.play_click()
	
	var success: bool = SaveManager.save_game(slot)
	
	if success:
		# Show confirmation
		var label: Label = Label.new()
		label.text = "Saved to slot %d" % slot
		label.modulate = Color(0, 1, 0)
		save_slots_container.add_child(label)
		
		# Refresh after delay
		await get_tree().create_timer(1.0).timeout
		_populate_save_slots()
	else:
		# Show error
		var label: Label = Label.new()
		label.text = "Save failed!"
		label.modulate = Color(1, 0, 0)
		save_slots_container.add_child(label)


func _on_load_slot_pressed(slot: int) -> void:
	"""Load from selected slot"""
	AudioManager.play_click()
	
	var success: bool = SaveManager.load_game(slot)
	
	if success:
		_on_resume()
	else:
		# Show error
		var label: Label = Label.new()
		label.text = "Load failed!"
		label.modulate = Color(1, 0, 0)
		load_slots_container.add_child(label)


func _on_save_back() -> void:
	"""Back from save panel"""
	AudioManager.play_click()
	save_panel.visible = false


func _on_load_back() -> void:
	"""Back from load panel"""
	AudioManager.play_click()
	load_panel.visible = false