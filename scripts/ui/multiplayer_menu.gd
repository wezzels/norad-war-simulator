## multiplayer_menu.gd
## Multiplayer menu for hosting and joining games
## Shows server browser and connection options

extends Control

# Nodes
@onready var host_button: Button = $PanelContainer/VBoxContainer/HostButton
@onready var join_button: Button = $PanelContainer/VBoxContainer/JoinButton
@onready var back_button: Button = $PanelContainer/VBoxContainer/BackButton
@onready var player_name_edit: LineEdit = $PanelContainer/VBoxContainer/PlayerNameEdit
@onready var server_ip_edit: LineEdit = $PanelContainer/VBoxContainer/ServerIP/LineEdit
@onready var server_port_spin: SpinBox = $PanelContainer/VBoxContainer/ServerPort/SpinBox
@onready var status_label: Label = $PanelContainer/VBoxContainer/Status

# State
var is_connecting: bool = false


func _ready() -> void:
	# Setup button animations
	ButtonAnimations.setup_button(host_button)
	ButtonAnimations.setup_button(join_button)
	ButtonAnimations.setup_button(back_button)
	
	# Connect buttons
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect network signals
	NetworkManager.connection_established.connect(_on_connection_established)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.game_started.connect(_on_game_started)
	
	# Set default values
	server_port_spin.value = 7777
	server_ip_edit.text = "127.0.0.1"
	
	# Load saved player name
	var saved_name: String = Settings.get_value("player_name", "Player")
	player_name_edit.text = saved_name
	
	# Focus name field
	player_name_edit.grab_focus()


func _on_host_pressed() -> void:
	"""Host a new game"""
	AudioManager.play_click()
	
	var player_name: String = player_name_edit.text.strip_edges()
	if player_name.is_empty():
		status_label.text = "Please enter a player name"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	# Save player name
	Settings.set_value("player_name", player_name)
	
	var port: int = int(server_port_spin.value)
	
	status_label.text = "Starting server..."
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Host game
	if NetworkManager.host_game(player_name, port):
		# Save settings
		Settings.save_settings()
		
		# Go to lobby
		_goto_lobby()
	else:
		status_label.text = "Failed to start server"
		status_label.add_theme_color_override("font_color", Color.RED)


func _on_join_pressed() -> void:
	"""Join an existing game"""
	AudioManager.play_click()
	
	var player_name: String = player_name_edit.text.strip_edges()
	if player_name.is_empty():
		status_label.text = "Please enter a player name"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	var server_ip: String = server_ip_edit.text.strip_edges()
	if server_ip.is_empty():
		status_label.text = "Please enter server IP"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	# Save player name
	Settings.set_value("player_name", player_name)
	
	var port: int = int(server_port_spin.value)
	
	status_label.text = "Connecting to %s:%d..." % [server_ip, port]
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	
	is_connecting = true
	
	# Join game
	if NetworkManager.join_game(server_ip, port, player_name):
		# Save settings
		Settings.save_settings()
	else:
		status_label.text = "Failed to connect"
		status_label.add_theme_color_override("font_color", Color.RED)
		is_connecting = false


func _on_back_pressed() -> void:
	"""Go back to main menu"""
	AudioManager.play_click()
	
	var main: Node = get_parent()
	if main and main.has_method("load_menu"):
		main.load_menu()


func _on_connection_established() -> void:
	"""Handle successful connection"""
	is_connecting = false
	status_label.text = "Connected!"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	
	# Go to lobby
	_goto_lobby()


func _on_connection_failed(reason: String) -> void:
	"""Handle connection failure"""
	is_connecting = false
	status_label.text = "Connection failed: %s" % reason
	status_label.add_theme_color_override("font_color", Color.RED)


func _on_game_started() -> void:
	"""Handle game start from lobby"""
	var main: Node = get_parent()
	if main and main.has_method("load_game"):
		main.load_game("multiplayer")


func _goto_lobby() -> void:
	"""Switch to lobby scene"""
	var main: Node = get_parent()
	if main and main.has_method("load_lobby"):
		main.load_lobby()
	else:
		# Direct load
		var lobby: Node = preload("res://scenes/lobby_menu.tscn").instantiate()
		get_parent().add_child(lobby)
		queue_free()