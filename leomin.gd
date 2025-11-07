class_name Leomin
extends CharacterBody3D

@export var default_speed: float = 7.0
@export var nav_target: Node3D
@export var acceleration: float = 8.0
@export var deceleration: float = 15.0

@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var crowd_detection: Area3D = $CrowdDetection

var path_update_rate: float = 0.1
var last_path_update_time : float

func _physics_process(delta: float) -> void:
	# gravity
	velocity.y -= gravity * delta
	
	if is_on_floor(): 
		if nav_target != null:
			var current_time = Time.get_unix_time_from_system()	
			if current_time - last_path_update_time > path_update_rate:
				last_path_update_time = current_time
				move_to_position(nav_target.position, false)
			
			var target_pos = agent.get_next_path_position()
			var move_dir = position.direction_to(target_pos)
			move_dir.y = 0
			move_dir = move_dir.normalized()
			
			if agent.is_navigation_finished():
				move_dir = Vector3.ZERO
				
			velocity.x = lerpf(velocity.x, move_dir.x * default_speed, acceleration * delta)
			velocity.z = lerpf(velocity.z, move_dir.z * default_speed, acceleration * delta)
		else:
			velocity.x = lerpf(velocity.x, 0, deceleration * delta)
			velocity.z = lerpf(velocity.z, 0, deceleration * delta)
		
		adjust_crowd_distance()
	
	move_and_slide()

func move_to_position(to_position : Vector3, adjust_pos : bool = true):
	if adjust_pos:
		var map = get_world_3d().navigation_map
		var adjusted_pos = NavigationServer3D.map_get_closest_point(map, to_position)
		agent.target_position = adjusted_pos
	else:
		agent.target_position = to_position

func calculate_throwing_vector(distance: float, height_offset: float, facing_angle: float, initial_velocity: Vector3 = Vector3.ZERO, throw_height: float = 10.0, throw_time: float = 2) -> Vector3:
	var vel_y = (throw_height - height_offset)
	var vel_x = distance
	
	var throwing_vector = Vector3(vel_x, vel_y, 0) 
	throwing_vector = throwing_vector.rotated(Vector3.UP, facing_angle + PI/2) + initial_velocity
	print(throwing_vector)
	return throwing_vector
	pass
	
func adjust_crowd_distance() -> void:
	var crowded_vector: Vector3 = Vector3.ZERO
	var crowding_bodies = crowd_detection.get_overlapping_areas()
	
	for c in crowding_bodies:
		var nearest_neighbor_vector = global_position - c.get_parent_node_3d().global_position
		if crowded_vector == Vector3.ZERO:
			crowded_vector = nearest_neighbor_vector
		elif nearest_neighbor_vector.length() < crowded_vector.length():
			crowded_vector = nearest_neighbor_vector
	
	if crowded_vector != Vector3.ZERO:
		velocity += Vector3(crowded_vector.x, velocity.y, crowded_vector.z) * 1.1
	
func throw(throw_vector: Vector3) -> void:
	nav_target = null
	velocity = throw_vector
