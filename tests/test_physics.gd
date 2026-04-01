## test_physics.gd
## Unit tests for ballistic physics system
## Run from command line: godot --headless --script res://tests/test_physics.gd

extends SceneTree

var Ballistics: RefCounted


func _init() -> void:
	print("=== Ballistic Physics Tests ===")
	print("")
	
	# Load the physics system
	Ballistics = load("res://scripts/systems/ballistic_physics.gd").new()
	
	# Run tests
	test_great_circle_distance()
	test_initial_bearing()
	test_intermediate_point()
	test_altitude_calculation()
	test_flight_time()
	test_position_at_time()
	test_intercept_probability()
	
	print("")
	print("=== All Tests Complete ===")
	quit()


func test_great_circle_distance() -> void:
	print("Testing: great_circle_distance")
	
	# Los Angeles to New York
	var dist: float = Ballistics.great_circle_distance(34.05, -118.24, 40.71, -74.00)
	assert(abs(dist - 3935.0) < 50.0, "LA-NY distance should be ~3935 km, got %.0f" % dist)
	print("  LA to NY: %.0f km ✓" % dist)
	
	# London to Moscow
	dist = Ballistics.great_circle_distance(51.50, -0.12, 55.75, 37.62)
	assert(abs(dist - 2500.0) < 50.0, "London-Moscow distance should be ~2500 km")
	print("  London to Moscow: %.0f km ✓" % dist)
	
	# North Korea to Washington DC
	dist = Ballistics.great_circle_distance(39.04, 125.76, 38.91, -77.04)
	assert(dist > 10000.0, "NK-Washington should be >10000 km")
	print("  NK to Washington: %.0f km ✓" % dist)
	
	print("  PASS\n")


func test_initial_bearing() -> void:
	print("Testing: initial_bearing")
	
	var bearing: float = Ballistics.initial_bearing(34.05, -118.24, 40.71, -74.00)
	assert(bearing > 45.0 and bearing < 90.0, "LA-NY bearing should be ~60 degrees")
	print("  LA to NY bearing: %.1f° ✓" % bearing)
	
	print("  PASS\n")


func test_intermediate_point() -> void:
	print("Testing: intermediate_point")
	
	var midpoint: Dictionary = Ballistics.intermediate_point(34.05, -118.24, 40.71, -74.00, 0.5)
	print("  LA-NY midpoint: lat %.2f, lon %.2f" % [midpoint.lat, midpoint.lon])
	
	# Midpoint should be roughly in Kansas/Nebraska area
	assert(midpoint.lat > 35.0 and midpoint.lat < 45.0, "Midpoint latitude should be ~40")
	assert(midpoint.lon > -100.0 and midpoint.lon < -95.0, "Midpoint longitude should be ~-97")
	print("  PASS\n")


func test_altitude_calculation() -> void:
	print("Testing: altitude_at_fraction")
	
	# Test boost phase (should be climbing)
	var alt: float = Ballistics.altitude_at_fraction(0.1, 1200.0, 10000.0)
	print("  Altitude at 10%%: %.0f km" % alt)
	assert(alt > 0 and alt < 400, "Boost altitude should be >0 and <400")
	
	# Test peak (should be near max)
	alt = Ballistics.altitude_at_fraction(0.5, 1200.0, 10000.0)
	print("  Altitude at 50%%: %.0f km" % alt)
	assert(alt > 800, "Peak altitude should be >800 km")
	
	# Test terminal (should be descending)
	alt = Ballistics.altitude_at_fraction(0.9, 1200.0, 10000.0)
	print("  Altitude at 90%%: %.0f km" % alt)
	assert(alt < 500, "Terminal altitude should be <500 km")
	
	print("  PASS\n")


func test_flight_time() -> void:
	print("Testing: calculate_flight_time")
	
	# LA to NY
	var time: float = Ballistics.calculate_flight_time(3935.0, "ICBM")
	print("  LA-NY flight time: %.0f seconds (%.1f minutes)" % [time, time/60.0])
	assert(time > 600 and time < 1800, "ICBM flight time should be 10-30 minutes")
	
	# Short range (SRBM)
	time = Ballistics.calculate_flight_time(500.0, "SRBM")
	print("  SRBM 500km flight time: %.0f seconds (%.1f minutes)" % [time, time/60.0])
	assert(time < 600, "SRBM flight time should be <10 minutes")
	
	print("  PASS\n")


func test_position_at_time() -> void:
	print("Testing: position_at_time")
	
	# Launch from NK to Washington
	var origin_lat: float = 39.04
	var origin_lon: float = 125.76
	var target_lat: float = 38.91
	var target_lon: float = -77.04
	var total_time: float = 1800.0  # 30 minutes
	
	# Check position at various times
	var pos: Dictionary = Ballistics.position_at_time(origin_lat, origin_lon, target_lat, target_lon, 0, total_time, "ICBM")
	print("  At launch: lat %.2f, lon %.2f, alt %.0f km" % [pos.lat, pos.lon, pos.altitude_km])
	assert(pos.phase == "boost", "Should be in boost phase")
	
	pos = Ballistics.position_at_time(origin_lat, origin_lon, target_lat, target_lon, 900, total_time, "ICBM")
	print("  At 50%%: lat %.2f, lon %.2f, alt %.0f km" % [pos.lat, pos.lon, pos.altitude_km])
	assert(pos.phase == "midcourse", "Should be in midcourse phase")
	
	pos = Ballistics.position_at_time(origin_lat, origin_lon, target_lat, target_lon, 1700, total_time, "ICBM")
	print("  At 94%%: lat %.2f, lon %.2f, alt %.0f km" % [pos.lat, pos.lon, pos.altitude_km])
	assert(pos.phase == "terminal", "Should be in terminal phase")
	
	print("  PASS\n")


func test_intercept_probability() -> void:
	print("Testing: intercept_probability")
	
	# GBI in midcourse (best chance)
	var prob: float = Ballistics.intercept_probability("midcourse", "GBI", 5000.0)
	print("  GBI midcourse: %.0f%%" % [prob * 100])
	assert(prob > 0.5, "GBI midcourse should be >50%")
	
	# GBI in boost (harder)
	prob = Ballistics.intercept_probability("boost", "GBI", 5000.0)
	print("  GBI boost: %.0f%%" % [prob * 100])
	assert(prob < 0.4, "GBI boost should be <40%")
	
	# THAAD in terminal
	prob = Ballistics.intercept_probability("terminal", "THAAD", 100.0)
	print("  THAAD terminal: %.0f%%" % [prob * 100])
	assert(prob > 0.3, "THAAD terminal should be >30%")
	
	# Patriot at range limit
	prob = Ballistics.intercept_probability("terminal", "Patriot", 100.0)
	print("  Patriot at 100km: %.0f%%" % [prob * 100])
	assert(prob < 0.4, "Patriot at range limit should be <40%")
	
	print("  PASS\n")