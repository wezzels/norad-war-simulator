## missile.gd
## Missile entity script
## Handles individual missile behavior and trajectory

extends Node3D

class_name Missile

# Signals
signal position_updated(missile: Missile)
signal phase_changed(missile: Missile, new_phase: String)
signal impact(missile: Missile)

# Properties
@export var missile_id: String = ""
@export var origin: String = ""
@export var target: String = ""
@export var missile_type: String = "ICBM"
@export var warhead_yield: int = 500  # kilotons
@export var flight_time: float = 600.0  # seconds

# State
var progress: float = 0.0  # 0-100%
var altitude: float = 0.0  # km
var speed: float = 0.0  # km/s
var status: String = "launching"  # launching, boost, midcourse, terminal, destroyed
var intercepted: bool = false

# Trajectory data
var origin_coords: Dictionary = {}
var target_coords: Dictionary = {}
var distance_km: float = 0.0
var peak_altitude: float = 1200.0  # km
var max_speed: float = 7.0  # km/s

# Visual
var contrail: Line3D

# Constants
const EARTH_RADIUS: float = 6371.0  # km


func _ready() -> void:
	setup_contrail()


func setup_contrail() -> void:
	"""Create contrail visualization"""
	contrail = Line3D.new()
	contrail.width = 2.0
	contrail.default_color = Color(1.0, 0.5, 0.0, 0.7)  # Orange
	add_child(contrail)


func initialize(missile_data: Dictionary) -> void:
	"""Initialize missile from data dictionary"""
	missile_id = missile_data.get("id", "THREAT-0000")
	origin = missile_data.get("origin", "")
	target = missile_data.get("target", "")
	missile_type = missile_data.get("type", "ICBM")
	warhead_yield = missile_data.get("yield", randi_range(100, 800))
	
	# Get coordinates
	origin_coords = get_launch_site_coords(origin)
	target_coords = get_city_coords(target)
	
	# Calculate trajectory
	calculate_trajectory()
	
	status = "boost"


func get_launch_site_coords(site_name: String) -> Dictionary:
	"""Get coordinates for a launch site"""
	var sites: Array = load_json("res://data/launch_sites.json")
	for site: Dictionary in sites:
		if site.name == site_name:
			return {"lat": site.lat, "lon": site.lon}
	return {"lat": 0.0, "lon": 0.0}


func get_city_coords(city_name: String) -> Dictionary:
	"""Get coordinates for a city"""
	var cities: Array = load_json("res://data/cities.json")
	for city: Dictionary in cities:
		if city.name == city_name:
			return {"lat": city.lat, "lon": city.lon}
	return {"lat": 0.0, "lon": 0.0}


func calculate_trajectory() -> void:
	"""Calculate trajectory parameters"""
	# Distance using Haversine formula
	var lat1: float = deg_to_rad(origin_coords.lat)
	var lon1: float = deg_to_rad(origin_coords.lon)
	var lat2: float = deg_to_rad(target_coords.lat)
	var lon2: float = deg_to_rad(target_coords.lon)
	
	var dlat: float = lat2 - lat1
	var dlon: float = lon2 - lon1
	
	var a: float = sin(dlat/2) * sin(dlat/2) + cos(lat1) * cos(lat2) * sin(dlon/2) * sin(dlon/2)
	distance_km = EARTH_RADIUS * 2 * atan2(sqrt(a), sqrt(1-a))
	
	# Flight time (simplified: 7-15 minutes for ICBM)
	flight_time = max(420.0, distance_km / 7.0)
	
	# Peak altitude
	peak_altitude = minf(1200.0, distance_km * 0.15)
	
	# Maximum speed
	max_speed = randf_range(6.0, 8.0)


func _process(delta: float) -> void:
	if intercepted or status == "destroyed":
		return
	
	# Update progress
	var dt: float = delta * GameState.speed_multiplier
	progress += (dt / flight_time) * 100.0
	
	# Determine phase and update
	update_phase()
	update_position()
	update_contrail()
	
	# Check for impact
	if progress >= 100.0:
		impact.emit(self)


func update_phase() -> void:
	"""Update missile phase based on progress"""
	var new_phase: String
	
	if progress < 5.0:
		new_phase = "launching"
	elif progress < 15.0:
		new_phase = "boost"
	elif progress < 75.0:
		new_phase = "midcourse"
	elif progress < 100.0:
		new_phase = "terminal"
	else:
		new_phase = "impact"
	
	if new_phase != status:
		status = new_phase
		phase_changed.emit(self, new_phase)


func update_position() -> void:
	"""Update altitude and speed based on phase"""
	match status:
		"launching":
			altitude = progress * 8.0  # Rising fast
			speed = max_speed * (progress / 15.0)
		"boost":
			altitude = progress * 10.0
			speed = max_speed
		"midcourse":
			# Sinusoidal altitude curve
			altitude = peak_altitude * sin(PI * progress / 100.0)
			speed = max_speed
		"terminal":
			# Descending
			altitude = peak_altitude * sin(PI * (100.0 - progress) / 25.0)
			speed = max_speed * 1.2  # Re-entry acceleration
	
	# Update 3D position on globe
	var pos: Vector3 = calculate_3d_position()
	global_position = pos


func calculate_3d_position() -> Vector3:
	"""Calculate 3D position on globe from progress"""
	var lat: float = lerp(origin_coords.lat, target_coords.lat, progress / 100.0)
	var lon: float = lerp(origin_coords.lon, target_coords.lon, progress / 100.0)
	
	# Convert lat/lon to 3D coordinates (globe radius = 100 units)
	var radius: float = 100.0 + (altitude / 20.0)  # Scale altitude for visibility
	var lat_rad: float = deg_to_rad(lat)
	var lon_rad: float = deg_to_rad(lon)
	
	var x: float = radius * cos(lat_rad) * cos(lon_rad)
	var y: float = radius * sin(lat_rad)
	var z: float = radius * cos(lat_rad) * sin(lon_rad)
	
	return Vector3(x, y, z)


func update_contrail() -> void:
	"""Update contrail visualization"""
	# Add point at current position
	if contrail.get_point_count() < 100:
		contrail.add_point(global_position)
	else:
		# Shift points
		for i: int in range(contrail.get_point_count() - 1):
			contrail.set_point_position(i, contrail.get_point_position(i + 1))
		contrail.set_point_position(contrail.get_point_count() - 1, global_position)


func destroy() -> void:
	"""Mark missile as destroyed"""
	status = "destroyed"
	intercepted = true
	queue_free()


func get_data() -> Dictionary:
	"""Get missile data for JSON export"""
	return {
		"id": missile_id,
		"origin": origin,
		"target": target,
		"type": missile_type,
		"status": status,
		"altitude": altitude,
		"speed": speed,
		"progress": progress,
		"flight_time": flight_time,
		"yield": warhead_yield,
		"intercepted": intercepted
	}


func load_json(path: String) -> Array:
	"""Load JSON data from file"""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return []
	
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		return []
	
	return json.data