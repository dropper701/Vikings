extends SceneTree
var failures := 0

func _initialize() -> void:
 call_deferred("check_scene")

func check_scene() -> void:
 var scene := load("res://scenes/village/village_preview.tscn") as PackedScene
 if scene == null:
  quit(1)
  return
 var preview := scene.instantiate()
 root.add_child(preview)
 await physics_frame
 await physics_frame
 var space: PhysicsDirectSpaceState3D = preview.get_world_3d().direct_space_state
 for sample in [Vector3(0,5,13),Vector3(24,5,0),Vector3(-20,5,-10),Vector3(9,2,24)]:
  var query := PhysicsRayQueryParameters3D.create(sample,sample-Vector3(0,10,0))
  query.exclude = [preview.get_node("Explorer").get_rid()]
  verify(not space.intersect_ray(query).is_empty(),"Walkable surface at "+str(sample))
 for x in [-4.0,10.0]:
  var z := -19.0 if x == -4 else -15.0
  var query := PhysicsRayQueryParameters3D.create(Vector3(x,2.15,z+1),Vector3(x,2.15,z-1))
  verify(space.intersect_ray(query).is_empty(),"Doorway headroom at "+str(x))
 var water_query := PhysicsRayQueryParameters3D.create(Vector3(32,1,12),Vector3(32,-3,12))
 var river_hit := space.intersect_ray(water_query)
 verify(not river_hit.is_empty() and river_hit.position.y < -1.8,"River has a lowered solid bed")
 var explorer: CharacterBody3D = preview.get_node("Explorer")
 explorer.enabled = true
 for i in range(60): await physics_frame
 verify(explorer.is_on_floor(),"Explorer settles on the village ground")
 var start := explorer.position
 Input.action_press("move_forward")
 for i in range(30): await physics_frame
 Input.action_release("move_forward")
 verify(explorer.position.z < start.z-1.0,"WASD moves the explorer forward")
 var toggle := InputEventKey.new()
 toggle.keycode = KEY_TAB
 toggle.pressed = true
 preview._unhandled_input(toggle)
 verify(explorer.camera.current,"Tab activates the explorer camera")
 preview._unhandled_input(toggle)
 verify(preview.get_node("OverviewCamera").current and not explorer.enabled,"Tab restores overview and pauses movement")
 preview.free()
 print("Village validation failures: ",failures)
 quit(failures)

func verify(condition: bool, label: String) -> void:
 print("PASS: " if condition else "FAIL: ",label)
 if not condition: failures += 1
