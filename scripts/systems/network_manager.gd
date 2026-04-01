## network_manager.gd
## Multiplayer networking using ENet
## Handles host/client connections, state sync, and lobby

extends Node

class_name NetworkManager

# Signals
signal connection_established()
signal connection_failed(reason: String)
signal player_joined(player_id: int, player_name: String)
signal player_left(player_id: int)
signal lobby_updated(players: Array[Dictionary])
signal game_started()
signal state_received(state: Dictionary)
signal chat_message(player_id: int, player_name: String, message: String)

# Constants
const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 8
const TICK_RATE: float = 20.0  # Updates per second
const STATE_SYNC_RATE: float = 10.0  # State syncs per second

# Network state
var is_host: bool = false
var is_connected: bool = false
var local_player_id: int = 0
var local_player_name: String = ""
var server_ip: String = ""
var server_port: int = DEFAULT_PORT

# Players
var players: Dictionary = {}  # player_id -> {name, team, ready}
var host_player_id: int = 0

# Game mode
enum GameMode { COOP, VERSUS }
var game_mode: GameMode = GameMode.COOP

# Network nodes
var peer: ENetMultiplayerPeer = null

# State sync
var state_accumulator: float = 0.0
var last_state: Dictionary = {}

# Chat
var chat_history: Array[Dictionary] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if not is_connected:
		return
	
	# State sync for host
	if is_host:
		state_accumulator += delta
		if state_accumulator >= (1.0 / STATE_SYNC_RATE):
			state_accumulator = 0.0
			sync_game_state()


# === HOST FUNCTIONS ===

