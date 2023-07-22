extends CharacterBody3D


@export var speed = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var pivot = $pivot



func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_pressed("look_down"):
		pivot.rotation.x += deg_to_rad(-1)
	elif Input.is_action_pressed("look_up"):
		pivot.rotation.x += deg_to_rad(1)
	var z = 0
	if Input.is_action_pressed("forward"):
		z = -1
	elif Input.is_action_pressed("backward"):
		z = 1
	if Input.is_action_pressed("turn_left"):
		rotation.y += deg_to_rad(1)
	elif Input.is_action_pressed("turn_right"):
		rotation.y += deg_to_rad(-1)
	var direction = (transform.basis * Vector3(0, 0, z)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
