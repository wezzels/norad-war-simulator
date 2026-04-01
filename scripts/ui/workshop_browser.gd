## workshop_browser.gd
## Browse and manage Steam Workshop scenarios
## Upload, download, and rate custom scenarios

extends Control

# Signals
signal scenario_selected(scenario_id: String)
signal back_pressed()

# Nodes
@onready var item_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/ItemList
@onready var upload_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/UploadButton
@onready var refresh_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/RefreshButton
@onready var back_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/BackButton
@onready var search_input: LineEdit = $PanelContainer/VBoxContainer/SearchContainer/SearchInput
@onready var status_label: Label = $PanelContainer/VBoxContainer/Status

# Workshop items (simulated for now)
var workshop_items: Array[Dictionary] = []
var subscribed_items: Array[Dictionary] = []
var is_loading: bool = false


func _ready() -> void:
	# Setup buttons
	ButtonAnimations.setup_button(upload_button)
	ButtonAnimations.setup_button(refresh_button)
	ButtonAnimations.setup_button(back_button)
	
	# Connect signals
	upload_button.pressed.connect(_on_upload)
	refresh_button.pressed.connect(_on_refresh)
	back_button.pressed.connect(_on_back)
	search_input.text_changed.connect(_on_search)
	
	# Load items
	_refresh_items()


func _refresh_items() -> void:
	"""Refresh workshop items from Steam"""
	is_loading = true
	status_label.text = "Loading workshop items..."
	
	# Simulated workshop items for development
	# In production, would query Steam Workshop API
	_populate_mock_items()
	
	# Clear and repopulate
	_populate_list()
	
	is_loading = false
	status_label.text = "Loaded %d items" % workshop_items.size()


func _populate_mock_items() -> void:
	"""Populate mock workshop items for testing"""
	workshop_items = [
		{
			"id": "workshop_001",
			"title": "Cold War Crisis",
			"author": "Strategist42",
			"description": "Relive the tension of 1962 with realistic Soviet missile placements.",
			"rating": 4.8,
			"downloads": 15234,
			"tags": ["historical", "hard"],
			"subscribed": true
		},
		{
			"id": "workshop_002",
			"title": "Pacific Rim Defense",
			"author": "AdmiralNuke",
			"description": "Defend the West Coast from a massive Pacific launch.",
			"rating": 4.5,
			"downloads": 8721,
			"tags": ["regional", "medium"],
			"subscribed": false
		},
		{
			"id": "workshop_003",
			"title": "European Shield",
			"author": "IronDome",
			"description": "Protect European capitals from coordinated strike.",
			"rating": 4.2,
			"downloads": 6543,
			"tags": ["europe", "medium"],
			"subscribed": true
		},
		{
			"id": "workshop_004",
			"title": "Global Thermonuclear War",
			"author": "WOPR",
			"description": "A strange game. The only winning move is not to play.",
			"rating": 4.9,
			"downloads": 25000,
			"tags": ["extreme", "hard"],
			"subscribed": false
		},
		{
			"id": "workshop_005",
			"title": "Operation Desert Shield",
			"author": "StorminNorman",
			"description": "Defend the Persian Gulf region during the 1991 conflict.",
			"rating": 4.3,
			"downloads": 4321,
			"tags": ["historical", "medium"],
			"subscribed": false
		}
	]


func _populate_list(filter: String = "") -> void:
	"""Populate the item list"""
	# Clear existing
	for child: Node in item_list.get_children():
		child.queue_free()
	
	# Filter items
	var filtered: Array[Dictionary] = []
	if filter.is_empty():
		filtered = workshop_items
	else:
		filter = filter.to_lower()
		for item: Dictionary in workshop_items:
			if item.title.to_lower().contains(filter) or \
			   item.author.to_lower().contains(filter) or \
			   item.description.to_lower().contains(filter):
				filtered.append(item)
	
	# Create item rows
	for item: Dictionary in filtered:
		var row: HBoxContainer = _create_item_row(item)
		item_list.add_child(row)


