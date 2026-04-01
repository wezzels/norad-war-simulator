## hud_controller.gd
## Main HUD controller
## Manages UI elements, DEFCON display, alerts, and controls

extends CanvasLayer

# Nodes
@onready var defcon_label: Label = $HUD/DefconPanel/DefconLabel
@onready var speed_label: Label = $HUD/SpeedPanel/SpeedLabel
@onready var alert_container: VBoxContainer = $HUD/AlertPanel/AlertContainer
@onready var stats_label: Label = $HUD/StatsPanel/StatsLabel
@onready var pause_button: Button = $HUD/ControlPanel/PauseButton
@onready var speed_slider: HSlider = $HUD/ControlPanel/SpeedSlider

# Alert queue
var alert_queue: Array[Dictionary] = []
const MAX_ALERTS: int = 10


func _ready() -> void:
	# Connect to game state signals
	GameState.defcon_changed.connect(_on_defcon_changed)
	GameState.alert_received.connect(_on_alert_received)
	GameState.missile_launched.connect(_on_missile_launched)
	GameState.missile_intercepted.connect(_on_missile_intercepted)
	GameState.detonation_detected.connect(_on_detonation_detected)
	
	# Connect UI signals
	pause_button.pressed.connect(_on_pause_pressed)
	speed_slider.value_changed.connect(_on_speed_changed)
	
	# Initialize
	update_defcon_display()
	update_speed_display()
	update_stats()


func _process(delta: float) -> void:
	update_stats()


func update_defcon_display() -> void:
	"""Update DEFCON level display"""
	defcon_label.text = "DEFCON %d" % GameState.current_defcon
	
	# Color based on level
	match GameState.current_defcon:
		1: defcon_label.modulate = Color(1.0, 0.0, 0.0)  # Red - Maximum
		2: defcon_label.modulate = Color(1.0, 0.5, 0.0)  # Orange
		3: defcon_label.modulate = Color(1.0, 1.0, 0.0)  # Yellow
		4: defcon_label.modulate = Color(0.5, 1.0, 0.5)  # Light green
		5: defcon_label.modulate = Color(0.0, 1.0, 0.0)  # Green - Normal


func update_speed_display() -> void:
	"""Update simulation speed display"""
	if GameState.paused:
		speed_label.text = "PAUSED"
		speed_label.modulate = Color(1.0, 0.0, 0.0)
	else:
		speed_label.text = "Speed: %.1fx" % GameState.speed_multiplier
		speed_label.modulate = Color(1.0, 1.0, 1.0)


func update_stats() -> void:
	"""Update statistics display"""
	var stats_text: String = """
	Missiles Launched: %d
	Intercepted: %d
	Detonations: %d
	Cities Hit: %d
	Active Threats: %d
	""" % [
		GameState.stats.missiles_launched,
		GameState.stats.missiles_intercepted,
		GameState.stats.detonations_detected,
		GameState.stats.cities_hit,
		GameState.stats.threats_active
	]
	stats_label.text = stats_text


func add_alert(text: String, priority: int = 0) -> void:
	"""Add an alert to the queue"""
	var alert: Dictionary = {
		"text": text,
		"priority": priority,
		"time": Time.get_time_string_from_system()
	}
	
	alert_queue.append(alert)
	
	# Create label
	var label: Label = Label.new()
	label.text = "[%s] %s" % [alert.time, text]
	
	# Color by priority
	match priority:
		0: label.modulate = Color(1.0, 1.0, 1.0)  # White - Info
		1: label.modulate = Color(1.0, 1.0, 0.0)  # Yellow - Warning
		2: label.modulate = Color(1.0, 0.5, 0.0)  # Orange - High
		3: label.modulate = Color(1.0, 0.0, 0.0)  # Red - Critical
	
	alert_container.add_child(label)
	
	# Remove old alerts
	if alert_container.get_child_count() > MAX_ALERTS:
		alert_container.get_child(0).queue_free()
		alert_queue.pop_front()
	
	# Play alert sound for high priority
	if priority >= 2:
		AudioManager.play_alert()


# Signal handlers
func _on_defcon_changed(level: int) -> void:
	update_defcon_display()
	add_alert("DEFCON %d declared" % level, level)


func _on_alert_received(alert_data: Dictionary) -> void:
	add_alert(alert_data.text, alert_data.get("priority", 1))


func _on_missile_launched(missile: Dictionary) -> void:
	add_alert("LAUNCH DETECTED: %s → %s" % [missile.origin, missile.target], 3)


func _on_missile_intercepted(missile_id: String) -> void:
	add_alert("INTERCEPT SUCCESS: %s" % missile_id, 0)


func _on_detonation_detected(detonation: Dictionary) -> void:
	add_alert("NUCLEAR DETONATION: %s (%d kt)" % [detonation.city, detonation.yield], 3)


func _on_pause_pressed() -> void:
	if GameState.paused:
		GameState.resume()
		pause_button.text = "Pause"
	else:
		GameState.pause()
		pause_button.text = "Resume"
	update_speed_display()


func _on_speed_changed(value: float) -> void:
	GameState.set_speed(value)
	update_speed_display()


func _on_defcon_up_pressed() -> void:
	GameState.set_defcon(GameState.current_defcon + 1)


func _on_defcon_down_pressed() -> void:
	GameState.set_defcon(GameState.current_defcon - 1)