func host_game(player_name: String, port: int = DEFAULT_PORT) -> bool:
	"""Create a game server"""
	if is_connected:
		push_error("Already connected to a game")
		return false
	
	peer = ENetMultiplayerPeer.new()
	var error: int = peer.create_server(port, MAX_PLAYERS)
	
	if error != OK:
		connection_failed.emit("Failed to create server: %s" % error_string(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	is_host = true
	is_connected = true
	local_player_id = multiplayer.get_unique_id()
	local_player_name = player_name
	host_player_id = local_player_id
	server_port = port
	
	# Add host as first player
	players[local_player_id] = {
		"name": player_name,
		"team": 1,
		"ready": true,
		"is_host": true
	}
	
	# Connect signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	connection_established.emit()
	lobby_updated.emit(_get_player_list())
	
	print("Server started on port %d" % port)
	return true


func start_game() -> bool:
	"""Start the game (host only)"""
	if not is_host:
		push_error("Only host can start game")
		return false
	
	# Check if all players are ready
	for player_id: int in players:
		if not players[player_id].ready:
			push_error("Not all players are ready")
			return false
	
	# Send game start signal to all clients
	rpc("receive_game_start")
	game_started.emit()
	return true


# === CLIENT FUNCTIONS ===

func join_game(ip: String, port: int, player_name: String) -> bool:
	"""Join a game server"""
	if is_connected:
		push_error("Already connected to a game")
		return false
	
	peer = ENetMultiplayerPeer.new()
	var error: int = peer.create_client(ip, port)
	
	if error != OK:
		connection_failed.emit("Failed to connect to server: %s" % error_string(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	is_host = false
	local_player_name = player_name
	server_ip = ip
	server_port = port
	
	# Connect signals
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	return true


func set_ready(ready: bool) -> void:
	"""Set player ready state"""
	if is_host:
		players[local_player_id].ready = ready
		lobby_updated.emit(_get_player_list())
	else:
		rpc_id(1, "receive_player_ready", local_player_id, ready)


func send_chat(message: String) -> void:
	"""Send chat message"""
	if is_host:
		_receive_chat(local_player_id, local_player_name, message)
	else:
		rpc_id(1, "receive_chat", local_player_id, local_player_name, message)


# === STATE SYNC ===

func sync_game_state() -> void:
	"""Sync game state to all clients (host only)"""
	if not is_host:
		return
	
	var state: Dictionary = GameState.get_state()
	rpc("receive_game_state", state)


@rpc("any_peer", "call_remote", "reliable")
func receive_game_state(state: Dictionary) -> void:
	"""Receive game state from host"""
	state_received.emit(state)
	_apply_state(state)


func _apply_state(state: Dictionary) -> void:
	"""Apply received state to local game"""
	# Update missiles
	if state.has("missiles"):
		for missile: Dictionary in state.missiles:
			var existing: Dictionary = GameState.get_missile_by_id(missile.id)
			if existing.is_empty():
				GameState.missiles.append(missile)
			else:
				# Update existing
				for key: String in missile:
					existing[key] = missile[key]
	
	# Update interceptors
	if state.has("interceptors"):
		GameState.interceptors = state.interceptors
	
	# Update other state
	if state.has("defcon"):
		GameState.current_defcon = state.defcon
	if state.has("simulation_time"):
		GameState.simulation_time = state.simulation_time
	if state.has("stats"):
		GameState.stats = state.stats


# === RPC FUNCTIONS ===

@rpc("any_peer", "call_remote", "reliable")
func receive_player_join(player_id: int, player_name: String, team: int) -> void:
	"""Receive new player notification"""
	players[player_id] = {
		"name": player_name,
		"team": team,
		"ready": false,
		"is_host": false
	}
	player_joined.emit(player_id, player_name)
	lobby_updated.emit(_get_player_list())


@rpc("any_peer", "call_remote", "reliable")
func receive_player_leave(player_id: int) -> void:
	"""Receive player leave notification"""
	players.erase(player_id)
	player_left.emit(player_id)
	lobby_updated.emit(_get_player_list())


@rpc("any_peer", "call_remote", "reliable")
func receive_game_start() -> void:
	"""Receive game start notification"""
	game_started.emit()


@rpc("any_peer", "call_remote", "reliable")
func receive_player_ready(player_id: int, ready: bool) -> void:
	"""Receive player ready state (host -> clients)"""
	if players.has(player_id):
		players[player_id].ready = ready
		lobby_updated.emit(_get_player_list())


@rpc("any_peer", "call_remote", "reliable")
func _receive_chat(player_id: int, player_name: String, message: String) -> void:
	"""Receive chat message"""
	chat_message.emit(player_id, player_name, message)
	chat_history.append({
		"player_id": player_id,
		"player_name": player_name,
		"message": message,
		"timestamp": Time.get_time_string_from_system()
	})


@rpc("any_peer", "call_remote", "reliable")
func receive_lobby_state(player_list: Array) -> void:
	"""Receive full lobby state (new clients)"""
	players.clear()
	for player: Dictionary in player_list:
		players[player.id] = player
	lobby_updated.emit(_get_player_list())


# === SIGNAL HANDLERS ===

func _on_peer_connected(player_id: int) -> void:
	"""Handle new player connection (host)"""
	print("Player connected: %d" % player_id)
	
	# Request player info from client
	rpc_id(player_id, "request_player_info")


@rpc("authority", "call_remote", "reliable")
func request_player_info() -> void:
	"""Server requests player info"""
	rpc_id(1, "provide_player_info", local_player_name)


@rpc("any_peer", "call_remote", "reliable")
func provide_player_info(player_name: String) -> void:
	"""Client provides player info to host"""
	var sender_id: int = multiplayer.get_remote_sender_id()
	
	# Assign team
	var team: int = _assign_team()
	
	# Add player
	players[sender_id] = {
		"name": player_name,
		"team": team,
		"ready": false,
		"is_host": false
	}
	
	# Notify all clients of new player
	rpc("receive_player_join", sender_id, player_name, team)
	
	# Send lobby state to new player
	rpc_id(sender_id, "receive_lobby_state", _get_player_list())
	
	player_joined.emit(sender_id, player_name)


func _on_peer_disconnected(player_id: int) -> void:
	"""Handle player disconnection (host)"""
	print("Player disconnected: %d" % player_id)
	players.erase(player_id)
	rpc("receive_player_leave", player_id)
	player_left.emit(player_id)


func _on_connected_to_server() -> void:
	"""Handle successful connection to server (client)"""
	is_connected = true
	local_player_id = multiplayer.get_unique_id()
	connection_established.emit()
	print("Connected to server")


func _on_connection_failed() -> void:
	"""Handle connection failure (client)"""
	is_connected = false
	connection_failed.emit("Failed to connect to server")


func _on_server_disconnected() -> void:
	"""Handle server disconnect (client)"""
	is_connected = false
	players.clear()
	print("Disconnected from server")


# === HELPER FUNCTIONS ===

func _assign_team() -> int:
	"""Assign team for new player"""
	if game_mode == GameMode.COOP:
		return 1  # Everyone on same team
	
	# Versus mode - balance teams
	var team1_count: int = 0
	var team2_count: int = 0
	
	for player_id: int in players:
		if players[player_id].team == 1:
			team1_count += 1
		else:
			team2_count += 1
	
	return 1 if team1_count <= team2_count else 2


func _get_player_list() -> Array[Dictionary]:
	"""Get player list as array"""
	var list: Array[Dictionary] = []
	for player_id: int in players:
		list.append({
			"id": player_id,
			"name": players[player_id].name,
			"team": players[player_id].team,
			"ready": players[player_id].ready,
			"is_host": players[player_id].is_host
		})
	return list


func disconnect_game() -> void:
	"""Disconnect from current game"""
	if peer:
		peer.close()
	
	peer = null
	is_host = false
	is_connected = false
	players.clear()
	chat_history.clear()


func get_ping() -> int:
	"""Get ping to server in milliseconds"""
	if peer and is_connected and not is_host:
		return peer.get_stat(ENetMultiplayerPeer.PEER_ROUND_TRIP_TIME)
	return 0


func is_player_host(player_id: int) -> bool:
	"""Check if player is host"""
	return players.has(player_id) and players[player_id].is_host