func _create_item_row(item: Dictionary) -> HBoxContainer:
	"""Create a workshop item row"""
	var row: HBoxContainer = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 80)
	
	# Thumbnail placeholder
	var thumb: ColorRect = ColorRect.new()
	thumb.custom_minimum_size = Vector2(80, 80)
	thumb.color = Color(0.2, 0.2, 0.25)
	row.add_child(thumb)
	
	# Info container
	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	
	# Title
	var title: Label = Label.new()
	title.text = item.title
	title.add_theme_font_size_override("font_size", 16)
	if item.subscribed:
		title.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	info.add_child(title)
	
	# Author
	var author: Label = Label.new()
	author.text = "by %s" % item.author
	author.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	author.add_theme_font_size_override("font_size", 12)
	info.add_child(author)
	
	# Description
	var desc: Label = Label.new()
	desc.text = item.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 11)
	info.add_child(desc)
	
	# Stats
	var stats: HBoxContainer = HBoxContainer.new()
	info.add_child(stats)
	
	var rating: Label = Label.new()
	rating.text = "★ %.1f" % item.rating
	rating.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	stats.add_child(rating)
	
	var downloads: Label = Label.new()
	downloads.text = "  |  %s downloads" % _format_number(item.downloads)
	downloads.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	stats.add_child(downloads)
	
	# Subscribe button
	var sub_btn: Button = Button.new()
	sub_btn.text = "Subscribed" if item.subscribed else "Subscribe"
	if item.subscribed:
		sub_btn.disabled = true
	sub_btn.custom_minimum_size = Vector2(100, 0)
	sub_btn.pressed.connect(_on_subscribe.bind(item))
	row.add_child(sub_btn)
	
	# Play button
	var play_btn: Button = Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size = Vector2(60, 0)
	play_btn.disabled = not item.subscribed
	play_btn.pressed.connect(_on_play.bind(item))
	row.add_child(play_btn)
	
	return row


func _format_number(num: int) -> String:
	"""Format large numbers"""
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	return str(num)


func _on_search(text: String) -> void:
	"""Handle search input"""
	_populate_list(text)


func _on_subscribe(item: Dictionary) -> void:
	"""Subscribe to workshop item"""
	AudioManager.play_click()
	
	if item.subscribed:
		return
	
	# Subscribe via Steam
	SteamManager.subscribe_to_workshop_item(item.id.hash())
	
	# Update local state
	item.subscribed = true
	
	# Refresh list
	_populate_list(search_input.text)
	
	status_label.text = "Subscribed to: %s" % item.title


func _on_play(item: Dictionary) -> void:
	"""Play workshop scenario"""
	AudioManager.play_click()
	
	if not item.subscribed:
		status_label.text = "Subscribe to play this scenario"
		return
	
	# Load and play scenario
	_load_workshop_scenario(item.id)


func _load_workshop_scenario(scenario_id: String) -> void:
	"""Load a workshop scenario"""
	# In production, would load from Steam Workshop content
	# For now, transition to game with scenario ID
	
	status_label.text = "Loading scenario: %s" % scenario_id
	
	# Simulate loading delay
	await get_tree().create_timer(0.5).timeout
	
	# Start game with scenario
	var main: Node = get_parent()
	if main and main.has_method("load_game"):
		main.load_game(scenario_id)
	else:
		# Use global Main
		Main.load_game(scenario_id)


func _on_upload() -> void:
	"""Upload current scenario to Workshop"""
	AudioManager.play_click()
	
	# Show upload dialog
	_show_upload_dialog()


func _show_upload_dialog() -> void:
	"""Show scenario upload dialog"""
	var dialog: AcceptDialog = AcceptDialog.new()
	dialog.dialog_text = "Upload Scenario"
	dialog.title = "Workshop Upload"
	
	# Create form
	var form: VBoxContainer = VBoxContainer.new()
	
	var title_edit: LineEdit = LineEdit.new()
	title_edit.placeholder_text = "Scenario Title"
	form.add_child(title_edit)
	
	var desc_edit: TextEdit = TextEdit.new()
	desc_edit.placeholder_text = "Description"
	desc_edit.custom_minimum_size = Vector2(300, 100)
	form.add_child(desc_edit)
	
	var tags_edit: LineEdit = LineEdit.new()
	tags_edit.placeholder_text = "Tags (comma separated)"
	form.add_child(tags_edit)
	
	dialog.add_child(form)
	
	# Show dialog
	add_child(dialog)
	dialog.popup_centered()
	
	# Handle confirmation
	dialog.confirmed.connect(func():
		var title: String = title_edit.text.strip_edges()
		var desc: String = desc_edit.text
		var tags: String = tags_edit.text
		
		if title.is_empty():
			status_label.text = "Title required"
			return
		
		# Upload to Workshop
		_upload_scenario(title, desc, tags.split(","))
	)


func _upload_scenario(title: String, description: String, tags: Array) -> void:
	"""Upload scenario to Workshop"""
	status_label.text = "Uploading..."
	
	# Get current scenario path
	var scenario_path: String = "user://scenarios/current.json"
	
	# Create preview
	var preview_path: String = "user://scenarios/preview.png"
	
	# Upload via Steam
	SteamManager.create_workshop_item(title, description, scenario_path, preview_path)
	
	status_label.text = "Scenario uploaded: %s" % title
	
	# Refresh list
	await get_tree().create_timer(1.0).timeout
	_refresh_items()


func _on_refresh() -> void:
	"""Refresh workshop items"""
	AudioManager.play_click()
	_refresh_items()


func _on_back() -> void:
	"""Go back to main menu"""
	AudioManager.play_click()
	back_pressed.emit()
	
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()
	else:
		queue_free()