## statistics.gd
## Tracks game statistics and achievements
## Records games played, cities saved, intercepts, etc.

extends Node


# Save file path
const STATS_FILE: String = "user://statistics.json"

# Statistics data
var stats: Dictionary = {
	"games_played": 0,
	"games_completed": 0,
	"scenarios_completed": [],
	"total_missiles_intercepted": 0,
	"total_cities_saved": 0,
	"total_cities_hit": 0,
	"total_detonations": 0,
	"best_defcon": 5,
	"interceptors_used": {
		"GBI": 0,
		"THAAD": 0,
		"Patriot": 0
	},
	"playtime_seconds": 0,
	"achievements": [],
	"statistics_by_scenario": {}
}

# Achievements
const ACHIEVEMENTS: Dictionary = {
	"first_intercept": {
		"name": "First Blood",
		"description": "Successfully intercept your first missile",
		"condition": "missiles_intercepted >= 1"
	},
	"ten_intercepts": {
		"name": "Getting Good",
		"description": "Intercept 10 missiles",
		"condition": "missiles_intercepted >= 10"
	},
	"fifty_intercepts": {
		"name": "Iron Dome",
		"description": "Intercept 50 missiles",
		"condition": "missiles_intercepted >= 50"
	},
	"hundred_intercepts": {
		"name": "Sky Shield",
		"description": "Intercept 100 missiles",
		"condition": "missiles_intercepted >= 100"
	},
	"perfect_game": {
		"name": "Perfect Defense",
		"description": "Complete a scenario without losing any cities",
		"condition": "cities_hit == 0 and game_completed"
	},
	"all_scenarios": {
		"name": "War Game Master",
		"description": "Complete all built-in scenarios",
		"condition": "scenarios_completed contains all builtin"
	},
	"defcon_1": {
		"name": "Critical Hour",
		"description": "Reach DEFCON 1",
		"condition": "defcon_reached == 1"
	},
	"playtime_hour": {
		"name": "Dedicated Commander",
		"description": "Play for 1 hour",
		"condition": "playtime_seconds >= 3600"
	}
}


func _ready() -> void:
	load_stats()


func load_stats() -> bool:
	"""Load statistics from file"""
	var file: FileAccess = FileAccess.open(STATS_FILE, FileAccess.READ)
	if not file:
		return false
	
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	
	stats = json.data
	return true


func save_stats() -> bool:
	"""Save statistics to file"""
	var file: FileAccess = FileAccess.open(STATS_FILE, FileAccess.WRITE)
	if not file:
		return false
	
	file.store_string(JSON.stringify(stats, "  "))
	return true


func record_game(scenario_id: String, result: Dictionary) -> void:
	"""Record a completed game"""
	stats.games_played += 1
	
	if result.get("completed", false):
		stats.games_completed += 1
		
		if not stats.scenarios_completed.has(scenario_id):
			stats.scenarios_completed.append(scenario_id)
	
	# Accumulate statistics
	stats.total_missiles_intercepted += result.get("missiles_intercepted", 0)
	stats.total_cities_saved += result.get("cities_saved", 0)
	stats.total_cities_hit += result.get("cities_hit", 0)
	stats.total_detonations += result.get("detonations", 0)
	
	# Track interceptors
	for type: String in result.get("interceptors_used", {}):
		stats.interceptors_used[type] = stats.interceptors_used.get(type, 0) + result.interceptors_used[type]
	
	# Best DEFCON
	var defcon: int = result.get("min_defcon", 5)
	if defcon < stats.best_defcon:
		stats.best_defcon = defcon
	
	# Scenario-specific stats
	if not stats.statistics_by_scenario.has(scenario_id):
		stats.statistics_by_scenario[scenario_id] = {
			"played": 0,
			"completed": 0,
			"best_time": null
		}
	
	stats.statistics_by_scenario[scenario_id].played += 1
	if result.get("completed", false):
		stats.statistics_by_scenario[scenario_id].completed += 1
		
		var time: float = result.get("time_seconds", 0)
		var best: Variant = stats.statistics_by_scenario[scenario_id].best_time
		if best == null or time < best:
			stats.statistics_by_scenario[scenario_id].best_time = time
	
	# Check achievements
	check_achievements(result)
	
	save_stats()


