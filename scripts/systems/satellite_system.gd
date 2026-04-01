## satellite_system.gd
## Satellite detection and tracking system
## Simulates DSP, SBIRS, and GPS-III satellites

extends Node


# Signal when satellite detects something
signal detection_event(satellite: Dictionary, event_type: String, data: Dictionary)

# Satellite configurations (loaded from JSON)
var SATELLITES: Dictionary = {}

# Detection events tracking
var detection_history: Array[Dictionary] = []
const MAX_HISTORY: int = 100


func _ready() -> void:
	# Load satellites from JSON
	_load_satellites()


func _load_satellites() -> void:
	"""Load satellite data from JSON file"""
	var file: FileAccess = FileAccess.open("res://data/satellites.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data: Array = json.data
			for sat: Dictionary in data:
				SATELLITES[sat.id] = sat


func get_satellite(satellite_id: String) -> Dictionary:
	"""Get satellite configuration"""
	return SATELLITES.get(satellite_id, {}).duplicate(true)


func get_all_satellites() -> Dictionary:
	"""Get all satellite configurations"""
	return SATELLITES.duplicate(true)


func get_satellites_by_type(sat_type: String) -> Array[Dictionary]:
	"""Get all satellites of a specific type"""
	var result: Array[Dictionary] = []
	for sat_id: String in SATELLITES:
		var sat: Dictionary = SATELLITES[sat_id]
		if sat.get("type", "") == sat_type:
			result.append(sat)
	return result


func get_satellites_by_orbit(orbit_type: String) -> Array[Dictionary]:
	"""Get all satellites in a specific orbit"""
	var result: Array[Dictionary] = []
	for sat_id: String in SATELLITES:
		var sat: Dictionary = SATELLITES[sat_id]
		if sat.get("orbit", "") == orbit_type:
			result.append(sat)
	return result


func detect_launch(origin_lat: float, origin_lon: float) -> Dictionary:
	"""
	Detect a missile launch using available satellites.
	Returns detection data with confidence and timing.
	"""
	var detections: Array[Dictionary] = []
	var best_confidence: float = 0.0
	var best_detection: Dictionary = {}
	
	for sat_id: String in SATELLITES:
		var sat: Dictionary = SATELLITES[sat_id]
		
		# Check if satellite can detect launches
		if not sat.get("detection_types", []).has("IR_launch"):
			continue
		
		# Check visibility (simplified - would use actual orbital mechanics)
		var can_see: bool = _check_visibility(origin_lat, origin_lon, sat)
		
		if can_see:
			# Calculate detection confidence
			var confidence: float = _calculate_confidence(sat, origin_lat, origin_lon)
			
			var detection: Dictionary = {
				"satellite_id": sat_id,
				"satellite_type": sat.type,
				"confidence": confidence,
				"detection_time": Time.get_ticks_msec() / 1000.0,
				"lat": origin_lat,
				"lon": origin_lon
			}
			
			detections.append(detection)
			
			if confidence > best_confidence:
				best_confidence = confidence
				best_detection = detection
	
	# Record detection
	if not detections.is_empty():
		_record_detection("launch", {"detections": detections})
		detection_event.emit(best_detection, "launch_detected", {"detections": detections})
	
	return {
		"detected": not detections.is_empty(),
		"detections": detections,
		"best": best_detection
	}


func track_missile(missile_id: String, lat: float, lon: float, altitude: float) -> Dictionary:
	"""
	Track a missile using available satellites.
	Returns tracking data with position updates.
	"""
	var tracks: Array[Dictionary] = []
	
	# SBIRS satellites provide continuous tracking
	for sat_id: String in SATELLITES:
		var sat: Dictionary = SATELLITES[sat_id]
		if not sat.get("detection_types", []).has("IR_track"):
			continue
		
		var can_track: bool = _check_visibility(lat, lon, sat)
		
		if can_track:
			var track: Dictionary = {
				"satellite_id": sat_id,
				"type": sat.type,
				"position": {
					"lat": lat,
					"lon": lon,
					"alt": altitude
				},
				"timestamp": Time.get_ticks_msec() / 1000.0
			}
			tracks.append(track)
	
	return {
		"tracked": not tracks.is_empty(),
		"tracks": tracks
	}


func detect_detonation(lat: float, lon: float, altitude: float) -> Dictionary:
	"""
	Detect a nuclear detonation using NUDET sensors.
	"""
	var detections: Array[Dictionary] = []
	
	for sat_id: String in SATELLITES:
		var sat: Dictionary = SATELLITES[sat_id]
		if not sat.get("detection_types", []).has("NUDET"):
			continue
		
		var can_detect: bool = _check_visibility(lat, lon, sat)
		
		if can_detect:
			var detection: Dictionary = {
				"satellite_id": sat_id,
				"type": sat.type,
				"location": {"lat": lat, "lon": lon, "alt": altitude},
				"yield_estimate": _estimate_yield(altitude),
				"timestamp": Time.get_ticks_msec() / 1000.0
			}
			detections.append(detection)
	
	if not detections.is_empty():
		_record_detection("detonation", {"detections": detections})
		detection_event.emit(detections[0], "nudet_detected", {"detections": detections})
	
	return {
		"detected": not detections.is_empty(),
		"detections": detections
	}


func _check_visibility(lat: float, lon: float, sat: Dictionary) -> bool:
	"""Check if satellite can see a location (simplified)"""
	match sat.get("orbit", ""):
		"GEO":
			# Geostationary - sees about 1/3 of Earth
			var sat_lon: float = sat.get("longitude", 0.0)
			var lon_diff: float = abs(lat - lon - sat_lon)
			return lon_diff < 60.0 or lon_diff > 300.0
		"MEO":
			# Medium Earth Orbit - sees about half
			return true
		_:
			return false


func _calculate_confidence(sat: Dictionary, lat: float, lon: float) -> float:
	"""Calculate detection confidence based on satellite capabilities"""
	var base_confidence: float = 0.8
	
	# Higher refresh rate = better tracking
	var refresh: float = sat.get("refresh_rate_sec", 10.0)
	if refresh < 5.0:
		base_confidence += 0.1
	if refresh < 1.0:
		base_confidence += 0.05
	
	# SBIRS has better accuracy
	if sat.get("type", "") == "SBIRS":
		base_confidence += 0.05
	
	return min(base_confidence, 1.0)


func _estimate_yield(altitude: float) -> float:
	"""Estimate warhead yield based on detonation characteristics (simplified)"""
	return 500.0  # Placeholder - would calculate from actual data


func _record_detection(event_type: String, data: Dictionary) -> void:
	"""Record detection in history"""
	var record: Dictionary = {
		"event_type": event_type,
		"data": data,
		"timestamp": Time.get_ticks_msec() / 1000.0
	}
	
	detection_history.append(record)
	
	# Trim old records
	while detection_history.size() > MAX_HISTORY:
		detection_history.pop_front()


func get_detection_history() -> Array[Dictionary]:
	"""Get detection history"""
	return detection_history.duplicate(true)


func clear_history() -> void:
	"""Clear detection history"""
	detection_history.clear()