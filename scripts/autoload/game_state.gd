## game_state.gd
## Global game state manager
## Handles simulation state, missiles, interceptors, satellites

extends Node

# Signals
signal missile_launched(missile_data: Dictionary)
signal missile_intercepted(missile_id: String)
signal detonation_detected(detonation_data: Dictionary)
signal defcon_changed(level: int)
signal alert_received(alert_data: Dictionary)
signal simulation_tick(delta: float)

# Game State
var paused: bool = false
var speed_multiplier: float = 1.0
var current_defcon: int = 3
var simulation_time: float = 0.0

# Entities
var missiles: Array[Dictionary] = []
var interceptors: Array[Dictionary] = []
var detonations: Array[Dictionary] = []
var satellites: Array[Dictionary] = []
var alerts: Array[String] = []

# Statistics
var stats: Dictionary = {
	"missiles_launched": 0,
	"missiles_intercepted": 0,
	"detonations_detected": 0,
	"cities_hit": 0,
	"threats_active": 0
}

# Scenario
var current_scenario: Dictionary = {}
var scenario_loaded: bool = false


func _ready() -> void:
	load_satellites()
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _process(delta: float) -> void:
	if paused:
		return
	
	var sim_delta: float = delta * speed_multiplier
	simulation_time += sim_delta
	
	update_missiles(sim_delta)
	update_interceptors(sim_delta)
	check_detections()
	
	simulation_tick.emit(sim_delta)


