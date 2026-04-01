## detonation.gd
## Nuclear detonation effect
## Visual and audio representation of nuclear explosion

extends Node3D

class_name Detonation

# Signals
signal detonation_complete(detonation: Detonation)

# Properties
@export var yield_kt: int = 500  # Kilotons
@export var detonation_duration: float = 2.0

# Visual
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var flash_light: OmniLight3D = $FlashLight
@onready var mushroom_cloud: GPUParticles3D = $MushroomCloud

# State
var elapsed: float = 0.0
var active: bool = false


func _ready() -> void:
	# Initialize particles
	if explosion_particles:
		explosion_particles.emitting = false
	if mushroom_cloud:
		mushroom_cloud.emitting = false
	if flash_light:
		flash_light.light_energy = 0.0


func initialize(yield_kilotons: int, city_name: String) -> void:
	"""Initialize detonation with yield"""
	yield_kt = yield_kilotons
	
	# Scale effect based on yield
	var scale_factor: float = sqrt(float(yield_kt) / 500.0)
	
	if explosion_particles:
		explosion_particles.scale = Vector3.ONE * scale_factor
	
	if flash_light:
		flash_light.omni_range = 50.0 * scale_factor
	
	# Start effect
	start_effect()


func start_effect() -> void:
	"""Start detonation effect"""
	active = true
	elapsed = 0.0
	
	# Initial flash
	if flash_light:
		flash_light.light_energy = 100.0
		flash_light.light_color = Color(1.0, 0.9, 0.7)
	
	# Start particles
	if explosion_particles:
		explosion_particles.emitting = true
	
	# Play sound
	AudioManager.play_detonation()
	
	# Camera shake
	camera_shake()


func _process(delta: float) -> void:
	if not active:
		return
	
	elapsed += delta
	
	# Flash fades quickly
	if flash_light and elapsed < 0.5:
		flash_light.light_energy = 100.0 * (1.0 - elapsed / 0.5)
	
	# Mushroom cloud rises
	if mushroom_cloud and elapsed > 0.3:
		if not mushroom_cloud.emitting:
			mushroom_cloud.emitting = true
	
	# End after duration
	if elapsed >= detonation_duration:
		end_effect()


func camera_shake() -> void:
	"""Shake camera based on yield"""
	# Find camera
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Calculate shake intensity
	var shake_intensity: float = min(1.0, sqrt(float(yield_kt) / 100.0))
	
	# Apply shake (would need camera controller support)
	# For now, just print
	print("Detonation yield: %d kt, shake: %.2f" % [yield_kt, shake_intensity])


func end_effect() -> void:
	"""End detonation effect"""
	active = false
	
	if explosion_particles:
		explosion_particles.emitting = false
	
	if mushroom_cloud:
		mushroom_cloud.emitting = false
	
	detonation_complete.emit(self)
	
	# Remove after delay
	await get_tree().create_timer(1.0).timeout
	queue_free()


func get_blast_radius() -> float:
	"""Calculate blast radius in km based on yield"""
	# Simplified formula: R = C * Y^(1/3)
	# C ≈ 1.2 for 50% destruction
	var radius: float = 1.2 * pow(float(yield_kt), 1.0/3.0)
	return radius


func get_thermal_radius() -> float:
	"""Calculate thermal radiation radius in km"""
	# Simplified: thermal radius ~ 2x blast radius
	return get_blast_radius() * 2.0