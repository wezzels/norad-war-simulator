## campaign_manager.gd
## Manages campaign progression, missions, and unlocks
## Handles story progression and player advancement

extends Node


# Signals
signal mission_started(mission: Dictionary)
signal mission_completed(mission: Dictionary, success: bool)
signal tech_unlocked(tech_id: String)
signal campaign_completed()

# Campaign data
var campaign_data: Dictionary = {}
var current_mission: int = 0
var unlocked_techs: Array[String] = []
var completed_missions: Array[int] = []

# Tech tree
const TECH_TREE: Dictionary = {
	"interceptor_gbi_2": {
		"name": "GBI Block II",
		"description": "Improved Ground-Based Interceptor",
		"cost": 3,
		"unlocks": ["interceptor_gbi_3"],
		"effects": {"gbi_success": 0.1}
	},
	"interceptor_gbi_3": {
		"name": "GBI Block III",
		"description": "Advanced GBI with multiple kill vehicles",
		"cost": 5,
		"unlocks": [],
		"effects": {"gbi_success": 0.15}
	},
	"interceptor_thaad_2": {
		"name": "THAAD ER",
		"description": "Extended Range THAAD",
		"cost": 2,
		"unlocks": ["interceptor_thaad_3"],
		"effects": {"thaad_range": 50}
	},
	"interceptor_thaad_3": {
		"name": "THAAD Block II",
		"description": "Next-gen THAAD",
		"cost": 4,
		"unlocks": [],
		"effects": {"thaad_success": 0.1}
	},
	"satellite_sbirs_2": {
		"name": "SBIRS Block II",
		"description": "Enhanced missile detection",
		"cost": 3,
		"unlocks": ["satellite_sbirs_3"],
		"effects": {"detection_speed": 0.2}
	},
	"satellite_sbirs_3": {
		"name": "SBIRS-GEO 3",
		"description": "Global persistent coverage",
		"cost": 5,
		"unlocks": [],
		"effects": {"detection_accuracy": 0.1}
	},
	"defense_patriot_pac3": {
		"name": "PAC-3 MSE",
		"description": "Improved Patriot",
		"cost": 2,
		"unlocks": [],
		"effects": {"patriot_success": 0.1}
	}
}

# Campaign missions
const MISSIONS: Array[Dictionary] = [
	{
		"id": "mission_01",
		"name": "First Alert",
		"description": "A single missile launch detected. Learn the basics of NORAD defense.",
		"scenario": "tutorial",
		"unlocks": ["interceptor_thaad_2"],
		"tech_points": 1,
		"briefing": "Welcome to NORAD. A hostile launch has been detected. This is a training exercise, but treat it as real."
	},
	{
		"id": "mission_02",
		"name": "Testing the Shield",
		"description": "Three missiles incoming. Your first real test.",
		"scenario": "first_alert",
		"unlocks": ["satellite_sbirs_2"],
		"tech_points": 2,
		"briefing": "Multiple launches detected. This is not a drill. Defend the homeland."
	},
	{
		"id": "mission_03",
		"name": "Rising Tensions",
		"description": "Escalating threats from multiple vectors.",
		"scenario": "rising_tensions",
		"unlocks": ["interceptor_gbi_2"],
		"tech_points": 2,
		"briefing": "The situation is deteriorating. Multiple launch sites are active."
	},
	{
		"id": "mission_04",
		"name": "Cuban Crisis",
		"description": "Historical recreation of the 1962 crisis.",
		"scenario": "cuban_crisis",
		"unlocks": ["interceptor_patriot_pac3"],
		"tech_points": 3,
		"briefing": "Soviet missiles have been discovered in Cuba. We must neutralize them."
	},
	{
		"id": "mission_05",
		"name": "Korean Standoff",
		"description": "Tensions on the Korean peninsula.",
		"scenario": "korean_standoff",
		"unlocks": ["interceptor_thaad_3"],
		"tech_points": 3,
		"briefing": "North Korea has launched a limited strike. We must intercept every missile."
	},
	{
		"id": "mission_06",
		"name": "Defense of the Realm",
		"description": "Protect critical infrastructure.",
		"scenario": "rising_tensions",
		"unlocks": ["interceptor_gbi_3"],
		"tech_points": 4,
		"briefing": "Critical military and civilian targets have been identified. Failure is not an option."
	},
	{
		"id": "mission_07",
		"name": "Satellite Down",
		"description": "Enemy anti-satellite weapons deployed.",
		"scenario": "rising_tensions",
		"unlocks": ["satellite_sbirs_3"],
		"tech_points": 4,
		"briefing": "Our satellites are being targeted. Rely on backup systems."
	},
	{
		"id": "mission_08",
		"name": "Total War",
		"description": "Full-scale nuclear exchange.",
		"scenario": "ww3",
		"unlocks": [],
		"tech_points": 5,
		"briefing": "This is it. Total war. Defend everything."
	}
]

# Save path
const CAMPAIGN_SAVE: String = "user://campaign_save.json"


func _ready() -> void:
	load_campaign()


func load_campaign() -> bool:
	"""Load campaign progress"""
	var file: FileAccess = FileAccess.open(CAMPAIGN_SAVE, FileAccess.READ)
	if not file:
		# New campaign
		campaign_data = {
			"current_mission": 0,
			"completed_missions": [],
			"unlocked_techs": [],
			"tech_points": 0
		}
		return false
	
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	
	campaign_data = json.data
	current_mission = campaign_data.get("current_mission", 0)
	completed_missions = campaign_data.get("completed_missions", [])
	unlocked_techs = campaign_data.get("unlocked_techs", [])
	
	return true


