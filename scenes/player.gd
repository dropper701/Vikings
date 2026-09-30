extends CharacterBody3D

@export var mouse_sensitivity: float = 0.003
@onready var camera_rig: SpringArm3D = $CameraRig

const SPEED := 5.0
const JUMP_VELOCITY := 5.0
const GRAVITY := 9.8

func _ready() -> void:
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 camera_rig.add_excluded_object(get_rid())

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
  rotate_y(-event.relative.x * mouse_sensitivity)
  camera_rig.rotation.x = clampf(camera_rig.rotation.x - event.relative.y * mouse_sensitivity, -1.0, 1.0)

func _physics_process(delta: float) -> void:
 if not is_on_floor():
  velocity.y -= GRAVITY * delta
 var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
 # Mouse owns yaw. WASD follows that yaw without rotating the camera.
 var direction := global_basis * Vector3(input.x, 0, input.y)
 velocity.x = direction.x * SPEED
 velocity.z = direction.z * SPEED
 if Input.is_action_just_pressed("jump") and is_on_floor():
  velocity.y = JUMP_VELOCITY
 move_and_slide()
