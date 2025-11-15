extends Node3D

@onready var character_model: MeshInstance3D = $"../Character Model"
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D

@export var default_tilt_angle: float = -30
@export var default_high_tilt_angle: float = -60

@export var camera_distances: Array[Array] = [[2.0, 0.5], [5.0, 2.5], [9.0, 2.5]]
var camera_distance_index: int = 1
var target_camera_distance: float = 3.0
var target_camera_height: float = 2.5

var target_angle: float = 0
var tilt_angle: float

var is_high_camera_angle: bool = false

func _ready() -> void:
	tilt_angle = default_tilt_angle
	spring_arm_3d.rotation.x = tilt_angle
	target_angle = rotation.y
	camera_distance_index = 1
	target_camera_distance = camera_distances[camera_distance_index][0]
	target_camera_height = camera_distances[camera_distance_index][1]	

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("reposition_camera"):
		target_angle = character_model.rotation.y + PI
		tilt_angle = default_tilt_angle
		
	if Input.is_action_just_pressed("high_angle_camera"):
		is_high_camera_angle = !is_high_camera_angle
	
	if Input.is_action_just_pressed("toggle_camera_distance"):
		_change_camera_distance()
	
	tilt_angle = default_high_tilt_angle if is_high_camera_angle else default_tilt_angle
	rotation.y = lerp_angle(rotation.y, target_angle, 10 * delta)
	position.y = lerpf(position.y, target_camera_height, 10 * delta)
	
	spring_arm_3d.rotation.x = lerp_angle(spring_arm_3d.rotation.x, deg_to_rad(tilt_angle), 10 * delta)
	spring_arm_3d.spring_length = lerpf(spring_arm_3d.spring_length, target_camera_distance, 10 * delta)

func _change_camera_distance() -> void:
	camera_distance_index += 1
	if camera_distance_index >= len(camera_distances):
		camera_distance_index = 0
		
	target_camera_distance = camera_distances[camera_distance_index][0]
	target_camera_height = camera_distances[camera_distance_index][1]
