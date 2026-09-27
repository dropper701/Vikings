extends CharacterBody3D
@export var mouse_sensitivity= 0.003
@onready var camera_rig= $CameraRig

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 9.8

func _ready():
	Input.mouse_mode= Input.MOUSE_MODE_CAPTURED
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)	
		camera_rig.rotation.x -= event.relative.y * mouse_sensitivity
		camera_rig.rotation.x = clamp(camera_rig.rotation.x, -1.0, 1.0)
	

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Movement
	var input = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)

	var direction = Vector3(input.x, 0, input.y).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		rotation.y= lerp_angle(rotation.y, atan2(direction.x, direction.z), 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	
