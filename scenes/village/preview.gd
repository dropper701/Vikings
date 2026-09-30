extends Node3D
var overview := true
@onready var explorer: CharacterBody3D = $Explorer
@onready var view_camera: Camera3D = $OverviewCamera

func _ready() -> void:
 view_camera.look_at(Vector3(-4,0,-3))
 if "--capture-village" in OS.get_cmdline_user_args():
  await get_tree().create_timer(3).timeout
  await RenderingServer.frame_post_draw
  var error := get_viewport().get_texture().get_image().save_png("res://assets/village/preview.png")
  print("Screenshot: ",error_string(error))
  get_tree().quit(error)

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
  overview = not overview
  explorer.enabled = not overview
  if overview:
   view_camera.make_current()
   Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  else:
   explorer.camera.make_current()
   Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  $HUD/Panel/Margin/Labels/Mode.text = "TAB  Explore on foot" if overview else "TAB  Village overview"
  get_viewport().set_input_as_handled()
