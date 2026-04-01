## defense_manager.gd
## Manages interceptor inventory and launches
## Tracks available interceptors and defense sites
## Implements shoot-look-shoot engagement doctrine

extends Node


# Signals
signal interceptor_launched(interceptor: Dictionary)
signal interceptor_depleted(interceptor_type: String)
signal all_defenses_exhausted()
signal engagement_started(missile_id: String)
signal engagement_complete(missile_id: String, success: bool)

# Interceptor inventory
var inventory: Dictionary = {
	"GBI": {"total": 44, "available": 44, "sites": ["Fort Greely", "Vandenberg"]},
	"THAAD": {"total": 100, "available": 100, "sites": ["Alaska", "Guam", "Hawaii", "Korea"]},
	"Patriot": {"total": 200, "available": 200, "sites": ["Global"]}
}

# Defense sites (lat/lon positions)
const DEFENSE_SITES: Dictionary = {
	"Fort Greely": {"lat": 63.9, "lon": -145.7, "type": "GBI"},
	"Vandenberg": {"lat": 34.7, "lon": -120.6, "type": "GBI"},
	"Alaska": {"lat": 64.0, "lon": -165.0, "type": "THAAD"},
	"Guam": {"lat": 13.4, "lon": 144.8, "type": "THAAD"},
	"Hawaii": {"lat": 21.3, "lon": -157.8, "type": "THAAD"},
	"Korea": {"lat": 35.9, "lon": 127.8, "type": "THAAD"}
}

# Active interceptors
var active_interceptors: Array[Node] = []

# Engagement queue (missiles prioritized for intercept)
var engagement_queue: Array[Dictionary] = []

# Interceptor scene
const InterceptorScene: PackedScene = preload("res://scenes/interceptor.tscn")

# Engagement doctrine
enum Doctrine {
	SHOOT_SHOOT_SHOOT,  # Fire all interceptors at once
	SHOOT_LOOK_SHOOT,   # Fire one, check result, fire again
	SHOOT_SHOOT_LOOK    # Fire two, check result, fire again
}
var doctrine: Doctrine = Doctrine.SHOOT_LOOK_SHOOT
var interceptors_per_target: int = 2  # Default number of interceptors per target


# Type-specific stats (mutable copy for runtime modifications)
var TYPE_STATS: Dictionary = {
	"GBI": {"range": 5000.0, "altitude": 2000.0, "speed": 8.0, "success_base": 0.7},
	"THAAD": {"range": 200.0, "altitude": 150.0, "speed": 2.8, "success_base": 0.6},
	"Patriot": {"range": 160.0, "altitude": 24.0, "speed": 1.5, "success_base": 0.5}
}

func _ready() -> void:
	# Connect to game state
	GameState.missile_launched.connect(_on_missile_launched)


func can_intercept(missile: Dictionary, interceptor_type: String = "GBI") -> bool:
	"""Check if we can intercept a missile"""
	# Check inventory
	if not inventory.has(interceptor_type):
		return false
	
	if inventory[interceptor_type].available <= 0:
		return false
	
	# Check range
	var missile_pos: Vector3 = get_missile_position(missile)
	var nearest_site: Dictionary = get_nearest_site(missile_pos, interceptor_type)
	
	if nearest_site.is_empty():
		return false
	
	var distance: float = calculate_distance(nearest_site.position, missile_pos)
	var max_range: float = TYPE_STATS[interceptor_type].range
	
	return distance <= max_range


func launch_interceptor(missile_id: String, interceptor_type: String = "GBI", site_name: String = "") -> bool:
	"""Launch an interceptor at a missile"""
	# Check inventory
	if not inventory.has(interceptor_type):
		push_error("Unknown interceptor type: %s" % interceptor_type)
		return false
	
	if inventory[interceptor_type].available <= 0:
		interceptor_depleted.emit(interceptor_type)
		return false
	
	# Get missile data
	var missile: Dictionary = GameState.get_missile_by_id(missile_id)
	if missile.is_empty():
		push_error("Missile not found: %s" % missile_id)
		return false
	
	# Select site
	if site_name.is_empty():
		var missile_pos: Vector3 = get_missile_position(missile)
		var nearest: Dictionary = get_nearest_site(missile_pos, interceptor_type)
		if nearest.is_empty():
			return false
		site_name = nearest.name
	
	# Get site position
	var site: Dictionary = DEFENSE_SITES.get(site_name, {})
	if site.is_empty():
		push_error("Defense site not found: %s" % site_name)
		return false
	
	# Calculate intercept position
	var missile_pos: Vector3 = get_missile_position(missile)
	var site_pos: Vector3 = lat_lon_to_3d(site.lat, site.lon, 100.0)
	
	# Calculate success chance based on phase
	var success_chance: float = TYPE_STATS[interceptor_type].success_base
	match missile.get("status", "midcourse"):
		"boost":
			success_chance *= 0.5
		"terminal":
			success_chance *= 0.7
		_:
			pass  # midcourse is best
	
	# Decrement inventory
	inventory[interceptor_type].available -= 1
	
	# Create interceptor
	var interceptor: Node3D = InterceptorScene.instantiate()
	get_tree().current_scene.get_node("InterceptorContainer").add_child(interceptor)
	
	# Initialize interceptor
	var intercept_pos: Vector3 = missile_pos  # Would calculate intercept point
	interceptor.initialize(missile_id, site_pos, intercept_pos, success_chance)
	
	# Track
	active_interceptors.append(interceptor)
	
	# Signal
	var interceptor_data: Dictionary = {
		"id": interceptor.interceptor_id,
		"type": interceptor_type,
		"site": site_name,
		"target": missile_id,
		"success_chance": success_chance
	}
	interceptor_launched.emit(interceptor_data)
	
	return true


