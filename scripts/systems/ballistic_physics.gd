## ballistic_physics.gd
## Accurate ballistic missile trajectory calculations
## Based on real ICBM physics with Earth curvature

extends Node

class_name BallisticPhysics

# Constants
const EARTH_RADIUS_KM: float = 6371.0  # km
const GRAVITY: float = 9.81  # m/s²
const EARTH_MASS: float = 5.972e24  # kg
const GRAVITATIONAL_CONSTANT: float = 6.674e-11  # m³/(kg·s²)

# Missile type configurations
const MISSILE_TYPES: Dictionary = {
	"ICBM": {
		"boost_time": 180.0,  # seconds (3 minutes)
		"boost_acceleration": 30.0,  # m/s²
		"burnout_velocity": 7000.0,  # m/s
		"max_altitude_km": 1200.0,  # km
		"reentry_velocity": 7000.0,  # m/s
		"warhead_mass_kg": 500.0,  # kg
		"types": ["Minuteman III", "Peacekeeper", "SS-18", "DF-41"]
	},
	"IRBM": {
		"boost_time": 120.0,
		"boost_acceleration": 25.0,
		"burnout_velocity": 4000.0,
		"max_altitude_km": 600.0,
		"reentry_velocity": 4000.0,
		"warhead_mass_kg": 750.0,
		"types": ["Taepodong-2", "Agni-V", "Shahab-3"]
	},
	"SRBM": {
		"boost_time": 60.0,
		"boost_acceleration": 20.0,
		"burnout_velocity": 2000.0,
		"max_altitude_km": 150.0,
		"reentry_velocity": 2000.0,
		"warhead_mass_kg": 1000.0,
		"types": ["Scud", "Iskander", "ATACMS"]
	}
}


## Calculate great circle distance between two points on Earth
func great_circle_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
	"""Calculate distance in km using Haversine formula"""
	var lat1_rad: float = deg_to_rad(lat1)
	var lat2_rad: float = deg_to_rad(lat2)
	var lon1_rad: float = deg_to_rad(lon1)
	var lon2_rad: float = deg_to_rad(lon2)
	
	var dlat: float = lat2_rad - lat1_rad
	var dlon: float = lon2_rad - lon1_rad
	
	var a: float = sin(dlat/2) * sin(dlat/2) + cos(lat1_rad) * cos(lat2_rad) * sin(dlon/2) * sin(dlon/2)
	var c: float = 2 * atan2(sqrt(a), sqrt(1-a))
	
	return EARTH_RADIUS_KM * c


