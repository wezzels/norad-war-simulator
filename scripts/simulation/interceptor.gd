## interceptor.gd
## Interceptor missile entity
## Launches from defense sites to intercept incoming threats

extends Node3D

class_name Interceptor

# Signals
signal launched(interceptor: Interceptor)
signal hit(interceptor: Interceptor, target_id: String)
signal missed(interceptor: Interceptor)

# Properties
@export var interceptor_type: String = "GBI"  # GBI, THAAD, Patriot
@export var max_range: float = 5000.0  # km
@export var max_altitude: float = 2000.0  # km
@export var speed: float = 8.0  # km/s

# State
var interceptor_id: String = ""
var target_missile_id: String = ""
var progress: float = 0.0  # 0-1
var active: bool = false
var hit_success: bool = false

# Trajectory
var launch_position: Vector3 = Vector3.ZERO
var target_position: Vector3 = Vector3.ZERO
var current_position: Vector3 = Vector3.ZERO
var flight_time: float = 0.0

# Type-specific stats (static reference)
static var TYPE_STATS: Dictionary = {
	"GBI": {"range": 5000.0, "altitude": 2000.0, "speed": 8.0, "success_base": 0.7},
	"THAAD": {"range": 200.0, "altitude": 150.0, "speed": 2.8, "success_base": 0.6},
	"Patriot": {"range": 160.0, "altitude": 24.0, "speed": 1.5, "success_base": 0.5}
}

# Visual
var trail_points: Array[Vector3] = []
const MAX_TRAIL_POINTS: int = 50


func _ready() -> void:
	# Set type-specific stats
	if TYPE_STATS.has(interceptor_type):
		var stats: Dictionary = TYPE_STATS[interceptor_type]
		max_range = stats.range
		max_altitude = stats.altitude
		speed = stats.speed


func initialize(target_id: String, launch_pos: Vector3, target_pos: Vector3, success_chance: float) -> void:
	"""Initialize interceptor with target"""
	interceptor_id = "INT-%s-%d" % [Time.get_time_string_from_system().replace(":", ""), randi_range(100, 999)]
	target_missile_id = target_id
	launch_position = launch_pos
	target_position = target_pos
	
	# Calculate flight time
	var distance: float = launch_pos.distance_to(target_pos)
	flight_time = distance / (speed * 60.0)  # Convert to game time
	
	# Determine hit success
	hit_success = randf() < success_chance
	
	active = true
	launched.emit(self)
	
	# Clear trail points
	trail_points.clear()


func _process(delta: float) -> void:
	if not active:
		return
	
	# Update progress
	var dt: float = delta * GameState.speed_multiplier
	progress += dt / flight_time
	
	# Calculate position
	update_position()
	
	# Update trail
	update_trail()
	
	# Check for hit/miss
	if progress >= 1.0:
		complete_intercept()


func update_position() -> void:
	"""Update position along trajectory"""
	# Interpolate between launch and target
	current_position = launch_position.lerp(target_position, progress)
	
	# Add altitude curve (parabolic)
	var altitude: float = sin(PI * progress) * max_altitude * 0.1
	
	# Push out from globe
	var direction: Vector3 = current_position.normalized()
	var distance: float = 100.0 + altitude  # Globe radius + altitude
	
	global_position = direction * distance


func update_trail() -> void:
	"""Update trail effect"""
	trail_points.append(global_position)
	
	if trail_points.size() > MAX_TRAIL_POINTS:
		trail_points.pop_front()
	# Trail visualization would be done via particle system or mesh


func complete_intercept() -> void:
	"""Complete the intercept attempt"""
	active = false
	
	if hit_success:
		hit.emit(self, target_missile_id)
		# Visual: explosion effect
		create_explosion()
	else:
		missed.emit(self)
	
	# Remove after delay
	await get_tree().create_timer(0.5).timeout
	queue_free()


func create_explosion() -> void:
	"""Create explosion effect on hit"""
	# Would spawn particle effect here
	AudioManager.play_intercept()


func get_success_chance(missile_phase: String) -> float:
	"""Calculate intercept success chance based on missile phase"""
	var base: float = TYPE_STATS[interceptor_type].success_base
	
	match missile_phase:
		"boost":
			return base * 0.5  # Hard to intercept
		"midcourse":
			return base  # Best chance
		"terminal":
			return base * 0.7  # Limited time
		_:
			return base