func auto_intercept() -> void:
	"""Automatically intercept incoming threats"""
	# Get all active missiles
	for missile: Dictionary in GameState.missiles:
		if missile.get("intercepted", false):
			continue
		
		# Try GBI first (best range)
		if can_intercept(missile, "GBI"):
			launch_interceptor(missile.id, "GBI")
			continue
		
		# Try THAAD if in terminal phase
		if missile.get("status") == "terminal" and can_intercept(missile, "THAAD"):
			launch_interceptor(missile.id, "THAAD")
			continue
		
		# Try Patriot for last resort
		if missile.get("status") == "terminal" and can_intercept(missile, "Patriot"):
			launch_interceptor(missile.id, "Patriot")


func get_missile_position(missile: Dictionary) -> Vector3:
	"""Get 3D position of missile"""
	var lat: float = missile.get("lat", 0.0)
	var lon: float = missile.get("lon", 0.0)
	var alt: float = missile.get("altitude", 100.0)
	return lat_lon_to_3d(lat, lon, 100.0 + alt)


func get_nearest_site(position: Vector3, interceptor_type: String) -> Dictionary:
	"""Find nearest defense site for interceptor type"""
	var nearest: Dictionary = {}
	var min_distance: float = INF
	
	for site_name: String in DEFENSE_SITES:
		var site: Dictionary = DEFENSE_SITES[site_name]
		
		if site.type != interceptor_type:
			continue
		
		var site_pos: Vector3 = lat_lon_to_3d(site.lat, site.lon, 100.0)
		var distance: float = position.distance_to(site_pos)
		
		if distance < min_distance:
			min_distance = distance
			nearest = {
				"name": site_name,
				"position": site_pos,
				"distance": distance
			}
	
	return nearest


func calculate_distance(pos1: Vector3, pos2: Vector3) -> float:
	"""Calculate distance between two points on globe"""
	# Simplified: Euclidean distance scaled to km
	return pos1.distance_to(pos2) * 63.71  # Scale factor for Earth radius


func lat_lon_to_3d(lat: float, lon: float, radius: float) -> Vector3:
	"""Convert lat/lon to 3D coordinates"""
	var lat_rad: float = deg_to_rad(lat)
	var lon_rad: float = deg_to_rad(lon)
	
	var x: float = radius * cos(lat_rad) * cos(lon_rad)
	var y: float = radius * sin(lat_rad)
	var z: float = radius * cos(lat_rad) * sin(lon_rad)
	
	return Vector3(x, y, z)


func _on_missile_launched(missile: Dictionary) -> void:
	"""React to new missile launch"""
	# Auto-intercept if enabled
	if Settings.gameplay.get("auto_intercept", false):
		await get_tree().create_timer(1.0).timeout  # Brief delay
		if can_intercept(missile, "GBI"):
			launch_interceptor(missile.id, "GBI")


func get_inventory_status() -> Dictionary:
	"""Get current inventory status"""
	return {
		"GBI": inventory.GBI.available,
		"THAAD": inventory.THAAD.available,
		"Patriot": inventory.Patriot.available
	}


func reset_inventory() -> void:
	"""Reset inventory to initial values"""
	for type: String in inventory:
		inventory[type].available = inventory[type].total


func prioritize_targets() -> Array[Dictionary]:
	"""Prioritize missiles for engagement based on threat level"""
	var threats: Array[Dictionary] = []
	
	for missile: Dictionary in GameState.missiles:
		if missile.get("intercepted", false):
			continue
		
		# Calculate priority score
		var priority: float = 0.0
		
		# Terminal phase = highest priority
		if missile.status == "terminal":
			priority += 100.0
		
		# Progress = closer to impact = higher priority
		priority += missile.progress
		
		# Target importance (would load from cities.json)
		var target: String = missile.get("target", "")
		var target_city: Dictionary = _get_city_data(target)
		if not target_city.is_empty():
			# Higher population = higher priority
			priority += log(target_city.get("population", 1000000)) / 10.0
		
		threats.append({
			"missile": missile,
			"priority": priority,
			"id": missile.id
		})
	
	# Sort by priority (highest first)
	threats.sort_custom(func(a: Dictionary, b: Dictionary): return a.priority > b.priority)
	
	return threats


