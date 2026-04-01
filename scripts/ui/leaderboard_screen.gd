## leaderboard_screen.gd
## Displays Steam leaderboards
## Shows top scores and player rankings

extends Control

# Nodes
@onready var leaderboard_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/LeaderboardList
@onready var leaderboard_tabs: HBoxContainer = $PanelContainer/VBoxContainer/Tabs
@onready var player_rank_label: Label = $PanelContainer/VBoxContainer/PlayerRank
@onready var back_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/BackButton
@onready var status_label: Label = $PanelContainer/VBoxContainer/Status

# Leaderboards
var current_leaderboard: String = "interceptions"
var leaderboards: Dictionary = {
	"interceptions": {"name": "Most Interceptions", "entries": []},
	"survival": {"name": "Best Survival Rate", "entries": []},
	"speedrun": {"name": "Fastest Campaign", "entries": []},
	"multiplayer": {"name": "Multiplayer Wins", "entries": []}
}


func _ready() -> void:
	ButtonAnimations.setup_button(back_button)
	
	back_button.pressed.connect(_on_back)
	
	# Create tab buttons
	_create_tabs()
	
	# Load initial leaderboard
	_load_leaderboard(current_leaderboard)


func _create_tabs() -> void:
	"""Create leaderboard tab buttons"""
	# Clear existing
	for child: Node in leaderboard_tabs.get_children():
		child.queue_free()
	
	# Create tabs
	for lb_id: String in leaderboards:
		var btn: Button = Button.new()
		btn.text = leaderboards[lb_id].name
		btn.toggle_mode = true
		btn.pressed.connect(_on_tab_pressed.bind(lb_id))
		
		if lb_id == current_leaderboard:
			btn.button_pressed = true
		
		leaderboard_tabs.add_child(btn)


func _on_tab_pressed(leaderboard_id: String) -> void:
	"""Handle tab selection"""
	AudioManager.play_click()
	current_leaderboard = leaderboard_id
	_load_leaderboard(leaderboard_id)
	
	# Update tab states
	for i: int in range(leaderboard_tabs.get_child_count()):
		var btn: Button = leaderboard_tabs.get_child(i)
		btn.button_pressed = (i == leaderboards.keys().find(leaderboard_id))


func _load_leaderboard(leaderboard_id: String) -> void:
	"""Load leaderboard data"""
	status_label.text = "Loading..."
	
	# Request from Steam (simulated for now)
	_populate_mock_leaderboard(leaderboard_id)
	_populate_list()
	
	# Get player rank
	_update_player_rank()


func _populate_mock_leaderboard(leaderboard_id: String) -> void:
	"""Populate mock leaderboard data"""
	var entries: Array[Dictionary] = []
	
	# Generate mock entries
	var names: Array[String] = [
		"Strategist42", "NuclearNinja", "IronDome", "MissileMaster",
		"DEFCON1", "SiloCommander", "ShieldBearer", "TargetPractice",
		"WarGames", "RedButton", "LaunchCode", "FalloutSurvivor"
	]
	
	var scores: Dictionary = {
		"interceptions": [15234, 12456, 11023, 9876, 8654, 7432, 6543, 5432, 4321, 3210],
		"survival": [98, 95, 92, 89, 85, 82, 78, 75, 71, 68],
		"speedrun": [1245, 1423, 1567, 1789, 1923, 2134, 2345, 2567, 2789, 3012],
		"multiplayer": [156, 134, 121, 98, 87, 76, 65, 54, 43, 32]
	}
	
	var units: Dictionary = {
		"interceptions": "interceptions",
		"survival": "% survival",
		"speedrun": "seconds",
		"multiplayer": "wins"
	}
	
	var lb_scores: Array = scores.get(leaderboard_id, [])
	
	for i: int in range(min(10, names.size())):
		entries.append({
			"rank": i + 1,
			"name": names[i],
			"score": lb_scores[i] if i < lb_scores.size() else 0,
			"unit": units.get(leaderboard_id, ""),
			"is_player": i == 3  # Mock player at rank 4
		})
	
	leaderboards[leaderboard_id].entries = entries


