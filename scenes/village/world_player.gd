extends "res://demo/src/Player.gd"
## Gameplay movement; the original demo's free-flight controls are not used here.
const GRAVITY := 24.0
const JUMP_VELOCITY := 7.5

func _ready() -> void:
 $CameraManager/Arm.add_excluded_object(get_rid())

func get_camera_relative_input() -> Vector3:
 var direction := Vector3.ZERO
 var camera: Camera3D = $CameraManager/Arm/Camera3D
 if Input.is_key_pressed(KEY_W): direction -= camera.global_basis.z
 if Input.is_key_pressed(KEY_S): direction += camera.global_basis.z
 if Input.is_key_pressed(KEY_A): direction -= camera.global_basis.x
 if Input.is_key_pressed(KEY_D): direction += camera.global_basis.x
 return direction

func _physics_process(delta: float) -> void:
 var direction := get_camera_relative_input()
 direction.y = 0.0
 direction = direction.normalized()
 var speed := MOVE_SPEED * (1.6 if Input.is_physical_key_pressed(KEY_SHIFT) else 1.0)
 velocity.x = direction.x * speed
 velocity.z = direction.z * speed
 if not is_on_floor(): velocity.y -= GRAVITY * delta
 elif velocity.y < 0: velocity.y = 0.0
 # Holding Space cannot add lift or trigger another jump after landing.
 if is_on_floor() and Input.is_action_just_pressed("jump"):
  velocity.y = JUMP_VELOCITY
 move_and_slide()

func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_V:
  first_person = not first_person
