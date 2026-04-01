## state_sync.gd
## Handles state synchronization for multiplayer
## Interpolates and predicts positions for smooth gameplay

extends Node

# Sync settings
const SYNC_RATE: float = 20.0  # Updates per second
const INTERPOLATION_DELAY: float = 0.05  # 50ms interpolation buffer
const MAX_PREDICTION_TIME: float = 0.5  # Max time to predict without update

# State buffers for interpolation
var missile_states: Dictionary = {}  # missile_id -> state buffer
var interceptor_states: Dictionary = {}  # interceptor_id -> state buffer

# Prediction
var last_update_time: float = 0.0
var prediction_enabled: bool = true

# Sync accumulator
var sync_accumulator: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _process(delta: float) -> void:
	if not NetworkManager.is_connected:
		return
	
	# Host sends state updates
	if NetworkManager.is_host:
		sync_accumulator += delta
		if sync_accumulator >= (1.0 / SYNC_RATE):
			sync_accumulator = 0.0
			_broadcast_state()
	
	# Clients interpolate
	if not NetworkManager.is_host:
		_interpolate_states(delta)


# === HOST FUNCTIONS ===

func _broadcast_state() -> void:
	"""Broadcast game state to all clients"""
	if not NetworkManager.is_host:
		return
	
	var state: Dictionary = _collect_state()
	NetworkManager.rpc("receive_game_state", state)


func _collect_state() -> Dictionary:
	"""Collect current game state for sync"""
	return {
		"time": GameState.simulation_time,
		"defcon": GameState.current_defcon,
		"speed": GameState.speed_multiplier,
		"missiles": _collect_missile_states(),
		"interceptors": _collect_interceptor_states(),
		"stats": GameState.stats.duplicate(),
		"game_mode": GameMode.current_mode,
		"team_scores": GameMode.team_scores.duplicate()
	}


func _collect_missile_states() -> Array:
	"""Collect all missile states"""
	var states: Array = []
	
	for missile: Dictionary in GameState.missiles:
		states.append({
			"id": missile.id,
			"position": missile.position,
			"progress": missile.progress,
			"status": missile.status,
			"altitude": missile.altitude,
			"speed": missile.speed,
			"intercepted": missile.intercepted
		})
	
	return states


func _collect_interceptor_states() -> Array:
	"""Collect all interceptor states"""
	var states: Array = []
	
	for interceptor: Dictionary in GameState.interceptors:
		states.append({
			"id": interceptor.id,
			"missile_id": interceptor.missile_id,
			"progress": interceptor.progress,
			"status": interceptor.status
		})
	
	return states


# === CLIENT FUNCTIONS ===

func _interpolate_states(delta: float) -> void:
	"""Interpolate received states for smooth movement"""
	_interpolate_missiles(delta)
	_interpolate_interceptors(delta)


func _interpolate_missiles(delta: float) -> void:
	"""Interpolate missile positions"""
	for missile: Dictionary in GameState.missiles:
		var id: String = missile.id
		if not missile_states.has(id):
			continue
		
		var buffer: Array = missile_states[id]
		if buffer.size() < 2:
			continue
		
		# Find two states to interpolate between
		var render_time: float = Time.get_ticks_msec() / 1000.0 - INTERPOLATION_DELAY
		
		for i: int in range(buffer.size() - 1):
			var state_a: Dictionary = buffer[i]
			var state_b: Dictionary = buffer[i + 1]
			
			if render_time >= state_a.time and render_time <= state_b.time:
				# Interpolate
				var t: float = (render_time - state_a.time) / (state_b.time - state_a.time)
				missile.position.lat = lerp(state_a.position.lat, state_b.position.lat, t)
				missile.position.lon = lerp(state_a.position.lon, state_b.position.lon, t)
				missile.position.alt = lerp(state_a.position.alt, state_b.position.alt, t)
				missile.progress = lerp(state_a.progress, state_b.progress, t)
				break


func _interpolate_interceptors(delta: float) -> void:
	"""Interpolate interceptor positions"""
	for interceptor: Dictionary in GameState.interceptors:
		var id: String = interceptor.id
		if not interceptor_states.has(id):
			continue
		
		var buffer: Array = interceptor_states[id]
		if buffer.size() < 2:
			continue
		
		var render_time: float = Time.get_ticks_msec() / 1000.0 - INTERPOLATION_DELAY
		
		for i: int in range(buffer.size() - 1):
			var state_a: Dictionary = buffer[i]
			var state_b: Dictionary = buffer[i + 1]
			
			if render_time >= state_a.time and render_time <= state_b.time:
				var t: float = (render_time - state_a.time) / (state_b.time - state_a.time)
				interceptor.progress = lerp(state_a.progress, state_b.progress, t)
				break


