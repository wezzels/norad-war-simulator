## damage_model.gd
## Calculate damage from nuclear detonations
## Based on blast radius, thermal radiation, and fallout

extends Node

class_name DamageModel

# Nuclear effects constants
# Based on NUKEMAP and historical data

## Calculate blast radius for a given yield
## Returns radii in km for different damage levels
func calculate_blast_radius(yield_kt: float) -> Dictionary:
	"""
	Calculate blast radii for different damage levels.
	Uses simplified scaling laws from nuclear weapons effects.
	"""
	# Scaling: R = C * Y^(1/3) where Y is yield in kt
	# C varies by damage level
	
	var y_third: float = pow(yield_kt, 1.0/3.0)
	
	return {
		"fireball": 0.15 * y_third,  # km - everything vaporized
		"heavy_damage": 0.4 * y_third,  # km - reinforced structures destroyed
		"moderate_damage": 0.6 * y_third,  # km - residential destroyed
		"light_damage": 1.0 * y_third,  # km - windows broken, minor damage
		"thermal": 1.5 * y_third,  # km - third-degree burns
		"radiation": 2.0 * y_third  # km - acute radiation sickness
	}


## Calculate thermal radiation radius
func calculate_thermal_radius(yield_kt: float, burn_degree: int = 3) -> float:
	"""
	Calculate radius for thermal radiation effects.
	Burn degree: 1 = first degree, 2 = second degree, 3 = third degree
	"""
	var base: float = pow(yield_kt, 0.41)
	var burn_factor: Dictionary = {1: 2.5, 2: 1.8, 3: 1.2}
	return base * burn_factor.get(burn_degree, 1.0)


## Calculate prompt radiation radius
func calculate_radiation_radius(yield_kt: float, dose_sv: float = 4.0) -> float:
	"""
	Calculate radius for prompt radiation dose.
	dose_sv: Target dose in Sieverts (4 Sv = LD50 in 2 weeks)
	"""
	# Simplified: radiation radius doesn't scale much with yield
	# Because higher yield = less relative radiation output
	var base: float = 1.5 + 0.5 * pow(yield_kt, 0.19)
	return base * (4.0 / dose_sv)


## Calculate casualties for a city
func calculate_casualties(city_population: int, yield_kt: int, 
							distance_from_ground_zero_km: float) -> Dictionary:
	"""
	Estimate casualties based on distance from detonation.
	"""
	var radii: Dictionary = calculate_blast_radius(float(yield_kt))
	
	# Population distribution (simplified)
	# Assume uniform density within city radius
	var city_radius: float = 20.0  # km - typical city radius
	var city_area: float = PI * city_radius * city_radius
	var pop_density: float = float(city_population) / city_area
	
	# Calculate affected areas
	var fireball_pop: float = _population_in_radius(distance_from_ground_zero_km, 
			radii.fireball, pop_density)
	var heavy_pop: float = _population_in_radius(distance_from_ground_zero_km + radii.fireball, 
			radii.heavy_damage, pop_density)
	var moderate_pop: float = _population_in_radius(distance_from_ground_zero_km + radii.heavy_damage, 
			radii.moderate_damage, pop_density)
	var light_pop: float = _population_in_radius(distance_from_ground_zero_km + radii.moderate_damage, 
			radii.light_damage, pop_density)
	
	# Fatality rates
	var fatalities: int = int(fireball_pop * 1.0 + heavy_pop * 0.9 + moderate_pop * 0.5 + light_pop * 0.1)
	var injuries: int = int(moderate_pop * 0.3 + light_pop * 0.5)
	var displaced: int = int(light_pop * 0.8)
	
	return {
		"fatalities": fatalities,
		"injuries": injuries,
		"displaced": displaced,
		"affected_total": fatalities + injuries + displaced
	}


func _population_in_radius(inner_km: float, width_km: float, density: float) -> float:
	"""Calculate population in a ring"""
	var outer_km: float = inner_km + width_km
	var outer_area: float = PI * outer_km * outer_km
	var inner_area: float = PI * inner_km * inner_km
	return density * (outer_area - inner_area)


## Calculate fallout pattern
func calculate_fallout(yield_kt: int, wind_speed_kph: float, wind_direction_deg: float) -> Dictionary:
	"""
	Calculate fallout pattern based on yield and wind.
	Returns approximate pattern dimensions.
	"""
	# Fallout scales with yield
	var stem_radius: float = 0.5 * pow(float(yield_kt), 0.3)
	var cloud_radius: float = 2.0 * pow(float(yield_kt), 0.25)
	
	# Downwind drift depends on time and wind
	var drift_distance: float = wind_speed_kph * 24.0  # 24 hours of drift
	
	# Pattern extends downwind
	var pattern_length: float = stem_radius + drift_distance * 0.3
	var pattern_width: float = cloud_radius * 2.0
	
	return {
		"stem_radius_km": stem_radius,
		"cloud_radius_km": cloud_radius,
		"pattern_length_km": pattern_length,
		"pattern_width_km": pattern_width,
		"wind_direction_deg": wind_direction_deg,
		"dangerous_fallout_time_hours": 48.0
	}


## Estimate yield from detection data
func estimate_yield(detection_data: Dictionary) -> int:
	"""
	Estimate warhead yield from satellite detection.
	Uses brightness, duration, and altitude data.
	"""
	# Real yield estimation uses multiple factors
	# Simplified: return estimated yield in kt
	
	var estimated: int = 500  # Default estimate
	
	# If we have altitude data, use it
	var altitude: float = detection_data.get("altitude_km", 0.0)
	if altitude > 0:
		# Higher altitude detonation = likely air burst = smaller yield
		# Ground burst = larger yield expected
		estimated = int(500 * (1.0 + (100.0 - altitude) / 200.0))
	
	# If we have brightness, refine estimate
	var brightness: float = detection_data.get("brightness", 1.0)
	estimated = int(estimated * brightness)
	
	return clamp(estimated, 10, 50000)  # 10kt to 50Mt


## Get yield category for display
func get_yield_category(yield_kt: int) -> Dictionary:
	"""Categorize yield for UI display"""
	if yield_kt < 20:
		return {"category": "Tactical", "color": "yellow", "icon": "💥"}
	elif yield_kt < 150:
		return {"category": "Strategic", "color": "orange", "icon": "🔥"}
	elif yield_kt < 1000:
		return {"category": "Major", "color": "red", "icon": "☢️"}
	else:
		return {"category": "Megaton", "color": "purple", "icon": "💀"}