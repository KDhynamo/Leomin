extends MeshInstance3D

@export var rotate_rate : float = 20
var target_y_rotation : float = 0

@onready var character_body: CharacterBody3D = $".."
@onready var target_node: Node3D = null

func _process(delta: float) -> void:
	_smooth_rotation(delta)
	_move_bob(delta)
	pass
	
func _smooth_rotation(delta: float) -> void:
	
	if target_node != null:
		if global_position.distance_to(target_node.global_position) >= 0.1:
			var look_target: Vector3 = -(target_node.global_position - global_position).normalized()
			target_y_rotation = atan2(look_target.x, look_target.z)
	
	rotation.y = lerp_angle(rotation.y, target_y_rotation, rotate_rate * delta)
	
func _move_bob(delta : float) -> void:
	var move_speed = character_body.velocity.length()
	if move_speed < 0.1 or not character_body.is_on_floor():
		scale.y = 1
		return
	
	var time = Time.get_unix_time_from_system()
	var y_scale = 1 + (sin(time * 30) * 0.08)
	scale.y = y_scale
	