## Calculate initial bearing from point 1 to point 2
func initial_bearing(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
	"""Calculate bearing in degrees"""
	var lat1_rad: float = deg_to_rad(lat1)
	var lat2_rad: float = deg_to_rad(lat2)
	var dlon_rad: float = deg_to_rad(lon2 - lon1)
	
	var x: float = cos(lat2_rad) * sin(dlon_rad)
	var y: float = cos(lat1_rad) * sin(lat2_rad) - sin(lat1_rad) * cos(lat2_rad) * cos(dlon_rad)
	
	var bearing: float = rad_to_deg(atan2(x, y))
	return fmod(bearing + 360.0, 360.0)


## Calculate intermediate point along great circle
func intermediate_point(lat1: float, lon1: float, lat2: float, lon2: float, fraction: float) -> Dictionary:
	"""Get lat/lon at fraction (0-1) along great circle path"""
	var lat1_rad: float = deg_to_rad(lat1)
	var lat2_rad: float = deg_to_rad(lat2)
	var lon1_rad: float = deg_to_rad(lon1)
	var lon2_rad: float = deg_to_rad(lon2)
	
	var d: float = great_circle_distance(lat1, lon1, lat2, lon2) / EARTH_RADIUS_KM
	
	var a: float = sin((1 - fraction) * d) / sin(d)
	var b: float = sin(fraction * d) / sin(d)
	
	var x: float = a * cos(lat1_rad) * cos(lon1_rad) + b * cos(lat2_rad) * cos(lon2_rad)
	var y: float = a * cos(lat1_rad) * sin(lon1_rad) + b * cos(lat2_rad) * sin(lon2_rad)
	var z: float = a * sin(lat1_rad) + b * sin(lat2_rad)
	
	var lat: float = rad_to_deg(atan2(z, sqrt(x*x + y*y)))
	var lon: float = rad_to_deg(atan2(y, x))
	
	return {"lat": lat, "lon": lon}


## Calculate altitude at fraction of trajectory
func altitude_at_fraction(fraction: float, max_altitude: float, total_distance: float) -> float:
	"""
	Calculate altitude using parabolic approximation.
	For a suborbital trajectory, altitude follows approximately:
	h(t) = v₀ * sin(θ) * t - 0.5 * g * t²
	
	We approximate this as a parabola peaked at 0.5 fraction.
	"""
	# Parabolic altitude profile
	# h = h_max * 4 * f * (1 - f) for a symmetric trajectory
	# But real trajectories are asymmetric - boost is shorter
	
	# Use asymmetric profile: boost at 15%, peak at 50%, terminal at 85%
	if fraction < 0.15:
		# Boost phase - rapid altitude increase
		return max_altitude * pow(fraction / 0.15, 0.8) * 0.3
	elif fraction < 0.50:
		# Midcourse phase - climbing to apogee
		var t: float = (fraction - 0.15) / 0.35
		return max_altitude * (0.3 + 0.7 * sin(PI * t / 2))
	elif fraction < 0.85:
		# Midcourse descending
		var t: float = (fraction - 0.50) / 0.35
		return max_altitude * (1.0 - 0.3 * t)
	else:
		# Terminal phase - rapid descent
		var t: float = (fraction - 0.85) / 0.15
		return max_altitude * 0.7 * pow(1.0 - t, 1.5)


## Calculate flight time for a trajectory
func calculate_flight_time(distance_km: float, missile_type: String = "ICBM") -> float:
	"""Calculate total flight time in seconds"""
	var type_data: Dictionary = MISSILE_TYPES.get(missile_type, MISSILE_TYPES.ICBM)
	var boost_time: float = type_data.boost_time
	
	# Coasting time is distance / average velocity
	# Use burnout velocity as approximation
	var coast_velocity: float = type_data.burnout_velocity / 1000.0  # km/s
	var coast_distance: float = distance_km - 100.0  # Approximate boost distance
	var coast_time: float = max(0, coast_distance / coast_velocity)
	
	# Terminal phase (reentry)
	var terminal_time: float = 120.0  # ~2 minutes for reentry
	
	return boost_time + coast_time + terminal_time


## Calculate velocity at a given point in trajectory
func velocity_at_fraction(fraction: float, missile_type: String = "ICBM") -> float:
	"""Calculate velocity in m/s at given fraction of trajectory"""
	var type_data: Dictionary = MISSILE_TYPES.get(missile_type, MISSILE_TYPES.ICBM)
	
	if fraction < 0.15:
		# Boost phase - accelerating
		var t: float = fraction / 0.15
		return type_data.boost_acceleration * type_data.boost_time * t
	elif fraction < 0.85:
		# Midcourse - roughly constant (with some variation due to gravity)
		return type_data.burnout_velocity * (0.9 + 0.2 * (0.5 - abs(fraction - 0.5)))
	else:
		# Terminal - accelerating due to gravity
		var t: float = (fraction - 0.85) / 0.15
		return type_data.reentry_velocity * (1.0 + 0.3 * t)


## Calculate position at time
func position_at_time(origin_lat: float, origin_lon: float, target_lat: float, target_lon: float, 
						elapsed_time: float, total_time: float, missile_type: String = "ICBM") -> Dictionary:
	"""Calculate position (lat, lon, altitude) at given time"""
	var fraction: float = clamp(elapsed_time / total_time, 0.0, 1.0)
	
	# Get ground position
	var ground_pos: Dictionary = intermediate_point(origin_lat, origin_lon, target_lat, target_lon, fraction)
	
	# Get altitude
	var distance: float = great_circle_distance(origin_lat, origin_lon, target_lat, target_lon)
	var type_data: Dictionary = MISSILE_TYPES.get(missile_type, MISSILE_TYPES.ICBM)
	var altitude: float = altitude_at_fraction(fraction, type_data.max_altitude_km, distance)
	
	# Get velocity
	var velocity: float = velocity_at_fraction(fraction, missile_type)
	
	# Determine phase
	var phase: String = "midcourse"
	if fraction < 0.15:
		phase = "boost"
	elif fraction >= 0.85:
		phase = "terminal"
	
	return {
		"lat": ground_pos.lat,
		"lon": ground_pos.lon,
		"altitude_km": altitude,
		"velocity_ms": velocity,
		"phase": phase,
		"fraction": fraction
	}


## Calculate intercept probability
func intercept_probability(missile_phase: String, interceptor_type: String, distance_km: float) -> float:
	"""
	Calculate probability of successful intercept.
	Based on real-world performance data.
	"""
	# Base probabilities by interceptor type
	var base_prob: Dictionary = {
		"GBI": 0.55,  # Ground-based Interceptor
		"THAAD": 0.60,  # Terminal High Altitude Area Defense
		"Patriot": 0.45,  # PAC-3
		"Aegis": 0.65  # SM-3
	}
	
	var prob: float = base_prob.get(interceptor_type, 0.5)
	
	# Phase modifiers
	var phase_mod: Dictionary = {
		"boost": 0.3,  # Very hard to intercept
		"midcourse": 1.0,  # Best chance
		"terminal": 0.7  # Limited time
	}
	prob *= phase_mod.get(missile_phase, 0.8)
	
	# Distance modifiers (for THAAD/Patriot)
	if interceptor_type == "THAAD" and distance_km > 150:
		prob *= 0.8
	elif interceptor_type == "Patriot" and distance_km > 50:
		prob *= 0.6
	
	return clamp(prob, 0.1, 0.9)


## Get missile type data
func get_missile_data(missile_type: String) -> Dictionary:
	"""Get configuration for a missile type"""
	return MISSILE_TYPES.get(missile_type, MISSILE_TYPES.ICBM).duplicate(true)