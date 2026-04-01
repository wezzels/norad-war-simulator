## contrail.gd
## Contrail effect for missiles
## Manages trail points and fading

extends MeshInstance3D

# Settings
@export var max_points: int = 100
@export var fade_speed: float = 0.1

# Trail points
var points: Array[Vector3] = []
var point_ages: Array[float] = []

# Mesh
var immediate_mesh: ImmediateMesh


func _ready() -> void:
	# Create immediate mesh
	immediate_mesh = ImmediateMesh.new()
	mesh = immediate_mesh
	clear_points()


func _process(delta: float) -> void:
	# Age existing points
	for i: int in range(point_ages.size()):
		point_ages[i] += delta
	
	# Update mesh
	update_mesh()


func add_point(position: Vector3) -> void:
	"""Add a new point to the trail"""
	points.append(position)
	point_ages.append(0.0)
	
	# Remove old points
	while points.size() > max_points:
		points.pop_front()
		point_ages.pop_front()
	
	update_mesh()


func clear_points() -> void:
	"""Clear all points"""
	points.clear()
	point_ages.clear()
	update_mesh()


func update_mesh() -> void:
	"""Update the mesh from points"""
	if points.size() < 2:
		return
	
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	for i: int in range(points.size()):
		var age: float = point_ages[i] if i < point_ages.size() else 0.0
		var alpha: float = 1.0 - min(age * fade_speed, 1.0)
		immediate_mesh.set_color(Color(1.0, 0.5, 0.0, alpha))
		immediate_mesh.add_vertex(points[i])
	
	immediate_mesh.surface_end()