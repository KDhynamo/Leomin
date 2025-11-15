extends CharacterBody3D

@export var move_speed : float = 7.5
@export var reticule_move_speed : float = 20.0
@export var jump_force : float = 10.0
@export var reticule_distance: float = 5.0
@export var acceleration: float = 8.0
@export var deceleration: float = 15.0

@onready var character_model: MeshInstance3D = $"Character Model"
@onready var camera_pivot: Node3D = $CameraPivot
@onready var target_reticule: Decal = $"Target Reticule"
@onready var throw_marker: Marker3D = $"Character Model/ThrowMarker"
@onready var touch_area: Area3D = $LeominTouchArea
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

const LEOMIN = preload("res://Scenes/Actors/leomin.tscn")

var camera_angle: float = -180
var controlled_leomin: Array[Leomin] = [] 
var held_leomin: Leomin = null
var can_move: bool = true

func _physics_process(delta: float) -> void:
	# gravity
	velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	if Input.is_action_just_released("jump") and not is_on_floor():
		if velocity.y > 0:
			velocity.y = 0
	
	# Get Input
	var move_input : Vector2 = Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	var move_direction : Vector3 = Vector3(move_input.x, 0, move_input.y)
	
	# Adjust for camera position
	move_direction = move_direction.rotated(Vector3.UP, camera_pivot.rotation.y + PI)
	
	var player_move_direction : Vector3 = (target_reticule.global_position - global_position).normalized() * move_direction.length()
	
	target_reticule.position = target_reticule.position.limit_length(reticule_distance)
	target_reticule.position.x += move_direction.x * reticule_move_speed * delta
	target_reticule.position.z += move_direction.z * reticule_move_speed * delta
	
	var distance_to_reticule = global_position.distance_to(target_reticule.global_position)
	if distance_to_reticule >= reticule_distance and move_input.length() > 0:
		move_direction = move_direction.rotated(Vector3.UP, camera_pivot.rotation.y + PI)
		velocity.x = lerpf(velocity.x, player_move_direction.x * move_speed, acceleration * delta)
		velocity.z = lerpf(velocity.z, player_move_direction.z * move_speed, acceleration * delta)
	elif move_input.length() > 0:
		velocity.x = lerpf(velocity.x, -move_direction.x * move_speed/2, acceleration * delta)
		velocity.z = lerpf(velocity.z, -move_direction.z * move_speed/2, acceleration * delta)
		
	else:
		# Decelerate
		velocity.x = lerpf(velocity.x, 0, deceleration * delta)
		velocity.z = lerpf(velocity.z, 0, deceleration * delta)
		
	if Input.is_action_just_pressed("throw"):
		held_leomin = LEOMIN.instantiate()
		throw_marker.add_child(held_leomin)
		held_leomin.collision.disabled = true
		held_leomin.set_physics_process(false)
		
	if Input.is_action_just_released("throw"):
		throw_leomin(distance_to_reticule)
	
	if can_move:
		move_and_slide()

func throw_leomin(distance_to_reticule: float):
	var throw_vector = held_leomin.calculate_throwing_vector(distance_to_reticule, throw_marker.position.y, character_model.rotation.y, velocity)
	held_leomin.reparent(get_tree().current_scene)
	held_leomin.position = Vector3(position.x, held_leomin.position.y, position.z)
	held_leomin.throw(throw_vector)
	held_leomin.collision.disabled = false
	held_leomin.set_physics_process(true)

func _on_leomin_touch_area_area_entered(area: Area3D):
	if area.get_parent().name == "LeoSign":
		print("hey!")
		if Dialogic.current_timeline != null:
			return
		Dialogic.start('timeline')
		pass