func check_achievements(result: Dictionary) -> void:
	"""Check and unlock achievements"""
	# First intercept
	if result.get("missiles_intercepted", 0) >= 1:
		unlock_achievement("first_intercept")
	
	# Ten intercepts
	if stats.total_missiles_intercepted >= 10:
		unlock_achievement("ten_intercepts")
	
	# Fifty intercepts
	if stats.total_missiles_intercepted >= 50:
		unlock_achievement("fifty_intercepts")
	
	# Hundred intercepts
	if stats.total_missiles_intercepted >= 100:
		unlock_achievement("hundred_intercepts")
	
	# Perfect game
	if result.get("cities_hit", 0) == 0 and result.get("completed", false):
		unlock_achievement("perfect_game")
	
	# DEFCON 1
	if result.get("min_defcon", 5) == 1:
		unlock_achievement("defcon_1")
	
	# Playtime
	if stats.playtime_seconds >= 3600:
		unlock_achievement("playtime_hour")


func unlock_achievement(achievement_id: String) -> void:
	"""Unlock an achievement"""
	if stats.achievements.has(achievement_id):
		return
	
	if not ACHIEVEMENTS.has(achievement_id):
		return
	
	stats.achievements.append(achievement_id)
	print("Achievement unlocked: %s" % ACHIEVEMENTS[achievement_id].name)
	
	# Would show notification in UI


func add_playtime(seconds: float) -> void:
	"""Add to playtime counter"""
	stats.playtime_seconds += seconds


func get_stats() -> Dictionary:
	"""Get current statistics"""
	return stats.duplicate(true)


func get_achievements() -> Array[Dictionary]:
	"""Get all achievements with unlock status"""
	var result: Array[Dictionary] = []
	
	for id: String in ACHIEVEMENTS:
		var achievement: Dictionary = ACHIEVEMENTS[id].duplicate()
		achievement.id = id
		achievement.unlocked = stats.achievements.has(id)
		result.append(achievement)
	
	return result


func get_scenario_stats(scenario_id: String) -> Dictionary:
	"""Get statistics for a specific scenario"""
	return stats.statistics_by_scenario.get(scenario_id, {
		"played": 0,
		"completed": 0,
		"best_time": null
	})


func reset_stats() -> void:
	"""Reset all statistics"""
	stats = {
		"games_played": 0,
		"games_completed": 0,
		"scenarios_completed": [],
		"total_missiles_intercepted": 0,
		"total_cities_saved": 0,
		"total_cities_hit": 0,
		"total_detonations": 0,
		"best_defcon": 5,
		"interceptors_used": {
			"GBI": 0,
			"THAAD": 0,
			"Patriot": 0
		},
		"playtime_seconds": 0,
		"achievements": [],
		"statistics_by_scenario": {}
	}
	save_stats()


func get_summary() -> String:
	"""Get a human-readable summary"""
	var summary: String = "=== Statistics ===\n"
	summary += "Games Played: %d\n" % stats.games_played
	summary += "Games Completed: %d\n" % stats.games_completed
	summary += "Total Intercepts: %d\n" % stats.total_missiles_intercepted
	summary += "Cities Saved: %d\n" % stats.total_cities_saved
	summary += "Cities Hit: %d\n" % stats.total_cities_hit
	summary += "Best DEFCON: %d\n" % stats.best_defcon
	summary += "Playtime: %.1f hours\n" % (stats.playtime_seconds / 3600.0)
	summary += "Achievements: %d/%d\n" % [stats.achievements.size(), ACHIEVEMENTS.size()]
	return summary