func load_satellites() -> void:
	"""Load satellite data from JSON"""
	var file: FileAccess = FileAccess.open("res://data/satellites.json", FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		var json: JSON = JSON.new()
		var error: int = json.parse(json_string)
		if error == OK:
			satellites = json.data
		else:
			push_error("Failed to parse satellites.json")


func load_scenario(scenario_name: String) -> bool:
	"""Load a scenario from JSON"""
	var file: FileAccess = FileAccess.open("res://data/scenarios/%s.json" % scenario_name, FileAccess.READ)
	if not file:
		push_error("Scenario not found: %s" % scenario_name)
		return false
	
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	var error: int = json.parse(json_string)
	
	if error != OK:
		push_error("Failed to parse scenario: %s" % scenario_name)
		return false
	
	current_scenario = json.data
	scenario_loaded = true
	
	# Reset state
	reset_state()
	
	# Set initial conditions
	if current_scenario.has("interceptors"):
		# Initialize interceptor counts
		pass
	
	return true


func reset_state() -> void:
	"""Reset game state for new scenario"""
	missiles.clear()
	interceptors.clear()
	detonations.clear()
	alerts.clear()
	simulation_time = 0.0
	current_defcon = 3
	speed_multiplier = 1.0
	
	stats = {
		"missiles_launched": 0,
		"missiles_intercepted": 0,
		"detonations_detected": 0,
		"cities_hit": 0,
		"threats_active": 0
	}


func pause() -> void:
	paused = true


func resume() -> void:
	paused = false


func set_speed(multiplier: float) -> void:
	speed_multiplier = clamp(multiplier, 0.1, 100.0)


func set_defcon(level: int) -> void:
	level = clamp(level, 1, 5)
	if level != current_defcon:
		current_defcon = level
		defcon_changed.emit(level)
		
		# Generate alert
		var alert_text: String = "DEFCON %d - " % level
		match level:
			1: alert_text += "MAXIMUM READINESS - Nuclear war imminent"
			2: alert_text += "ARMED FORCES READY - Next step nuclear war"
			3: alert_text += "AIR FORCE READY - Increase in force readiness"
			4: alert_text += "INCREASED INTELLIGENCE - Above normal readiness"
			5: alert_text += "NORMAL READINESS - Lowest state"
		
		alerts.append(alert_text)
		alert_received.emit({"level": level, "text": alert_text})


func launch_missile(origin: String, target: String, missile_type: String = "ICBM") -> Dictionary:
	"""Launch a new missile threat"""
	# Get coordinates from data files
	var origin_coords: Dictionary = _get_launch_site_coords(origin)
	var target_coords: Dictionary = _get_city_coords(target)
	
	# Calculate distance using ballistic physics
	var distance_km: float = Ballistics.great_circle_distance(
		origin_coords.lat, origin_coords.lon,
		target_coords.lat, target_coords.lon
	)
	
	# Calculate flight time
	var flight_time: float = Ballistics.calculate_flight_time(distance_km, missile_type)
	
	var missile: Dictionary = {
		"id": "THREAT-%s-%d" % [Time.get_time_string_from_system().replace(":", ""), randi_range(100, 999)],
		"origin": origin,
		"target": target,
		"type": missile_type,
		"status": "boost",
		"altitude": 0.0,
		"speed": 0.0,
		"progress": 0.0,
		"flight_time": flight_time,
		"launch_time": simulation_time,
		"warhead_yield": randi_range(100, 800),
		"distance_km": distance_km,
		"origin_lat": origin_coords.lat,
		"origin_lon": origin_coords.lon,
		"target_lat": target_coords.lat,
		"target_lon": target_coords.lon,
		"position": {"lat": origin_coords.lat, "lon": origin_coords.lon, "alt": 0.0},
		"intercepted": false
	}
	
	missiles.append(missile)
	stats.missiles_launched += 1
	stats.threats_active += 1
	
	missile_launched.emit(missile)
	
	return missile


func _get_launch_site_coords(site_name: String) -> Dictionary:
	"""Get coordinates for a launch site"""
	var file: FileAccess = FileAccess.open("res://data/launch_sites.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			for site: Dictionary in json.data:
				if site.name == site_name:
					return {"lat": site.lat, "lon": site.lon}
	return {"lat": 0.0, "lon": 0.0}


func _get_city_coords(city_name: String) -> Dictionary:
	"""Get coordinates for a city"""
	var file: FileAccess = FileAccess.open("res://data/cities.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			for city: Dictionary in json.data:
				if city.name == city_name:
					return {"lat": city.lat, "lon": city.lon}
	return {"lat": 0.0, "lon": 0.0}


func calculate_flight_time(origin: String, target: String) -> float:
	"""Calculate missile flight time in seconds - DEPRECATED, use Ballistics"""
	var origin_coords: Dictionary = _get_launch_site_coords(origin)
	var target_coords: Dictionary = _get_city_coords(target)
	var distance: float = Ballistics.great_circle_distance(
		origin_coords.lat, origin_coords.lon,
		target_coords.lat, target_coords.lon
	)
	return Ballistics.calculate_flight_time(distance, "ICBM")


func update_missiles(delta: float) -> void:
	"""Update all missile positions"""
	for i in range(missiles.size() - 1, -1, -1):
		var missile: Dictionary = missiles[i]
		
		if missile.intercepted:
			missiles.remove_at(i)
			continue
		
		# Update progress using ballistic physics
		var elapsed: float = simulation_time - missile.launch_time
		var total_time: float = missile.flight_time
		
		# Get accurate position from Ballistics
		var pos: Dictionary = Ballistics.position_at_time(
			missile.origin_lat, missile.origin_lon,
			missile.target_lat, missile.target_lon,
			elapsed, total_time, missile.type
		)
		
		missile.progress = pos.fraction * 100.0
		missile.status = pos.phase
		missile.altitude = pos.altitude_km
		missile.speed = pos.velocity_ms
		missile.position = {"lat": pos.lat, "lon": pos.lon, "alt": pos.altitude_km}
		
		# Check for impact
		if pos.fraction >= 1.0:
			# Impact!
			create_detonation(missile)
			missiles.remove_at(i)
			stats.cities_hit += 1
			stats.threats_active -= 1


func update_interceptors(delta: float) -> void:
	"""Update all interceptor positions"""
	for i in range(interceptors.size() - 1, -1, -1):
		var interceptor: Dictionary = interceptors[i]
		
		interceptor.progress += delta * 15.0  # Fast intercept
		
		if interceptor.progress >= 100.0:
			if interceptor.success:
				# Mark target missile as intercepted
				var target_missile: Dictionary = get_missile_by_id(interceptor.missile_id)
				if target_missile:
					target_missile.intercepted = true
					stats.missiles_intercepted += 1
					stats.threats_active -= 1
					missile_intercepted.emit(interceptor.missile_id)
			
			interceptors.remove_at(i)


func get_missile_by_id(missile_id: String) -> Dictionary:
	"""Find missile by ID"""
	for missile in missiles:
		if missile.id == missile_id:
			return missile
	return {}


func create_detonation(missile: Dictionary) -> void:
	"""Create a detonation event"""
	var detonation: Dictionary = {
		"id": "DET-%s" % Time.get_time_string_from_system().replace(":", ""),
		"lat": missile.position.lat,
		"lon": missile.position.lon,
		"yield": missile.warhead_yield,
		"city": missile.target,
		"time": Time.get_time_string_from_system(),
		"confirmed": false,
		"satellites_detected": []
	}
	
	detonations.append(detonation)
	stats.detonations_detected += 1
	detonation_detected.emit(detonation)


func launch_interceptor(missile_id: String, interceptor_type: String = "GBI") -> bool:
	"""Launch an interceptor at a missile"""
	var missile: Dictionary = get_missile_by_id(missile_id)
	if missile.is_empty():
		return false
	
	# Calculate success probability based on phase
	var success_chance: float = 0.0
	match missile.status:
		"boost": success_chance = 0.3
		"midcourse": success_chance = 0.7
		"terminal": success_chance = 0.5
	
	var interceptor: Dictionary = {
		"id": "INT-%s" % Time.get_time_string_from_system().replace(":", ""),
		"missile_id": missile_id,
		"type": interceptor_type,
		"status": "tracking",
		"success": randf() < success_chance,
		"progress": 0.0
	}
	
	interceptors.append(interceptor)
	return true


func check_detections() -> void:
	"""Check satellite detections for detonations"""
	# Would implement satellite detection logic here
	pass


func get_state() -> Dictionary:
	"""Get current game state for multiplayer sync"""
	return {
		"paused": paused,
		"speed": speed_multiplier,
		"defcon": current_defcon,
		"simulation_time": simulation_time,
		"missiles": missiles,
		"interceptors": interceptors,
		"detonations": detonations,
		"satellites": satellites,
		"stats": stats
	}