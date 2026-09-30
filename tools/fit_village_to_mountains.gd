extends SceneTree
## Fits village geometry to the existing demo terrain without editing terrain maps.
var village: Node3D
var terrain: Terrain3D
var origin := Transform3D(Basis(Vector3.UP,-PI/2),Vector3(932,0,-1810))

func _initialize() -> void: call_deferred("build")

func ground(local: Vector3) -> float:
 var height := terrain.data.get_height(origin*local)
 return height if is_finite(height) else 0.0

func own(node: Node) -> void:
 node.owner = village
 for child in node.get_children(): own(child)

func build() -> void:
 var demo: Node = load("res://demo/Demo.tscn").instantiate()
 root.add_child(demo)
 await process_frame
 terrain = demo.get_node("Terrain3D")
 village = load("res://scenes/village/riverside_village.tscn").instantiate()
 village.name = "MountainVillage"
 # All base slabs and preview banks are omitted; the map supplies the ground.
 village.get_node("Landscape").free()
 village.get_node("RiverStonesAndReeds").free()
 village.get_node("RiverbankGrasses").free()
 for house: Node3D in village.get_children():
  if not house.has_meta("village_house"): continue
  var footing: MeshInstance3D = house.get_node("StoneFooting")
  var size: Vector3 = footing.mesh.size
  # Prefer nearby level ground so wider buildings do not become tall stone towers.
  var planned := house.position
  var best_score := INF
  var best := planned
  for dx in [-4.0,0.0,4.0]:
   for dz in [-3.0,0.0,3.0]:
    house.position = planned+Vector3(dx,0,dz)
    var mn := INF
    var mx := -INF
    for x in [-size.x/2,0.0,size.x/2]:
     for z in [-size.z/2,0.0,size.z/2]:
      var height := ground(house.transform*Vector3(x,0,z))
      mn = minf(mn,height)
      mx = maxf(mx,height)
    var score := mx-mn+(absf(dx)+absf(dz))*0.06
    if score<best_score:
     best_score = score
     best = house.position
  house.position = best
  var low := INF
  var high := -INF
  for x in range(-ceili(size.x/2),ceili(size.x/2)+1):
   for z in range(-ceili(size.z/2),ceili(size.z/2)+1):
    var height := ground(house.transform*Vector3(x,0,z))
    low = minf(low,height)
    high = maxf(high,height)
  house.position.y = high+0.45
  # Deep stone footing meets uneven ground instead of leaving floating buildings.
  var depth := high-low+0.70
  footing.mesh = footing.mesh.duplicate()
  footing.mesh.size.y = depth
  footing.position.y = 0.24-depth/2
  var collision: CollisionShape3D = footing.get_node("CollisionBody/Shape")
  collision.shape = collision.shape.duplicate()
  collision.shape.size.y = depth
  var entry: MeshInstance3D = house.get_node("EntryStep")
  entry.free()
  var door := Vector3(0,0.33,size.z/2)
  var end := Vector3(0,0,size.z/2+8)
  end.y = ground(house.transform*end)-house.position.y+0.08
  var st := SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  var left := Vector3(-1.45,0,0)
  var right := -left
  for v in [door+left,door+right,end+right,door+left,end+right,end+left]: st.add_vertex(v)
  st.generate_normals()
  var ramp := MeshInstance3D.new()
  ramp.name = "EntranceRamp"
  ramp.mesh = st.commit()
  ramp.material_override = house.get_node("Floor").material_override
  house.add_child(ramp)
  ramp.create_trimesh_collision()
 # Drape each path over the original hills, keeping the ground intact.
 for path in village.get_node("PackedEarthPaths").get_children():
  var dimensions: Vector3 = path.mesh.size
  var nx := ceili(dimensions.x)
  var nz := ceili(dimensions.z)
  var st := SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for ix in range(nx):
   for iz in range(nz):
    var corners: Array[Vector3] = []
    for corner in [Vector2(ix,iz),Vector2(ix+1,iz),Vector2(ix+1,iz+1),Vector2(ix,iz+1)]:
     var v := Vector3(corner.x/nx*dimensions.x-dimensions.x/2,0,corner.y/nz*dimensions.z-dimensions.z/2)
     v.y = ground(path.position+v)-path.position.y+0.06
     corners.append(v)
    for i in [0,2,1,0,3,2]: st.add_vertex(corners[i])
  st.generate_normals()
  path.mesh = st.commit()
 for label in ["PineWoodland","VillageSupplies"]:
  for item in village.get_node(NodePath(label)).get_children():
   item.position.y += ground(item.position)
   if label in ["PineWoodland","VillageSupplies"]:
    var inside_house := false
    for house: Node3D in village.get_children():
     if not house.has_meta("village_house"): continue
     var local: Vector3 = house.transform.affine_inverse()*item.position
     var size: Vector3 = house.get_node("Floor").mesh.size
     if absf(local.x)<size.x/2+2 and local.z>-size.z/2-2 and local.z<size.z/2+9:
      inside_house = true
    if inside_house or (label == "PineWoodland" and item.position.y<0.5): item.free()
 for item in village.get_children():
  if item.has_node("CanvasAwning") or item.name in ["VillageWell","GatheringHearth"]:
   item.position.y = ground(item.position)+0.1
 # Water occupies the existing low basin, naturally clipped by the shoreline.
 var water := MeshInstance3D.new()
 water.name = "RiverInlet"
 var mesh := PlaneMesh.new()
 mesh.size = Vector2(112,100)
 mesh.subdivide_width = 70
 mesh.subdivide_depth = 70
 water.mesh = mesh
 water.position = origin.affine_inverse()*Vector3(906,0,-1718)
 water.rotation.y = PI/2
 var mat := ShaderMaterial.new()
 mat.shader = load("res://assets/village/river.gdshader")
 water.material_override = mat
 village.add_child(water)
 # A winding access path follows the existing slope down to the landing.
 var lane := SurfaceTool.new()
 lane.begin(Mesh.PRIMITIVE_TRIANGLES)
 var start := Vector3(932,0,-1793)
 var finish := Vector3(926,0,-1760)
 for step in range(33):
  var a := start.lerp(finish,step/33.0)
  var b := start.lerp(finish,(step+1)/33.0)
  var corners: Array[Vector3] = []
  for p in [a+Vector3(-1,0,0),a+Vector3(1,0,0),b+Vector3(1,0,0),b+Vector3(-1,0,0)]:
   var local: Vector3 = origin.affine_inverse()*p
   local.y = ground(local)+0.06
   corners.append(local)
  for i in [0,1,2,0,2,3]: lane.add_vertex(corners[i])
 lane.generate_normals()
 var access := MeshInstance3D.new()
 access.name = "ShoreAccessPath"
 access.mesh = lane.commit()
 access.material_override = village.get_node("PackedEarthPaths/QuaysidePath").material_override
 village.add_child(access)
 var dock: Node3D = village.get_node("TimberLanding")
 dock.position = origin.affine_inverse()*Vector3(926,1.2,-1760)
 var boat: Node3D = village.get_node("MooredClinkerBoat")
 boat.position = origin.affine_inverse()*Vector3(930,0.15,-1750)
 village.get_node("PlayerSpawn").position = Vector3(0,ground(Vector3(0,0,13))+1.5,13)
 for child in village.get_children(): own(child)
 var scene := PackedScene.new()
 var result := scene.pack(village)
 if result == OK: result = ResourceSaver.save(scene,"res://scenes/village/mountain_village.tscn")
 print("Mountain village: ",error_string(result),"; spawn local ",village.get_node("PlayerSpawn").position)
 village.free()
 demo.free()
 quit(result)
