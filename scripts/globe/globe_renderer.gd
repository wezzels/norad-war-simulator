## globe_renderer.gd
## 3D Globe rendering and management
## Handles Earth sphere, markers, and trajectory visualization

extends Node3D

class_name GlobeRenderer

# Globe mesh
@onready var earth_mesh: MeshInstance3D = $EarthMesh
@onready var atmosphere: MeshInstance3D = $Atmosphere
@onready var clouds: MeshInstance3D = $Clouds

# Markers
var city_markers: Array[Node3D] = []
var launch_site_markers: Array[Node3D] = []
var satellite_markers: Array[Node3D] = []

# Visuals
var trajectory_lines: Array[MeshInstance3D] = []

# Globe radius (arbitrary units)
const GLOBE_RADIUS: float = 100.0
const EARTH_ROTATION_SPEED: float = 0.1  # degrees per second

# Materials
var city_material: StandardMaterial3D
var launch_site_material: StandardMaterial3D
var trajectory_material: StandardMaterial3D


func _ready() -> void:
	setup_materials()
	load_markers()


func setup_materials() -> void:
	# City marker (green)
	city_material = StandardMaterial3D.new()
	city_material.albedo_color = Color(0.0, 1.0, 0.0, 1.0)
	city_material.emission_enabled = true
	city_material.emission = Color(0.0, 0.5, 0.0)
	city_material.emission_energy = 0.5
	
	# Launch site marker (red)
	launch_site_material = StandardMaterial3D.new()
	launch_site_material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	launch_site_material.emission_enabled = true
	launch_site_material.emission = Color(0.5, 0.0, 0.0)
	launch_site_material.emission_energy = 0.5
	
	# Trajectory line (orange)
	trajectory_material = StandardMaterial3D.new()


func load_markers() -> void:
	"""Load city and launch site markers from JSON"""
	# Load cities
	var cities: Array = load_json("res://data/cities.json")
	for city: Dictionary in cities:
		var marker: Node3D = create_city_marker(city)
		add_child(marker)
		city_markers.append(marker)
	
	# Load launch sites
	var sites: Array = load_json("res://data/launch_sites.json")
	for site: Dictionary in sites:
		var marker: Node3D = create_launch_site_marker(site)
		add_child(marker)
		launch_site_markers.append(marker)


func create_city_marker(city: Dictionary) -> Node3D:
	"""Create a 3D marker for a city"""
	var marker: Node3D = Node3D.new()
	
	# Create sphere mesh for marker
	var sphere: MeshInstance3D = MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	sphere.mesh.radius = 0.5
	sphere.mesh.height = 1.0
	sphere.material_override = city_material
	
	marker.add_child(sphere)
	
	# Position on globe
	var pos: Vector3 = lat_lon_to_3d(city.lat, city.lon, GLOBE_RADIUS + 1.0)
	marker.position = pos
	
	# Store metadata
	marker.set_meta("city_name", city.name)
	marker.set_meta("population", city.population)
	marker.set_meta("country", city.country)
	
	return marker


func create_launch_site_marker(site: Dictionary) -> Node3D:
	"""Create a 3D marker for a launch site"""
	var marker: Node3D = Node3D.new()
	
	# Create cone mesh for marker (pointing up)
	var cone: MeshInstance3D = MeshInstance3D.new()
	cone.mesh = CylinderMesh.new()
	cone.mesh.top_radius = 0.0
	cone.mesh.bottom_radius = 1.0
	cone.mesh.height = 2.0
	cone.material_override = launch_site_material
	
	marker.add_child(cone)
	
	# Position on globe
	var pos: Vector3 = lat_lon_to_3d(site.lat, site.lon, GLOBE_RADIUS + 1.5)
	marker.position = pos
	
	# Orient to point away from globe center
	marker.look_at(Vector3.ZERO)
	marker.rotate_x(PI / 2)
	
	# Store metadata
	marker.set_meta("site_name", site.name)
	marker.set_meta("country", site.country)
	
	return marker


func lat_lon_to_3d(lat: float, lon: float, radius: float = GLOBE_RADIUS) -> Vector3:
	"""Convert latitude/longitude to 3D coordinates"""
	var lat_rad: float = deg_to_rad(lat)
	var lon_rad: float = deg_to_rad(lon)
	
	var x: float = radius * cos(lat_rad) * cos(lon_rad)
	var y: float = radius * sin(lat_rad)
	var z: float = radius * cos(lat_rad) * sin(lon_rad)
	
	return Vector3(x, y, z)


func draw_trajectory(origin_lat: float, origin_lon: float, target_lat: float, target_lon: float, color: Color = Color(1.0, 0.5, 0.0)) -> MeshInstance3D:
	"""Draw a trajectory line between two points"""
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	mesh_instance.mesh = immediate_mesh
	
	# Calculate great circle path
	var points: Array[Vector3] = []
	var num_points: int = 50
	for i: int in range(num_points):
		var t: float = float(i) / float(num_points - 1)
		var lat: float = lerp(origin_lat, target_lat, t)
		var lon: float = lerp(origin_lon, target_lon, t)
		
		# Add altitude curve (parabolic)
		var alt: float = 20.0 * sin(PI * t)  # Peak altitude at midpoint
		
		var pos: Vector3 = lat_lon_to_3d(lat, lon, GLOBE_RADIUS + alt)
		points.append(pos)
	
	# Create line mesh
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for point in points:
		immediate_mesh.add_vertex(point)
	immediate_mesh.surface_end()
	
	add_child(mesh_instance)
	trajectory_lines.append(mesh_instance)
	
	return mesh_instance


func clear_trajectories() -> void:
	"""Clear all trajectory lines"""
	for mesh_inst: MeshInstance3D in trajectory_lines:
		mesh_inst.queue_free()
	trajectory_lines.clear()


func highlight_city(city_name: String) -> void:
	"""Highlight a specific city"""
	for marker: Node3D in city_markers:
		if marker.get_meta("city_name") == city_name:
			# Increase size and brightness
			var sphere: MeshInstance3D = marker.get_child(0)
			if sphere:
				sphere.scale = Vector3(1.5, 1.5, 1.5)
				break


func highlight_launch_site(site_name: String) -> void:
	"""Highlight a specific launch site"""
	for marker: Node3D in launch_site_markers:
		if marker.get_meta("site_name") == site_name:
			var cone: MeshInstance3D = marker.get_child(0)
			if cone:
				cone.scale = Vector3(1.5, 1.5, 1.5)
				break


func _process(delta: float) -> void:
	# Slowly rotate globe
	rotation.y += deg_to_rad(EARTH_ROTATION_SPEED * delta)


func load_json(path: String) -> Array:
	"""Load JSON data from file"""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return []
	
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		return []
	
	return json.data