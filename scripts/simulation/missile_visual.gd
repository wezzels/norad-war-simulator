## missile_visual.gd
## Visual representation of a missile
## Updates position based on game state data

extends Node3D

# Properties
var missile_id: String = ""
var target_city: String = ""

# Nodes
@onready var body: MeshInstance3D = $Body
@onready var contrail: MeshInstance3D = $Contrail
@onready var glow: OmniLight3D = $Glow

# Trajectory
var start_pos: Vector3 = Vector3.ZERO
var end_pos: Vector3 = Vector3.ZERO
var peak_altitude: float = 20.0
var progress: float = 0.0  # 0-1

# Globe radius (match globe_renderer.gd)
const GLOBE_RADIUS: float = 100.0


func initialize(missile_data: Dictionary) -> void:
	"""Initialize from game state missile data"""
	missile_id = missile_data.get("id", "")
	target_city = missile_data.get("target", "")
	
	# Get positions
	var origin_lat: float = missile_data.get("origin_lat", 0.0)
	var origin_lon: float = missile_data.get("origin_lon", 0.0)
	var target_lat: float = missile_data.get("target_lat", 0.0)
	var target_lon: float = missile_data.get("target_lon", 0.0)
	
	start_pos = lat_lon_to_3d(origin_lat, origin_lon, GLOBE_RADIUS)
	end_pos = lat_lon_to_3d(target_lat, target_lon, GLOBE_RADIUS)
	
	# Calculate peak altitude based on distance
	var distance: float = start_pos.distance_to(end_pos)
	peak_altitude = distance * 0.15 + 10.0
	
	# Initialize contrail
	contrail.clear_points()
	
	# Set progress
	progress = missile_data.get("progress", 0.0) / 100.0


func _process(delta: float) -> void:
	# Find our missile in game state
	var missile_data: Dictionary = GameState.get_missile_by_id(missile_id)
	
	if missile_data.is_empty():
		# Missile no longer exists (intercepted or impact)
		queue_free()
		return
	
	# Update progress
	progress = missile_data.get("progress", 0.0) / 100.0
	update_position()
	update_contrail()
	
	# Update glow based on phase
	var status: String = missile_data.get("status", "midcourse")
	match status:
		"launching", "boost":
			glow.light_energy = 4.0
			glow.omni_range = 15.0
		"terminal":
			glow.light_energy = 3.0
			glow.omni_range = 10.0
		_:
			glow.light_energy = 2.0
			glow.omni_range = 8.0
	
	# Remove if intercepted
	if missile_data.get("intercepted", false):
		# Explosion effect
		glow.light_energy = 10.0
		glow.omni_range = 30.0
		
		# Fade out
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 0.5)
		await tween.finished
		queue_free()


func update_position() -> void:
	"""Update position along trajectory"""
	# Lerp between start and end with altitude curve
	var t: float = progress
	
	# Horizontal position (spherical interpolation would be better)
	var pos: Vector3 = start_pos.lerp(end_pos, t)
	
	# Add altitude (parabolic curve)
	var altitude: float = peak_altitude * sin(PI * t)
	
	# Push out from globe center
	var direction: Vector3 = pos.normalized()
	var distance: float = GLOBE_RADIUS + altitude
	
	global_position = direction * distance
	
	# Orient along trajectory
	if t < 0.99:
		var next_pos: Vector3 = start_pos.lerp(end_pos, min(1.0, t + 0.01))
		var next_alt: float = peak_altitude * sin(PI * min(1.0, t + 0.01))
		next_pos = next_pos.normalized() * (GLOBE_RADIUS + next_alt)
		
		look_at(next_pos, Vector3.UP)


func update_contrail() -> void:
	"""Update contrail points"""
	# Add current position if moved enough
	if contrail.get_point_count() == 0:
		contrail.add_point(global_position)
	else:
		var last_point: Vector3 = contrail.get_point_position(contrail.get_point_count() - 1)
		if global_position.distance_to(last_point) > 1.0:
			contrail.add_point(global_position)
		
		# Limit contrail length
		while contrail.get_point_count() > 100:
			contrail.remove_point(0)


func lat_lon_to_3d(lat: float, lon: float, radius: float) -> Vector3:
	"""Convert lat/lon to 3D coordinates"""
	var lat_rad: float = deg_to_rad(lat)
	var lon_rad: float = deg_to_rad(lon)
	
	var x: float = radius * cos(lat_rad) * cos(lon_rad)
	var y: float = radius * sin(lat_rad)
	var z: float = radius * cos(lat_rad) * sin(lon_rad)
	
	return Vector3(x, y, z)