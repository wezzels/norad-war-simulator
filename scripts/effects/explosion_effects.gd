## explosion_effects.gd
## Improved explosion effects with multiple stages
## Fire, smoke, shockwave, and debris

extends Node3D

class_name ExplosionEffects

# Stages
enum Stage { FIREBALL, SMOKE, SHOCKWAVE, DEBRIS, CLEANUP }

# Current stage
var current_stage: Stage = Stage.FIREBALL
var elapsed: float = 0.0

# Properties
@export var yield_kt: int = 500
@export var duration: float = 5.0

# Nodes
@onready var fireball: GPUParticles3D = $Fireball
@onready var smoke: GPUParticles3D = $SmokeColumn
@onready var shockwave: GPUParticles3D = $Shockwave
@onready var debris: GPUParticles3D = $Debris
@onready var flash: OmniLight3D = $FlashLight
@onready var glow: OmniLight3D = $GlowLight

# Timing
const FIREBALL_DURATION: float = 0.5
const SMOKE_START: float = 0.3
const SHOCKWAVE_START: float = 0.1
const DEBRIS_START: float = 0.2
const FLASH_DURATION: float = 0.3


func _ready() -> void:
	# Initialize all particles
	if fireball:
		fireball.emitting = false
	if smoke:
		smoke.emitting = false
	if shockwave:
		shockwave.emitting = false
	if debris:
		debris.emitting = false
	if flash:
		flash.light_energy = 0.0
	if glow:
		glow.light_energy = 0.0


func initialize(yield_kilotons: int) -> void:
	"""Initialize explosion with yield"""
	yield_kt = yield_kilotons
	duration = 3.0 + sqrt(float(yield_kt)) * 0.5
	
	# Scale effects based on yield
	var scale: float = sqrt(float(yield_kt)) / sqrt(500.0)
	
	if fireball:
		fireball.scale = Vector3.ONE * scale
		fireball.amount = int(80 * scale)
	
	if smoke:
		smoke.scale = Vector3.ONE * scale
		smoke.amount = int(50 * scale)
	
	if shockwave:
		shockwave.scale = Vector3.ONE * scale
		shockwave.amount = int(30 * scale)
	
	if debris:
		debris.scale = Vector3.ONE * scale
		debris.amount = int(40 * scale)
	
	if flash:
		flash.omni_range = 50.0 * scale
	
	start_effect()


func start_effect() -> void:
	"""Start all explosion effects"""
	elapsed = 0.0
	current_stage = Stage.FIREBALL
	
	# Fireball
	if fireball:
		fireball.restart()
		fireball.emitting = true
	
	# Flash
	if flash:
		flash.light_energy = 150.0
		flash.light_color = Color(1.0, 0.9, 0.7)
	
	# Shockwave (delayed)
	get_tree().create_timer(SHOCKWAVE_START).timeout.connect(_start_shockwave)
	
	# Smoke (delayed)
	get_tree().create_timer(SMOKE_START).timeout.connect(_start_smoke)
	
	# Debris (delayed)
	get_tree().create_timer(DEBRIS_START).timeout.connect(_start_debris)
	
	# Flash fade
	get_tree().create_timer(FLASH_DURATION).timeout.connect(_fade_flash)
	
	# Audio
	AudioManager.play_detonation()


func _start_shockwave() -> void:
	"""Start shockwave effect"""
	if shockwave:
		shockwave.restart()
		shockwave.emitting = true


func _start_smoke() -> void:
	"""Start smoke column"""
	if smoke:
		smoke.restart()
		smoke.emitting = true


func _start_debris() -> void:
	"""Start debris particles"""
	if debris:
		debris.restart()
		debris.emitting = true


func _fade_flash() -> void:
	"""Fade out the flash"""
	if flash:
		var tween: Tween = create_tween()
		tween.tween_property(flash, "light_energy", 0.0, 2.0)


func _process(delta: float) -> void:
	elapsed += delta
	
	# Glow fades based on stage
	if glow:
		match current_stage:
			Stage.FIREBALL:
				glow.light_energy = lerp(50.0, 30.0, elapsed / FIREBALL_DURATION)
			Stage.SMOKE:
				glow.light_energy = lerp(30.0, 15.0, (elapsed - FIREBALL_DURATION) / 2.0)
			Stage.CLEANUP:
				glow.light_energy = lerp(15.0, 5.0, (elapsed - 3.0) / 2.0)
	
	# Cleanup
	if elapsed > duration:
		if fireball:
			fireball.emitting = false
		if smoke:
			smoke.emitting = false
		if shockwave:
			shockwave.emitting = false
		if debris:
			debris.emitting = false
		
		# Queue free after particles finish
		await get_tree().create_timer(3.0).timeout
		queue_free()


func get_blast_radius() -> float:
	"""Calculate blast radius in km"""
	return sqrt(float(yield_kt)) * 0.5


func get_thermal_radius() -> float:
	"""Calculate thermal radius in km"""
	return sqrt(float(yield_kt)) * 0.8