func _populate_list() -> void:
	"""Populate leaderboard list"""
	# Clear existing
	for child: Node in leaderboard_list.get_children():
		child.queue_free()
	
	# Header
	var header: HBoxContainer = _create_header()
	leaderboard_list.add_child(header)
	
	# Entries
	for entry: Dictionary in leaderboards[current_leaderboard].entries:
		var row: HBoxContainer = _create_entry_row(entry)
		leaderboard_list.add_child(row)


func _create_header() -> HBoxContainer:
	"""Create leaderboard header"""
	var header: HBoxContainer = HBoxContainer.new()
	
	var rank_label: Label = Label.new()
	rank_label.text = "Rank"
	rank_label.custom_minimum_size = Vector2(60, 0)
	rank_label.add_theme_font_size_override("font_size", 14)
	rank_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.4))
	header.add_child(rank_label)
	
	var name_label: Label = Label.new()
	name_label.text = "Player"
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.4))
	header.add_child(name_label)
	
	var score_label: Label = Label.new()
	score_label.text = "Score"
	score_label.custom_minimum_size = Vector2(150, 0)
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.4))
	header.add_child(score_label)
	
	return header


func _create_entry_row(entry: Dictionary) -> HBoxContainer:
	"""Create leaderboard entry row"""
	var row: HBoxContainer = HBoxContainer.new()
	
	# Highlight player's row
	if entry.is_player:
		var bg: StyleBoxFlat = StyleBoxFlat.new()
		bg.bg_color = Color(0.1, 0.2, 0.15, 0.5)
		row.add_theme_stylebox_override("panel", bg)
	
	# Rank
	var rank: Label = Label.new()
	rank.text = "#%d" % entry.rank
	rank.custom_minimum_size = Vector2(60, 0)
	
	match entry.rank:
		1: rank.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))  # Gold
		2: rank.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))  # Silver
		3: rank.add_theme_color_override("font_color", Color(0.85, 0.55, 0.3))  # Bronze
	
	row.add_child(rank)
	
	# Name
	var name: Label = Label.new()
	name.text = entry.name
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if entry.is_player:
		name.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
		name.text = entry.name + " (You)"
	
	row.add_child(name)
	
	# Score
	var score: Label = Label.new()
	score.text = "%s %s" % [_format_score(entry.score), entry.unit]
	score.custom_minimum_size = Vector2(150, 0)
	row.add_child(score)
	
	return row


func _format_score(score: int) -> String:
	"""Format score for display"""
	if score >= 1000000:
		return "%.1fM" % (score / 1000000.0)
	elif score >= 1000:
		return "%.1fK" % (score / 1000.0)
	return str(score)


func _update_player_rank() -> void:
	"""Update player rank display"""
	# Find player in leaderboard
	var player_rank: int = 0
	var player_score: int = 0
	
	for entry: Dictionary in leaderboards[current_leaderboard].entries:
		if entry.is_player:
			player_rank = entry.rank
			player_score = entry.score
			break
	
	if player_rank > 0:
		player_rank_label.text = "Your Rank: #%d (%s %s)" % [player_rank, _format_score(player_score), _get_score_unit()]
	else:
		player_rank_label.text = "Your Rank: Not ranked"
	
	status_label.text = leaderboards[current_leaderboard].name


func _get_score_unit() -> String:
	"""Get score unit for current leaderboard"""
	var units: Dictionary = {
		"interceptions": "interceptions",
		"survival": "% survival",
		"speedrun": "seconds",
		"multiplayer": "wins"
	}
	return units.get(current_leaderboard, "")


func _on_back() -> void:
	"""Go back"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()
	else:
		queue_free()


func upload_score(leaderboard_id: String, score: int) -> void:
	"""Upload score to leaderboard"""
	if not SteamManager.is_steam_running:
		return
	
	SteamManager.upload_leaderboard_score(leaderboard_id, score)


func refresh_leaderboard() -> void:
	"""Refresh current leaderboard"""
	_load_leaderboard(current_leaderboard)