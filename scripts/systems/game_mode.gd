## game_mode.gd
## Game mode manager for Co-op and Versus modes
## Handles mode-specific rules, scoring, and victory conditions

extends Node

# Signals
signal mode_changed(mode: int)
signal team_scored(team: int, points: int)
signal game_over(winner: int, reason: String)

# Mode constants
const COOP: int = 0
const VERSUS: int = 1

# Victory conditions
const ALL_THREATS_NEUTRALIZED: int = 0  # Co-op: Stop all missiles
const SURVIVAL_TIME: int = 1            # Co-op: Survive for X minutes
const OPPONENT_ELIMINATED: int = 2       # Versus: Destroy opponent's cities
const POINT_LIMIT: int = 3               # Versus: First to X points
const TIME_LIMIT: int = 4                # Versus: Most points when time runs out

# Current mode
var current_mode: int = COOP
var current_victory: int = ALL_THREATS_NEUTRALIZED

# Teams (Versus mode)
var team_scores: Dictionary = {1: 0, 2: 0}
var team_cities: Dictionary = {1: [], 2: []}  # Assigned cities to protect
var team_interceptors: Dictionary = {1: {}, 2: {}}  # Available interceptors

# Game settings
var time_limit: float = 0.0  # 0 = no limit
var score_limit: int = 0     # 0 = no limit
var survival_time: float = 0.0  # Minutes to survive
var game_started: bool = false
var game_time: float = 0.0

# Co-op settings
var coop_missile_multiplier: float = 1.0
var coop_interceptor_bonus: float = 1.5  # More interceptors in co-op

