## lobby_menu.gd
## Multiplayer lobby screen
## Shows connected players, team selection, ready status

extends Control

# Nodes
@onready var player_list: VBoxContainer = $PanelContainer/VBoxContainer/Players/PlayerList
@onready var game_mode_option: OptionButton = $PanelContainer/VBoxContainer/Settings/GameMode/OptionButton
@onready var team_option: OptionButton = $PanelContainer/VBoxContainer/Settings/Team/OptionButton
@onready var ready_check: CheckBox = $PanelContainer/VBoxContainer/Settings/ReadyCheck
@onready var chat_display: RichTextLabel = $PanelContainer/VBoxContainer/Chat/Messages
@onready var chat_input: LineEdit = $PanelContainer/VBoxContainer/Chat/Input
@onready var start_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/StartButton
@onready var ready_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/ReadyButton
@onready var back_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/BackButton
@onready var status_label: Label = $PanelContainer/VBoxContainer/Status

# State
var is_ready: bool = false


func _ready() -> void:
	# Setup button animations
	ButtonAnimations.setup_button(start_button)
	ButtonAnimations.setup_button(ready_button)
	ButtonAnimations.setup_button(back_button)
	
	# Connect signals
	ready_button.pressed.connect(_on_ready_pressed)
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)
	chat_input.text_submitted.connect(_on_chat_submitted)
	
	# Connect network signals
	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	NetworkManager.player_joined.connect(_on_player_joined)
	NetworkManager.player_left.connect(_on_player_left)
	NetworkManager.chat_message.connect(_on_chat_message)
	NetworkManager.game_started.connect(_on_game_started)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	
	# Setup game mode options
	game_mode_option.add_item("Co-op")
	game_mode_option.add_item("Versus")
	game_mode_option.selected = 0
	
	# Setup team options
	team_option.add_item("Team Alpha")
	team_option.add_item("Team Bravo")
	team_option.selected = 0
	
	# Hide start button for non-hosts
	start_button.visible = NetworkManager.is_host
	
	# Update UI
	_update_lobby()
	
	# Focus chat
	chat_input.grab_focus()


func _update_lobby() -> void:
	"""Update lobby display"""
	# Clear player list
	for child: Node in player_list.get_children():
		child.queue_free()
	
	# Add players
	var players: Array[Dictionary] = NetworkManager.players.values()
	for player: Dictionary in players:
		var player_row: HBoxContainer = _create_player_row(player)
		player_list.add_child(player_row)
	
	# Update status
	var count: int = players.size()
	status_label.text = "%d player%s connected" % [count, "" if count == 1 else "s"]
	
	# Update start button state
	if NetworkManager.is_host:
		var all_ready: bool = true
		for player: Dictionary in players:
			if not player.ready:
				all_ready = false
				break
		start_button.disabled = count < 1 or not all_ready


func _create_player_row(player: Dictionary) -> HBoxContainer:
	"""Create a player row widget"""
	var row: HBoxContainer = HBoxContainer.new()
	
	# Player name
	var name_label: Label = Label.new()
	name_label.text = player.name
	if player.is_host:
		name_label.text += " [Host]"
	name_label.custom_minimum_size.x = 150
	row.add_child(name_label)
	
	# Team
	var team_label: Label = Label.new()
	team_label.text = "Team %s" % ("Alpha" if player.team == 1 else "Bravo")
	team_label.custom_minimum_size.x = 80
	row.add_child(team_label)
	
	# Ready status
	var ready_label: Label = Label.new()
	ready_label.text = "✓" if player.ready else "○"
	ready_label.add_theme_color_override("font_color", Color.GREEN if player.ready else Color.GRAY)
	ready_label.custom_minimum_size.x = 40
	row.add_child(ready_label)
	
	# Highlight local player
	if player.id == NetworkManager.local_player_id:
		name_label.add_theme_color_override("font_color", Color.CYAN)
	
	return row


func _on_lobby_updated(players: Array[Dictionary]) -> void:
	"""Handle lobby update"""
	_update_lobby()


func _on_player_joined(player_id: int, player_name: String) -> void:
	"""Handle new player"""
	_add_chat_message("", "System", "%s joined the game" % player_name, Color.YELLOW)


func _on_player_left(player_id: int) -> void:
	"""Handle player leaving"""
	var name: String = "Player"
	if NetworkManager.players.has(player_id):
		name = NetworkManager.players[player_id].name
	_add_chat_message("", "System", "%s left the game" % name, Color.YELLOW)


func _on_chat_message(player_id: int, player_name: String, message: String) -> void:
	"""Handle chat message"""
	var color: Color = Color.WHITE
	if player_id == NetworkManager.local_player_id:
		color = Color.CYAN
	_add_chat_message(player_name, "", message, color)


func _on_game_started() -> void:
	"""Handle game start"""
	# Transition to game scene
	var main: Node = get_parent()
	if main and main.has_method("load_game"):
		main.load_game("multiplayer")


func _on_connection_failed(reason: String) -> void:
	"""Handle connection failure"""
	status_label.text = "Connection failed: %s" % reason
	status_label.add_theme_color_override("font_color", Color.RED)


func _on_ready_pressed() -> void:
	"""Toggle ready state"""
	AudioManager.play_click()
	is_ready = not is_ready
	NetworkManager.set_ready(is_ready)
	ready_check.button_pressed = is_ready
	ready_button.text = "Not Ready" if is_ready else "Ready"


func _on_start_pressed() -> void:
	"""Start game (host only)"""
	AudioManager.play_click()
	if NetworkManager.is_host:
		NetworkManager.start_game()


func _on_back_pressed() -> void:
	"""Leave lobby"""
	AudioManager.play_click()
	NetworkManager.disconnect_game()
	
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()


func _on_chat_submitted(text: String) -> void:
	"""Send chat message"""
	if text.strip_edges().is_empty():
		return
	
	NetworkManager.send_chat(text)
	chat_input.clear()


func _add_chat_message(player: String, prefix: String, message: String, color: Color = Color.WHITE) -> void:
	"""Add message to chat display"""
	var text: String = ""
	if not prefix.is_empty():
		text = "[%s] " % prefix
	elif not player.is_empty():
		text = "%s: " % player
	
	chat_display.push_color(color)
	chat_display.append_text(text + message + "\n")
	chat_display.pop()


func _on_game_mode_selected(index: int) -> void:
	"""Change game mode (host only)"""
	if not NetworkManager.is_host:
		return
	
	AudioManager.play_click()
	NetworkManager.game_mode = 0 if index == 0 else 1  # 0 = COOP, 1 = VERSUS
	# Sync game mode to clients
	# rpc("set_game_mode", index)


func _on_team_selected(index: int) -> void:
	"""Change team (versus mode)"""
	AudioManager.play_click()
	# Update local team
	if NetworkManager.players.has(NetworkManager.local_player_id):
		NetworkManager.players[NetworkManager.local_player_id].team = index + 1