func engage_missile(missile_id: String, interceptor_type: String = "GBI", count: int = -1) -> bool:
	"""
	Engage a missile with specified number of interceptors.
	If count is -1, use doctrine default.
	"""
	var missile: Dictionary = GameState.get_missile_by_id(missile_id)
	if missile.is_empty():
		push_error("Cannot engage: missile not found %s" % missile_id)
		return false
	
	var interceptors_to_launch: int = count if count > 0 else interceptors_per_target
	var launched: int = 0
	
	# Launch interceptors
	for i: int in range(interceptors_to_launch):
		if launch_interceptor(missile_id, interceptor_type):
			launched += 1
		else:
			break
	
	if launched > 0:
		engagement_started.emit(missile_id)
		return true
	
	return false


func engage_all_threats(max_per_missile: int = 2) -> int:
	"""
	Automatically engage all threats using current doctrine.
	Returns number of missiles engaged.
	"""
	var threats: Array[Dictionary] = prioritize_targets()
	var engaged: int = 0
	
	for threat: Dictionary in threats:
		var missile: Dictionary = threat.missile
		var missile_id: String = threat.id
		
		# Check available interceptors
		if inventory.GBI.available > 0:
			if engage_missile(missile_id, "GBI", max_per_missile):
				engaged += 1
				continue
		
		if inventory.THAAD.available > 0 and missile.status == "terminal":
			if engage_missile(missile_id, "THAAD", max_per_missile):
				engaged += 1
				continue
		
		if inventory.Patriot.available > 0 and missile.status == "terminal":
			if engage_missile(missile_id, "Patriot", max_per_missile):
				engaged += 1
	
	return engaged


func shoot_look_shoot(missile_id: String) -> void:
	"""
	Implement shoot-look-shoot doctrine:
	1. Fire one interceptor
	2. Wait for result
	3. Fire another if needed
	"""
	var missile: Dictionary = GameState.get_missile_by_id(missile_id)
	if missile.is_empty():
		return
	
	# Fire first interceptor
	if launch_interceptor(missile_id, "GBI"):
		# Wait for result (would be handled by interceptor hit signal)
		await get_tree().create_timer(5.0).timeout
		
		# Check if missile still active
		missile = GameState.get_missile_by_id(missile_id)
		if missile.is_empty() or missile.get("intercepted", false):
			engagement_complete.emit(missile_id, true)
			return
		
		# Fire second interceptor
		if launch_interceptor(missile_id, "GBI"):
			await get_tree().create_timer(5.0).timeout
			
			missile = GameState.get_missile_by_id(missile_id)
			if missile.is_empty() or missile.get("intercepted", false):
				engagement_complete.emit(missile_id, true)
				return
			
			# Try THAAD if still active
			if missile.status == "terminal":
				launch_interceptor(missile_id, "THAAD")
		
		engagement_complete.emit(missile_id, false)


func _get_city_data(city_name: String) -> Dictionary:
	"""Get city data from cities.json"""
	var file: FileAccess = FileAccess.open("res://data/cities.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			for city: Dictionary in json.data:
				if city.name == city_name:
					return city
	return {}


func set_doctrine(new_doctrine: Doctrine) -> void:
	"""Set engagement doctrine"""
	doctrine = new_doctrine
	
	match doctrine:
		Doctrine.SHOOT_SHOOT_SHOOT:
			interceptors_per_target = 4
		Doctrine.SHOOT_LOOK_SHOOT:
			interceptors_per_target = 2
		Doctrine.SHOOT_SHOOT_LOOK:
			interceptors_per_target = 3


func get_defense_status() -> Dictionary:
	"""Get comprehensive defense status"""
	return {
		"inventory": {
			"GBI": inventory.GBI.available,
			"THAAD": inventory.THAAD.available,
			"Patriot": inventory.Patriot.available
		},
		"active_interceptors": active_interceptors.size(),
		"engagement_queue": engagement_queue.size(),
		"doctrine": doctrine,
		"interceptors_per_target": interceptors_per_target
	}

func apply_tech_effects(effects: Dictionary) -> void:
	"""Apply tech upgrades to defense systems
	
	Args:
		effects: Dictionary with keys like 'gbi_success', 'thaad_range', etc.
	"""
	# Apply success rate modifiers
	if effects.has("gbi_success"):
		# Increase base success probability
		TYPE_STATS.GBI.success_base += effects.gbi_success
	
	if effects.has("thaad_success"):
		TYPE_STATS.THAAD.success_base += effects.thaad_success
	
	if effects.has("patriot_success"):
		TYPE_STATS.Patriot.success_base += effects.patriot_success
	
	# Apply range modifiers (for future use)
	if effects.has("thaad_range"):
		TYPE_STATS.THAAD.range += effects.thaad_range
	
	# Apply detection modifiers (for future use)
	if effects.has("detection_speed"):
		# Would affect satellite detection speed
		pass
	
	if effects.has("detection_accuracy"):
		# Would affect satellite detection accuracy
		pass
	
	print("Applied tech effects: %s" % str(effects))