func save_campaign() -> bool:
	"""Save campaign progress"""
	campaign_data.current_mission = current_mission
	campaign_data.completed_missions = completed_missions
	campaign_data.unlocked_techs = unlocked_techs
	
	var file: FileAccess = FileAccess.open(CAMPAIGN_SAVE, FileAccess.WRITE)
	if not file:
		return false
	
	file.store_string(JSON.stringify(campaign_data, "  "))
	return true


func get_current_mission() -> Dictionary:
	"""Get the current mission data"""
	if current_mission >= MISSIONS.size():
		return {}
	
	return MISSIONS[current_mission]


func get_mission(index: int) -> Dictionary:
	"""Get mission by index"""
	if index < 0 or index >= MISSIONS.size():
		return {}
	
	return MISSIONS[index]


func start_mission(index: int) -> bool:
	"""Start a mission"""
	if index < 0 or index >= MISSIONS.size():
		return false
	
	# Check if unlocked
	if index > 0 and index not in completed_missions and index != current_mission:
		return false
	
	current_mission = index
	mission_started.emit(MISSIONS[index])
	
	return true


func complete_mission(success: bool) -> void:
	"""Complete current mission"""
	if current_mission >= MISSIONS.size():
		return
	
	var mission: Dictionary = MISSIONS[current_mission]
	
	if success:
		# Add to completed
		if current_mission not in completed_missions:
			completed_missions.append(current_mission)
		
		# Award tech points
		campaign_data.tech_points = campaign_data.get("tech_points", 0) + mission.get("tech_points", 1)
		
		# Unlock techs
		for tech_id: String in mission.get("unlocks", []):
			if tech_id not in unlocked_techs:
				unlocked_techs.append(tech_id)
				tech_unlocked.emit(tech_id)
		
		# Advance to next mission
		if current_mission + 1 < MISSIONS.size():
			current_mission += 1
		else:
			# Campaign complete!
			campaign_completed.emit()
	
	mission_completed.emit(mission, success)
	save_campaign()


func is_campaign_complete() -> bool:
	"""Check if campaign is completed"""
	return completed_missions.size() >= MISSIONS.size()


func get_final_stats() -> Dictionary:
	"""Get final campaign statistics"""
	return {
		"missions_completed": completed_missions.size(),
		"total_missions": MISSIONS.size(),
		"tech_points": campaign_data.get("tech_points", 0),
		"techs_unlocked": unlocked_techs.size(),
		"playtime_seconds": Statistics.stats.get("playtime_seconds", 0),
		"total_intercepted": Statistics.stats.get("total_missiles_intercepted", 0),
		"cities_protected": 23 * completed_missions.size() - Statistics.stats.get("total_cities_hit", 0)
	}


func can_play_mission(index: int) -> bool:
	"""Check if a mission can be played"""
	# First mission is always available
	if index == 0:
		return true
	
	# Completed missions can be replayed
	if index in completed_missions:
		return true
	
	# Current mission is available
	if index == current_mission:
		return true
	
	return false


func unlock_tech(tech_id: String) -> bool:
	"""Unlock a technology"""
	if tech_id not in TECH_TREE:
		return false
	
	var tech: Dictionary = TECH_TREE[tech_id]
	var cost: int = tech.get("cost", 1)
	
	if campaign_data.get("tech_points", 0) < cost:
		return false
	
	# Check prerequisites (unlocks from)
	var prereqs_met: bool = true
	for prereq: String in tech.get("unlocks", []):
		if prereq not in unlocked_techs:
			prereqs_met = false
			break
	
	if not prereqs_met:
		return false
	
	# Deduct cost
	campaign_data.tech_points -= cost
	
	# Unlock
	if tech_id not in unlocked_techs:
		unlocked_techs.append(tech_id)
	
	save_campaign()
	tech_unlocked.emit(tech_id)
	
	return true


func get_available_techs() -> Array[Dictionary]:
	"""Get technologies available for purchase"""
	var available: Array[Dictionary] = []
	
	for tech_id: String in TECH_TREE:
		if tech_id in unlocked_techs:
			continue
		
		var tech: Dictionary = TECH_TREE[tech_id]
		
		# Check if prerequisite is unlocked
		var prereq_met: bool = true
		for parent_tech: String in tech.get("unlocks", []):
			if parent_tech not in unlocked_techs:
				prereq_met = false
				break
		
		if prereq_met:
			available.append({
				"id": tech_id,
				"name": tech.get("name", tech_id),
				"description": tech.get("description", ""),
				"cost": tech.get("cost", 1),
				"effects": tech.get("effects", {})
			})
	
	return available


func get_tech_effects() -> Dictionary:
	"""Get combined effects of all unlocked techs"""
	var effects: Dictionary = {
		"gbi_success": 0.0,
		"thaad_success": 0.0,
		"patriot_success": 0.0,
		"thaad_range": 0.0,
		"detection_speed": 0.0,
		"detection_accuracy": 0.0
	}
	
	for tech_id: String in unlocked_techs:
		if tech_id not in TECH_TREE:
			continue
		
		var tech_effects: Dictionary = TECH_TREE[tech_id].get("effects", {})
		for effect: String in tech_effects:
			if effects.has(effect):
				effects[effect] += tech_effects[effect]
	
	return effects


func reset_campaign() -> void:
	"""Reset campaign progress"""
	campaign_data = {
		"current_mission": 0,
		"completed_missions": [],
		"unlocked_techs": [],
		"tech_points": 0
	}
	
	current_mission = 0
	completed_missions.clear()
	unlocked_techs.clear()
	
	save_campaign()


func get_progress() -> Dictionary:
	"""Get campaign progress"""
	return {
		"current_mission": current_mission,
		"total_missions": MISSIONS.size(),
		"completed": completed_missions.size(),
		"tech_points": campaign_data.get("tech_points", 0),
		"unlocked_techs": unlocked_techs.size()
	}