# === STATE APPLICATION ===

func apply_state(state: Dictionary) -> void:
	"""Apply received state to local game"""
	# Update time
	GameState.simulation_time = state.get("time", GameState.simulation_time)
	GameState.current_defcon = state.get("defcon", GameState.current_defcon)
	GameState.speed_multiplier = state.get("speed", GameState.speed_multiplier)
	
	# Update stats
	if state.has("stats"):
		GameState.stats = state.stats.duplicate()
	
	# Update game mode state
	if state.has("game_mode"):
		GameMode.current_mode = state.game_mode
	if state.has("team_scores"):
		GameMode.team_scores = state.team_scores.duplicate()
	
	# Update missiles
	if state.has("missiles"):
		_apply_missile_states(state.missiles)
	
	# Update interceptors
	if state.has("interceptors"):
		_apply_interceptor_states(state.interceptors)


func _apply_missile_states(states: Array) -> void:
	"""Apply received missile states"""
	for state: Dictionary in states:
		var id: String = state.id
		
		# Find or create missile
		var missile: Dictionary = _find_or_create_missile(id)
		
		# Store in buffer for interpolation
		if not missile_states.has(id):
			missile_states[id] = []
		
		var state_entry: Dictionary = state.duplicate()
		state_entry.time = Time.get_ticks_msec() / 1000.0
		missile_states[id].append(state_entry)
		
		# Keep only last 10 states
		if missile_states[id].size() > 10:
			missile_states[id].pop_front()
		
		# Update immediate values
		missile.status = state.status
		missile.intercepted = state.intercepted


func _apply_interceptor_states(states: Array) -> void:
	"""Apply received interceptor states"""
	for state: Dictionary in states:
		var id: String = state.id
		
		var interceptor: Dictionary = _find_or_create_interceptor(id)
		
		if not interceptor_states.has(id):
			interceptor_states[id] = []
		
		var state_entry: Dictionary = state.duplicate()
		state_entry.time = Time.get_ticks_msec() / 1000.0
		interceptor_states[id].append(state_entry)
		
		if interceptor_states[id].size() > 10:
			interceptor_states[id].pop_front()
		
		interceptor.status = state.status


func _find_or_create_missile(id: String) -> Dictionary:
	"""Find or create a missile by ID"""
	for missile: Dictionary in GameState.missiles:
		if missile.id == id:
			return missile
	
	# Create new
	var new_missile: Dictionary = {
		"id": id,
		"position": {"lat": 0.0, "lon": 0.0, "alt": 0.0},
		"progress": 0.0,
		"status": "boost",
		"altitude": 0.0,
		"speed": 0.0,
		"intercepted": false
	}
	GameState.missiles.append(new_missile)
	return new_missile


func _find_or_create_interceptor(id: String) -> Dictionary:
	"""Find or create an interceptor by ID"""
	for interceptor: Dictionary in GameState.interceptors:
		if interceptor.id == id:
			return interceptor
	
	var new_interceptor: Dictionary = {
		"id": id,
		"missile_id": "",
		"progress": 0.0,
		"status": "tracking",
		"success": false
	}
	GameState.interceptors.append(new_interceptor)
	return new_interceptor


# === RPC SYNC ===

@rpc("authority", "call_remote", "unreliable")
func sync_missile_launch(missile_data: Dictionary) -> void:
	"""Receive missile launch from host"""
	if NetworkManager.is_host:
		return
	
	# Create missile locally
	GameState.missiles.append(missile_data)


@rpc("authority", "call_remote", "reliable")
func sync_interceptor_launch(interceptor_data: Dictionary) -> void:
	"""Receive interceptor launch from host"""
	if NetworkManager.is_host:
		return
	
	GameState.interceptors.append(interceptor_data)


@rpc("authority", "call_remote", "reliable")
func sync_detonation(detonation_data: Dictionary) -> void:
	"""Receive detonation from host"""
	if NetworkManager.is_host:
		return
	
	GameState.detonations.append(detonation_data)
	GameState.detonation_detected.emit(detonation_data)


@rpc("authority", "call_remote", "reliable")
func sync_defcon_change(level: int) -> void:
	"""Receive DEFCON change from host"""
	if NetworkManager.is_host:
		return
	
	GameState.current_defcon = level
	GameState.defcon_changed.emit(level)


# === CLEANUP ===

func clear_buffers() -> void:
	"""Clear all state buffers"""
	missile_states.clear()
	interceptor_states.clear()


func remove_missile(id: String) -> void:
	"""Remove missile from buffers"""
	missile_states.erase(id)


func remove_interceptor(id: String) -> void:
	"""Remove interceptor from buffers"""
	interceptor_states.erase(id)