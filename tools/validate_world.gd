extends SceneTree
var failures := 0

func _initialize() -> void: call_deferred("check_world")

func verify(ok: bool, label: String) -> void:
 print("PASS: " if ok else "FAIL: ",label)
 if not ok: failures += 1

func key(code: Key, pressed: bool) -> void:
 var event := InputEventKey.new()
 event.keycode = code
 event.physical_keycode = code
 event.pressed = pressed
 Input.parse_input_event(event)
 Input.flush_buffered_events()

func check_world() -> void:
 var world: Node = load("res://scenes/world.tscn").instantiate()
 root.add_child(world)
 var player: CharacterBody3D = world.get_node("Player")
 var terrain: Terrain3D = world.get_node("Terrain3D")
 var camera: Camera3D = player.get_node("CameraManager/Arm/Camera3D")
 camera.make_current()
 var grounded_frames := 0
 for i in range(180):
  await physics_frame
  if i > 90 and player.is_on_floor(): grounded_frames += 1
 print("Player after settling: ",player.position,"; grounded frames ",grounded_frames)
 verify(terrain.data.get_region_locations().size()==3,"All three mountain-map regions load")
 verify(terrain.data_directory=="res://demo/data","World uses the landscape shown in the reference")
 verify(terrain.has_node("Terrain3DParticles"),"Original grass particle system is retained")
 verify(terrain.material.world_background==2 and terrain.material.auto_shader,"Original mountain background and terrain shading retained")
 verify(not world.get_node("RiversideVillage").has_node("Landscape"),"Village has no slab covering the terrain")
 verify(grounded_frames>30,"Active player settles on mountain terrain")
 verify(player.position.y>-5,"Player remains above terrain, not falling through")
 var village: Node3D = world.get_node("RiversideVillage")
 var expected_origin := Transform3D(Basis(Vector3.UP,-PI/2),Vector3(932,0,-1810))
 verify(village.global_transform.is_equal_approx(expected_origin),"Village orientation matches its terrain fitting")
 verify(village.get_node("RiverInlet").global_position.distance_to(Vector3(906,0,-1718))<0.01,"Water sits in the existing basin")
 for label in ["ChieftainsLonghouse","WeaversHouse","FishersHouse","FamilyLonghouse","Storehouse","SmithsHouse","HuntersLodge","BrewersHouse","GuestLonghouse","FarmersHouse"]:
  var house: Node3D = village.get_node(NodePath(label))
  var floor: MeshInstance3D = house.get_node("Floor")
  var size: Vector3 = floor.mesh.size
  var clear := true
  for x in [-size.x/2,0.0,size.x/2]:
   for z in [-size.z/2,0.0,size.z/2]:
    var p: Vector3 = house.global_transform*Vector3(x,0.33,z)
    if terrain.data.get_height(p)>p.y: clear = false
  verify(clear,label+" floor clears the original terrain")
 var houses: Array[Node3D] = []
 var widths := {"ChieftainsLonghouse":22.0,"WeaversHouse":16.0,"FishersHouse":16.0,"FamilyLonghouse":18.0,"Storehouse":16.0,"SmithsHouse":16.0,"HuntersLodge":18.0,"BrewersHouse":18.0,"GuestLonghouse":20.0,"FarmersHouse":18.0}
 for child: Node3D in village.get_children():
  if not child.has_meta("village_house"): continue
  houses.append(child)
  verify(is_equal_approx(child.get_node("Floor").mesh.size.x,widths[str(child.name)]),"Doubled width: "+str(child.name))
 var spaced := true
 for i in range(houses.size()):
  for j in range(i+1,houses.size()):
   var a := houses[i].get_node("Floor").mesh.size as Vector3
   var b := houses[j].get_node("Floor").mesh.size as Vector3
   var d := (houses[i].position-houses[j].position).abs()
   if d.x<(a.x+b.x)/2+1.4 and d.z<(a.z+b.z)/2+1.5: spaced = false
 verify(spaced,"Expanded roofs and buildings do not overlap")
 # Hold Space long after landing: only one ballistic jump is allowed.
 var initial_height := player.position.y
 key(KEY_SPACE,true)
 var peak := initial_height
 var rises := 0
 var rising := false
 for i in range(150):
  await physics_frame
  peak = maxf(peak,player.position.y)
  if player.velocity.y>0.1 and not rising: rises += 1
  rising = player.velocity.y>0.1
 key(KEY_SPACE,false)
 verify(peak>initial_height+0.6 and peak<initial_height+2.0,"Space produces a normal jump height")
 verify(rises==1 and player.is_on_floor(),"Holding Space lands without flight or automatic repeat jumps")
 key(KEY_SPACE,true)
 for i in range(5): await physics_frame
 verify(player.velocity.y>0,"Releasing and pressing Space allows a second jump")
 key(KEY_SPACE,false)
 for i in range(90): await physics_frame
 # Exercise input at two camera yaws; WASD must not rotate the camera.
 for yaw in [0.0,PI/2]:
  player.get_node("CameraManager").rotation.y = yaw
  for code in [KEY_W,KEY_S,KEY_A,KEY_D]:
   for other in [KEY_W,KEY_S,KEY_A,KEY_D]: key(other,false)
   var before := camera.global_basis
   key(code,true)
   var direction: Vector3 = player.get_camera_relative_input()
   var expected: Vector3
   match code:
    KEY_W: expected = -before.z
    KEY_S: expected = before.z
    KEY_A: expected = -before.x
    KEY_D: expected = before.x
   verify(direction.normalized().dot(expected.normalized())>0.999,"Camera-relative direction %s at yaw %.2f" % [OS.get_keycode_string(code),yaw])
   for i in range(4): await physics_frame
   key(code,false)
   verify(camera.global_basis.is_equal_approx(before),"Movement leaves camera facing unchanged")
 # Walk the actual gameplay capsule through every furnished house entrance.
 for house: Node in village.get_children():
  if not house.has_meta("village_house"): continue
  var length: float = house.get_node("Floor").mesh.size.z
  player.position = house.global_transform*Vector3(0,0.6,length/2+1.0)
  player.velocity = Vector3.ZERO
  player.get_node("CameraManager").rotation.y = house.global_rotation.y
  for i in range(45): await physics_frame
  key(KEY_W,true)
  for i in range(28): await physics_frame
  key(KEY_W,false)
  var local: Vector3 = house.to_local(player.global_position)
  verify(local.z<length/2-1 and local.y>0.1,"Walk through entrance: "+str(house.name))
 # Regression for the original custom controller that caused the camera reversal.
 var legacy: CharacterBody3D = load("res://scenes/player.gd").new()
 var rig := SpringArm3D.new()
 rig.name = "CameraRig"
 legacy.add_child(rig)
 legacy.position = Vector3(919,100,-1810)
 root.add_child(legacy)
 legacy.set_physics_process(false)
 for yaw in [0.0,PI/2]:
  legacy.rotation.y = yaw
  for action in ["move_forward","move_backward","move_left","move_right"]:
   var before := legacy.global_basis
   Input.action_press(action)
   legacy._physics_process(1.0/60)
   Input.action_release(action)
   var desired := Vector3.ZERO
   match action:
    "move_forward": desired = -before.z
    "move_backward": desired = before.z
    "move_left": desired = -before.x
    "move_right": desired = before.x
   var horizontal := Vector3(legacy.velocity.x,0,legacy.velocity.z).normalized()
   verify(horizontal.dot(desired)>0.999 and legacy.global_basis.is_equal_approx(before),"Original controller regression: "+action)
 legacy.free()
 world.free()
 print("World validation failures: ",failures)
 quit(failures)
