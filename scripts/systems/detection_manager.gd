## detection_manager.gd
## Manages satellite detection events
## Integrates satellite system with game state

extends Node


# Signals
signal launch_detected(detection: Dictionary)
signal track_update(missile_id: String, position: Dictionary)
signal detonation_detected(detection: Dictionary)

# Detection events
var active_tracks: Dictionary = {}  # missile_id -> last detection
var detection_log: Array[Dictionary] = []
const MAX_LOG_SIZE: int = 100


func _ready() -> void:
	# Connect to game state
	GameState.missile_launched.connect(_on_missile_launched)
	GameState.missile_intercepted.connect(_on_missile_intercepted)
	
	# Connect to satellite system
	Satellites.detection_event.connect(_on_satellite_detection)


func _process(delta: float) -> void:
	if GameState.paused:
		return
	
	# Update tracking for all active missiles
	for missile: Dictionary in GameState.missiles:
		_track_missile(missile)


func _on_missile_launched(missile: Dictionary) -> void:
	"""Process new missile launch through satellite detection"""
	# Detect launch using satellites
	var detection: Dictionary = Satellites.detect_launch(
		missile.origin_lat,
		missile.origin_lon
	)
	
	if detection.detected:
		# Log detection
		var event: Dictionary = {
			"type": "launch",
			"missile_id": missile.id,
			"origin": missile.origin,
			"target": missile.target,
			"time": GameState.simulation_time,
			"detections": detection.detections
		}
		detection_log.append(event)
		
		# Create alert
		var alert_text: String = "LAUNCH DETECTED by %s\n" % detection.best.satellite_id
		alert_text += "Origin: %s\n" % missile.origin
		alert_text += "Trajectory: %s → %s" % [missile.origin, missile.target]
		
		GameState.alerts.append(alert_text)
		GameState.alert_received.emit({"level": detection.best.satellite_id, "text": alert_text, "priority": 3})
		
		# Start tracking
		active_tracks[missile.id] = {
			"missile_id": missile.id,
			"last_update": GameState.simulation_time,
			"detections": []
		}
		
		launch_detected.emit(detection)
	else:
		# Launch not detected (all satellites blind?)
		push_warning("Launch not detected by any satellite: %s" % missile.id)


func _track_missile(missile: Dictionary) -> void:
	"""Update tracking for a missile"""
	var track_data: Dictionary = active_tracks.get(missile.id, {})
	
	if track_data.is_empty():
		return
	
	# Get tracking update from satellites
	var track: Dictionary = Satellites.track_missile(
		missile.id,
		missile.position.lat,
		missile.position.lon,
		missile.altitude
	)
	
	if track.tracking:
		# Update track data
		track_data.last_update = GameState.simulation_time
		track_data.position = track.position
		
		# Store best track
		if track.tracks.size() > 0:
			track_data.detections.append(track.tracks[0])
			
			# Limit detections stored
			if track_data.detections.size() > 20:
				track_data.detections.pop_front()
		
		active_tracks[missile.id] = track_data
		
		# Signal update
		track_update.emit(missile.id, track.position)


func _on_missile_intercepted(missile_id: String) -> void:
	"""Remove tracking for intercepted missile"""
	active_tracks.erase(missile_id)


func _on_satellite_detection(satellite: Dictionary, event_type: String, data: Dictionary) -> void:
	"""Handle satellite detection events"""
	match event_type:
		"launch_detected":
			# Already handled in _on_missile_launched
			pass
		
		"detonation_detected":
			_handle_detonation_detection(satellite, data)


func _handle_detonation_detection(satellite: Dictionary, data: Dictionary) -> void:
	"""Process nuclear detonation detection"""
	var event: Dictionary = {
		"type": "detonation",
		"satellite": satellite.id,
		"lat": data.lat,
		"lon": data.lon,
		"yield_estimated": data.yield_estimated_kt,
		"time": GameState.simulation_time
	}
	
	detection_log.append(event)
	
	# Estimate yield
	var yield_estimate: int = Damage.estimate_yield(data)
	var yield_category: Dictionary = Damage.get_yield_category(yield_estimate)
	
	# Create alert
	var alert_text: String = "NUCLEAR DETONATION detected by %s\n" % satellite.id
	alert_text += "Location: %.2f°, %.2f°\n" % [data.lat, data.lon]
	alert_text += "Estimated yield: %d kt (%s)" % [yield_estimate, yield_category.category]
	
	GameState.alerts.append(alert_text)
	GameState.alert_received.emit({"level": satellite.id, "text": alert_text, "priority": 3})
	
	detonation_detected.emit(data)


func get_active_tracks() -> Dictionary:
	"""Get all active missile tracks"""
	return active_tracks.duplicate(true)


func get_detection_log(limit: int = 50) -> Array[Dictionary]:
	"""Get recent detection log entries"""
	var start: int = max(0, detection_log.size() - limit)
	return detection_log.slice(start)


func get_missile_track(missile_id: String) -> Dictionary:
	"""Get tracking data for a specific missile"""
	return active_tracks.get(missile_id, {})


func get_detection_confidence(missile_id: String) -> float:
	"""Get overall confidence for a missile track"""
	var track: Dictionary = active_tracks.get(missile_id, {})
	if track.is_empty():
		return 0.0
	
	var detections: Array = track.get("detections", [])
	if detections.is_empty():
		return 0.0
	
	# Average confidence
	var total: float = 0.0
	for det: Dictionary in detections:
		total += det.get("confidence", 0.5)
	
	return total / detections.size()


func clear_detection_log() -> void:
	"""Clear detection log"""
	detection_log.clear()


func get_statistics() -> Dictionary:
	"""Get detection statistics"""
	var stats: Dictionary = {
		"total_detections": detection_log.size(),
		"launch_detections": 0,
		"detonation_detections": 0,
		"active_tracks": active_tracks.size()
	}
	
	for event: Dictionary in detection_log:
		match event.type:
			"launch":
				stats.launch_detections += 1
			"detonation":
				stats.detonation_detections += 1
	
	return stats