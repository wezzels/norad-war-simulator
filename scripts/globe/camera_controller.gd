## camera_controller.gd
## Orbital camera controller
## Handles mouse/touch orbit, zoom, and click selection

extends Camera3D

# Target to orbit around
@export var orbit_target: Node3D
@export var orbit_distance: float = 300.0
@export var min_distance: float = 120.0
@export var max_distance: float = 600.0

# Rotation speeds
@export var horizontal_speed: float = 0.5
@export var vertical_speed: float = 0.3
@export var zoom_speed: float = 50.0

# Current rotation
var yaw: float = 0.0  # Horizontal rotation
var pitch: float = 0.3  # Vertical rotation (start tilted down)

# Limits
const MIN_PITCH: float = -PI/2 + 0.1
const MAX_PITCH: float = PI/2 - 0.1

# Input state
var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Find globe if not set
	if not orbit_target:
		orbit_target = get_parent().get_node("Globe")
	
	# Initial position
	update_position()


func _input(event: InputEvent) -> void:
	# Mouse drag for orbit
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
			last_mouse_pos = event.position
	
	# Mouse wheel for zoom
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			orbit_distance = maxf(min_distance, orbit_distance - zoom_speed)
			update_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			orbit_distance = minf(max_distance, orbit_distance + zoom_speed)
			update_position()
	
	# Touch pinch for zoom (mobile)
	# Note: InputEventScreenPinch is only available on mobile platforms
	# This is handled by the touch input system
	
	# Mouse movement for orbit
	elif event is InputEventMouseMotion:
		if is_dragging:
			var delta: Vector2 = event.position - last_mouse_pos
			yaw -= deg_to_rad(delta.x * horizontal_speed)
			pitch -= deg_to_rad(delta.y * vertical_speed)
			pitch = clamp(pitch, MIN_PITCH, MAX_PITCH)
			update_position()
			last_mouse_pos = event.position


func _process(delta: float) -> void:
	# Keyboard orbit controls
	var move_x: float = Input.get_axis("move_left", "move_right")
	var move_y: float = Input.get_axis("move_up", "move_down")
	
	if move_x != 0.0:
		yaw += deg_to_rad(move_x * horizontal_speed * 60.0 * delta)
		update_position()
	
	if move_y != 0.0:
		pitch += deg_to_rad(move_y * vertical_speed * 60.0 * delta)
		pitch = clamp(pitch, MIN_PITCH, MAX_PITCH)
		update_position()
	
	# Zoom with keyboard
	if Input.is_action_pressed("zoom_in"):
		orbit_distance = maxf(min_distance, orbit_distance - zoom_speed * delta)
		update_position()
	elif Input.is_action_pressed("zoom_out"):
		orbit_distance = minf(max_distance, orbit_distance + zoom_speed * delta)
		update_position()


func update_position() -> void:
	"""Update camera position based on rotation and distance"""
	if not orbit_target:
		return
	
	var target_pos: Vector3 = orbit_target.global_position
	
	# Calculate position from spherical coordinates
	var x: float = orbit_distance * cos(pitch) * cos(yaw)
	var y: float = orbit_distance * sin(pitch)
	var z: float = orbit_distance * cos(pitch) * sin(yaw)
	
	global_position = target_pos + Vector3(x, y, z)
	
	# Look at target
	look_at(target_pos, Vector3.UP)


func focus_on_position(lat: float, lon: float) -> void:
	"""Orbit to focus on a specific lat/lon"""
	var target_lat_rad: float = deg_to_rad(lat)
	var target_lon_rad: float = deg_to_rad(lon)
	
	# Calculate yaw and pitch to look at this position
	yaw = -target_lon_rad + PI/2
	pitch = target_lat_rad
	
	pitch = clamp(pitch, MIN_PITCH, MAX_PITCH)
	update_position()


func smooth_focus(lat: float, lon: float, duration: float = 1.0) -> void:
	"""Smoothly orbit to focus on a position"""
	var target_yaw: float = -deg_to_rad(lon) + PI/2
	var target_pitch: float = clamp(deg_to_rad(lat), MIN_PITCH, MAX_PITCH)
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "yaw", target_yaw, duration).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "pitch", target_pitch, duration).set_ease(Tween.EASE_IN_OUT)


func get_ray_direction(screen_pos: Vector2) -> Vector3:
	"""Get ray direction from screen position"""
	return project_ray_normal(screen_pos)


func screen_to_globe(screen_pos: Vector2) -> Dictionary:
	"""Convert screen position to lat/lon on globe"""
	var ray_origin: Vector3 = project_ray_origin(screen_pos)
	var ray_dir: Vector3 = project_ray_normal(screen_pos)
	
	# Ray-sphere intersection
	var globe_center: Vector3 = Vector3.ZERO
	var radius: float = 100.0  # Globe radius
	
	var oc: Vector3 = ray_origin - globe_center
	var a: float = ray_dir.dot(ray_dir)
	var b: float = 2.0 * oc.dot(ray_dir)
	var c: float = oc.dot(oc) - radius * radius
	
	var discriminant: float = b * b - 4 * a * c
	
	if discriminant < 0:
		return {}  # No intersection
	
	var t: float = (-b - sqrt(discriminant)) / (2.0 * a)
	var hit_point: Vector3 = ray_origin + t * ray_dir
	
	# Convert to lat/lon
	var lat: float = rad_to_deg(asin(hit_point.y / radius))
	var lon: float = rad_to_deg(atan2(hit_point.z, hit_point.x))
	
	return {"lat": lat, "lon": lon, "point": hit_point}