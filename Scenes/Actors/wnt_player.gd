extends CharacterBody3D

@export var move_speed : float = 7.5
@export var acceleration: float = 8.0
@export var deceleration: float = 15.0

@onready var player_sprite: Sprite3D = $"Sprite"
@onready var camera_pivot: Node3D = $CameraPivot
@onready var trigger_area: Area3D = $TriggerArea
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

const LEOMIN = preload("res://Scenes/Actors/leomin.tscn")

var camera_angle: float = -180
var controlled_leomin: Array[Leomin] = [] 
var held_leomin: Leomin = null
var can_move: bool = true

func _physics_process(delta: float) -> void:
	# gravity
	velocity.y -= gravity * delta
	
	# Get Input
	var move_input : Vector2 = Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	var move_direction : Vector3 = Vector3(move_input.x, 0, move_input.y)
	
	if move_input.length() > 0:
		velocity.x = lerpf(velocity.x, move_direction.x * move_speed, acceleration * delta)
		velocity.z = lerpf(velocity.z, move_direction.z * move_speed, acceleration * delta)
	else:
		# Decelerate
		velocity.x = lerpf(velocity.x, 0, deceleration * delta)
		velocity.z = lerpf(velocity.z, 0, deceleration * delta)
		
	if velocity.x < 0:
		player_sprite.flip_h = false
	elif velocity.x > 0:
		player_sprite.flip_h = true
	else:
		pass
		
	if can_move:
		move_and_slide()

func _on_leomin_touch_area_area_entered(area: Area3D):
	print("HWEY")
	if area.get_parent().is_in_group("Interactables"):
		if Dialogic.current_timeline != null:
			return
		Dialogic.start('timeline')
		pass