# Versus settings
var versus_starting_interceptors: Dictionary = {
	"GBI": 30,
	"THAAD": 20,
	"Patriot": 40
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _process(delta: float) -> void:
	if not game_started:
		return
	
	game_time += delta
	
	# Check victory conditions
	_check_victory_conditions()


# === MODE SETUP ===

func setup_coop(settings: Dictionary = {}) -> void:
	"""Setup cooperative mode"""
	current_mode = COOP
	current_victory = settings.get("victory", ALL_THREATS_NEUTRALIZED)
	
	# Apply settings
	coop_missile_multiplier = settings.get("missile_multiplier", 1.0)
	coop_interceptor_bonus = settings.get("interceptor_bonus", 1.5)
	survival_time = settings.get("survival_time", 0.0) * 60.0  # Convert to seconds
	
	# All players on team 1
	_assign_all_players_to_team(1)
	
	# Setup shared interceptor pool
	_setup_shared_interceptors(settings)
	
	mode_changed.emit(current_mode)


func setup_versus(settings: Dictionary = {}) -> void:
	"""Setup versus mode"""
	current_mode = VERSUS
	current_victory = settings.get("victory", POINT_LIMIT)
	
	# Apply settings
	time_limit = settings.get("time_limit", 0.0) * 60.0  # Convert to seconds
	score_limit = settings.get("score_limit", 100)
	
	# Assign teams
	_assign_teams_to_players()
	
	# Assign cities to teams
	_assign_cities_to_teams(settings.get("cities_per_team", 12))
	
	# Setup team interceptors
	_setup_team_interceptors()
	
	# Reset scores
	team_scores = {1: 0, 2: 0}
	
	mode_changed.emit(current_mode)


func start_game() -> void:
	"""Start the game"""
	game_started = true
	game_time = 0.0


func end_game() -> void:
	"""End the game"""
	game_started = false


# === TEAM ASSIGNMENT ===

func _assign_all_players_to_team(team: int) -> void:
	"""Assign all players to same team (co-op)"""
	for player_id: int in NetworkManager.players:
		NetworkManager.players[player_id].team = team


func _assign_teams_to_players() -> void:
	"""Assign players to teams (versus)"""
	var team1_count: int = 0
	var team2_count: int = 0
	
	for player_id: int in NetworkManager.players:
		# Alternate teams
		if team1_count <= team2_count:
			NetworkManager.players[player_id].team = 1
			team1_count += 1
		else:
			NetworkManager.players[player_id].team = 2
			team2_count += 1
	
	# Broadcast team assignments
	if NetworkManager.is_host:
		NetworkManager.rpc("receive_lobby_state", NetworkManager._get_player_list())


func _assign_cities_to_teams(cities_per_team: int) -> void:
	"""Assign cities to teams for protection"""
	var cities: Array = _load_cities()
	
	# Shuffle cities
	cities.shuffle()
	
	# Split cities between teams
	team_cities[1] = cities.slice(0, cities_per_team)
	team_cities[2] = cities.slice(cities_per_team, cities_per_team * 2)


func _setup_shared_interceptors(settings: Dictionary) -> void:
	"""Setup shared interceptor pool for co-op"""
	var base_interceptors: Dictionary = {
		"GBI": settings.get("gbi", 44),
		"THAAD": settings.get("thaad", 30),
		"Patriot": settings.get("patriot", 50)
	}
	
	# Apply bonus multiplier
	for interceptor_type: String in base_interceptors:
		base_interceptors[interceptor_type] = int(base_interceptors[interceptor_type] * coop_interceptor_bonus)
	
	DefenseManager.inventory = {
		"GBI": {"total": base_interceptors.GBI, "available": base_interceptors.GBI},
		"THAAD": {"total": base_interceptors.THAAD, "available": base_interceptors.THAAD},
		"Patriot": {"total": base_interceptors.Patriot, "available": base_interceptors.Patriot}
	}


func _setup_team_interceptors() -> void:
	"""Setup separate interceptor pools for each team (versus)"""
	for team: int in [1, 2]:
		team_interceptors[team] = {
			"GBI": versus_starting_interceptors.GBI,
			"THAAD": versus_starting_interceptors.THAAD,
			"Patriot": versus_starting_interceptors.Patriot
		}


# === SCORING ===

func award_points(team: int, points: int, reason: String) -> void:
	"""Award points to a team"""
	if current_mode == COOP:
		# In co-op, everyone gets points
		team_scores[1] += points
		team_scored.emit(1, points)
	else:
		team_scores[team] += points
		team_scored.emit(team, points)
	
	# Check for point limit victory
	if score_limit > 0 and team_scores[team] >= score_limit:
		game_over.emit(team, "Point limit reached")


func on_missile_intercepted(interceptor_team: int = 1) -> void:
	"""Handle successful interception"""
	if current_mode == COOP:
		award_points(1, 10, "Missile intercepted")
	else:
		award_points(interceptor_team, 10, "Missile intercepted")


func on_city_hit(city_name: String, attacking_team: int = 0) -> void:
	"""Handle city being hit"""
	if current_mode == COOP:
		# Deduct points in co-op
		award_points(1, -50, "City hit: %s" % city_name)
	else:
		# Find which team owned the city
		for team: int in team_cities:
			for city: Dictionary in team_cities[team]:
				if city.name == city_name:
					# Attacking team gets points, defending team loses
					award_points(attacking_team, 25, "City hit: %s" % city_name)
					award_points(team, -15, "City lost: %s" % city_name)
					return


func on_missile_launch(launching_team: int = 0) -> void:
	"""Handle missile launch (versus mode)"""
	if current_mode == VERSUS:
		# Track who launched
		pass  # Just tracking, no points for launching


# === VICTORY CONDITIONS ===

func _check_victory_conditions() -> void:
	"""Check if victory conditions are met"""
	match current_victory:
		ALL_THREATS_NEUTRALIZED:
			_check_all_threats_neutralized()
		SURVIVAL_TIME:
			_check_survival_time()
		TIME_LIMIT:
			_check_time_limit()
		POINT_LIMIT:
			# Handled in award_points
			pass


func _check_all_threats_neutralized() -> void:
	"""Check if all threats are neutralized (co-op)"""
	if game_started and GameState.missiles.is_empty() and GameState.stats.threats_active == 0:
		# All missiles intercepted or scenario complete
		var total_intercepted: int = GameState.stats.missiles_intercepted
		var total_launched: int = GameState.stats.missiles_launched
		
		if total_intercepted == total_launched and total_launched > 0:
			game_over.emit(1, "All threats neutralized!")
			end_game()


func _check_survival_time() -> void:
	"""Check if survival time reached (co-op)"""
	if survival_time > 0 and game_time >= survival_time:
		game_over.emit(1, "Survived! Time: %.1f minutes" % (survival_time / 60.0))
		end_game()


func _check_time_limit() -> void:
	"""Check if time limit reached (versus)"""
	if time_limit > 0 and game_time >= time_limit:
		# Determine winner by score
		if team_scores[1] > team_scores[2]:
			game_over.emit(1, "Time's up! Team Alpha wins!")
		elif team_scores[2] > team_scores[1]:
			game_over.emit(2, "Time's up! Team Bravo wins!")
		else:
			game_over.emit(0, "Time's up! It's a draw!")
		end_game()


func _check_cities_eliminated() -> void:
	"""Check if a team's cities are eliminated (versus)"""
	for team: int in team_cities:
		var remaining: int = team_cities[team].size()
		if remaining == 0:
			var winner: int = 2 if team == 1 else 1
			var winner_name: String = "Team Alpha" if winner == 1 else "Team Bravo"
			game_over.emit(winner, "%s eliminated Team %s!" % [winner_name, "Alpha" if team == 1 else "Bravo"])
			end_game()
			return


# === HELPER FUNCTIONS ===

func get_team_for_player(player_id: int) -> int:
	"""Get team for a player"""
	if NetworkManager.players.has(player_id):
		return NetworkManager.players[player_id].team
	return 1


func get_interceptors_for_team(team: int) -> Dictionary:
	"""Get available interceptors for a team"""
	if current_mode == COOP:
		return DefenseManager.inventory
	else:
		return team_interceptors.get(team, {})


func use_interceptor(team: int, interceptor_type: String) -> bool:
	"""Use an interceptor (returns false if none available)"""
	var pool: Dictionary = get_interceptors_for_team(team)
	
	if not pool.has(interceptor_type):
		return false
	
	if pool[interceptor_type].available <= 0:
		return false
	
	pool[interceptor_type].available -= 1
	return true


func restore_interceptor(team: int, interceptor_type: String) -> void:
	"""Restore an interceptor (refund)"""
	var pool: Dictionary = get_interceptors_for_team(team)
	
	if pool.has(interceptor_type):
		pool[interceptor_type].available += 1


func _load_cities() -> Array:
	"""Load cities from data file"""
	var file: FileAccess = FileAccess.open("res://data/cities.json", FileAccess.READ)
	if not file:
		return []
	
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return []
	
	return json.data


func get_mode_name() -> String:
	"""Get name of current mode"""
	if current_mode == COOP:
		return "Co-op"
	elif current_mode == VERSUS:
		return "Versus"
	else:
		return "Unknown"


func get_victory_name() -> String:
	"""Get name of victory condition"""
	match current_victory:
		ALL_THREATS_NEUTRALIZED: return "All Threats Neutralized"
		SURVIVAL_TIME: return "Survival"
		OPPONENT_ELIMINATED: return "Opponent Eliminated"
		POINT_LIMIT: return "Point Limit"
		TIME_LIMIT: return "Time Limit"
		_: return "Unknown"