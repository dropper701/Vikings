extends CharacterBody3D
## Preview-only explorer; the game's existing player controller is unchanged.
const SPEED := 5.0
const SPRINT_SPEED := 9.0
const SPAWN := Vector3(0, 1.3, 13)
var enabled := false
@onready var camera: Camera3D = $Camera3D

func _unhandled_input(event: InputEvent) -> void:
 if not enabled: return
 if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 if event is InputEventMouseButton and event.pressed:
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
  rotation.y -= event.relative.x * 0.0025
  camera.rotation.x = clampf(camera.rotation.x-event.relative.y*0.0025,-1.3,1.3)
 if event is InputEventKey and event.pressed and event.keycode == KEY_R:
  position = SPAWN
  velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
 if not enabled: return
 var input := Input.get_vector("move_left","move_right","move_forward","move_backward")
 var direction := global_basis * Vector3(input.x,0,input.y)
 var speed := SPRINT_SPEED if Input.is_physical_key_pressed(KEY_SHIFT) else SPEED
 velocity.x = direction.x*speed
 velocity.z = direction.z*speed
 if not is_on_floor(): velocity.y -= 18.0*delta
 if is_on_floor() and Input.is_action_just_pressed("jump"): velocity.y = 6.0
 move_and_slide()
 if position.y < -5 or absf(position.z) > 63 or position.x < -56 or position.x > 76:
  position = SPAWN
  velocity = Vector3.ZERO
