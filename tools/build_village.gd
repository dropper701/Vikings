extends SceneTree
## Run: godot --headless --path . --script tools/build_village.gd
## Produces an editable, self-contained geometry for the village scene with a fixed seed.
var village: Node3D
var rng := RandomNumberGenerator.new()
var materials := {}
var serial := 0

func _initialize() -> void:
 rng.seed = 84721
 village = Node3D.new()
 village.name = "RiversideVillage"
 material("timber", Color("58402b"), 1.0)
 material("darkwood", Color("30291f"), 1.0)
 material("planks", Color("806346"), 1.0)
 material("turf", Color("535944"))
 material("earth", Color("615647"))
 material("grass", Color("636a4d"))
 material("stone", Color("73736b"))
 material("iron", Color("292d2c"))
 material("linen", Color("b6a78c"))
 material("red", Color("703c31"))
 material("pine", Color("303f34"))
 material("leaf", Color("465440"))
 material("weathered",Color("756b57"),1.0)
 textured_material("grass", "ground037", Color(0.62,0.69,0.49),0.28)
 textured_material("earth", "ground037", Color(0.82,0.73,0.59),0.4)
 textured_material("turf", "ground037", Color(0.44,0.52,0.30),0.7)
 textured_material("stone", "rock023", Color(0.7,0.72,0.68),0.9)
 var ground := group("Landscape", village)
 box("VillageBank", ground, Vector3(-44,-0.65,-5), Vector3(132,1.3,150), "grass", true)
 box("FarBank", ground, Vector3(58,-0.65,0), Vector3(40,1.3,130), "grass", true)
 box("RiverBed", ground, Vector3(30,-2.25,0), Vector3(16,0.5,130), "earth", true)
 slope(ground, 22, 25)
 slope(ground, 38, 35)
 var river := MeshInstance3D.new()
 river.name = "FlowingRiver"
 var plane := PlaneMesh.new()
 plane.size = Vector2(16,130)
 plane.subdivide_depth = 100
 river.mesh = plane
 var water := ShaderMaterial.new()
 water.shader = load("res://assets/village/river.gdshader")
 river.material_override = water
 river.position = Vector3(30,-0.5,0)
 add(river,ground)
 var paths := group("PackedEarthPaths",village)
 box("QuaysidePath",paths,Vector3(17,0.015,0),Vector3(4,0.03,94),"earth")
 box("MainLane",paths,Vector3(-40,0.02,6),Vector3(108,0.04,4),"earth")
 box("Square",paths,Vector3(3,0.018,-5),Vector3(19,0.035,18),"earth")
 box("NorthLane",paths,Vector3(-45,0.016,-18),Vector3(99,0.032,3),"earth")
 box("UpperLane",paths,Vector3(-18,0.02,-20),Vector3(3,0.04,60),"earth")
 box("OuterLane",paths,Vector3(-74,0.02,-20),Vector3(3,0.04,60),"earth")
 house("ChieftainsLonghouse",Vector3(-88,0,-35),22,22,3.6,2.6)
 house("WeaversHouse",Vector3(-60,0,-34),16,13,3.5,2.2)
 house("FishersHouse",Vector3(-32,0,-34),16,13,3.5,2.2)
 house("FamilyLonghouse",Vector3(-88,0,20),18,16,3.6,2.4,PI)
 house("Storehouse",Vector3(-60,0,20),16,13,3.5,2.2,PI)
 house("SmithsHouse",Vector3(-32,0,20),16,14,3.5,2.2,PI)
 house("HuntersLodge",Vector3(-60,0,-62),18,14,3.5,2.3)
 house("BrewersHouse",Vector3(-32,0,-62),18,14,3.5,2.3)
 house("GuestLonghouse",Vector3(-4,0,-34),20,15,3.6,2.4)
 house("FarmersHouse",Vector3(-4,0,-62),18,14,3.5,2.3)
 dock(Vector3(20,0.0,0))
 boat(Vector3(30,-0.35,2))
 market(Vector3(6,0,-4))
 market(Vector3(6,0,4))
 well(Vector3(-7,0,-5))
 firepit(Vector3(-3,0,0))
 var props := group("VillageSupplies",village)
 for p in [Vector3(13,0,-11),Vector3(15,0,-10),Vector3(19,0,4),Vector3(-24,0,2),Vector3(-1,0,17)]:
  barrel(props,p)
  box("SupplyCrate",props,p+Vector3(1.5,0.55,0.4),Vector3(0.9,1.1,0.9),"planks",true)
  for h in [0.15,0.95]:
   box("CrateBand",props,p+Vector3(1.5,h,0.4),Vector3(0.96,0.09,0.96),"darkwood")
 for i in range(7):
  var z := -40.0 + i * 12.0
  fence(props,Vector3(-31,0,z),Vector3(-31,0,z+9))
 for i in range(10):
  cylinder("Firewood",props,Vector3(-25+(i%5)*0.32,0.3+floori(i/5)*0.29,0),0.16,1.8,"timber",Vector3(PI/2,0,0))
 var rack := group("FishDryingRack",props)
 rack.position = Vector3(17,0,-15)
 for x in [-1.5,1.5]:
  box("Upright",rack,Vector3(x,1.4,0),Vector3(0.13,2.8,0.13),"timber",true)
 box("Crossbar",rack,Vector3(0,2.65,0),Vector3(3.4,0.13,0.13),"timber")
 for i in range(8):
  cylinder("HangingFish",rack,Vector3(-1.2+i*0.35,2.05,0),0.065,0.65,"linen")
 var trees := group("PineWoodland",village)
 for i in range(90):
  var x := rng.randf_range(-51,73)
  var z := rng.randf_range(-58,58)
  if x > -33 and x < 42 and absf(z) < 40: continue
  if x > 20 and x < 41: continue
  tree(trees,Vector3(x,0,z),rng.randf_range(0.8,1.5))
 var rocks := group("RiverStonesAndReeds",village)
 for i in range(95):
  var side := 1.0 if i % 2 == 0 else -1.0
  var x := 30.0 + side*rng.randf_range(7.4,8.3)
  var z := rng.randf_range(-60,60)
  rock(rocks,Vector3(x,-0.1,z),rng.randf_range(0.2,0.65))
  if absf(z) > 9:
   for j in range(3):
    cylinder("Reed",rocks,Vector3(x+rng.randf_range(-0.4,0.4),0.35,z+j*0.18),0.023,rng.randf_range(0.7,1.3),"turf")
 var grass := MultiMeshInstance3D.new()
 grass.name = "RiverbankGrasses"
 var blade := SurfaceTool.new()
 blade.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(5):
  var angle := i*2.4
  var lean := Vector3(cos(angle)*0.18,0,sin(angle)*0.18)
  var left := Vector3(cos(angle)*0.035,0,sin(angle)*0.035)
  blade.add_vertex(-left)
  blade.add_vertex(lean+Vector3(0,0.35+i*0.05,0))
  blade.add_vertex(left)
  blade.add_vertex(left)
  blade.add_vertex(lean+Vector3(0,0.35+i*0.05,0))
  blade.add_vertex(-left)
 blade.generate_normals()
 var instances := MultiMesh.new()
 instances.transform_format = MultiMesh.TRANSFORM_3D
 instances.mesh = blade.commit()
 instances.instance_count = 2300
 for i in range(2300):
  var side := -1.0 if i%2 == 0 else 1.0
  var x := 30+side*rng.randf_range(8.3,10.7)
  var z := rng.randf_range(-61,61)
  if absf(z) < 3: z += 8
  var basis := Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*rng.randf_range(0.7,1.6))
  instances.set_instance_transform(i,Transform3D(basis,Vector3(x,0,z)))
 grass.multimesh = instances
 grass.material_override = materials.turf
 add(grass,village)
 var spawn := Marker3D.new()
 spawn.name = "PlayerSpawn"
 spawn.position = Vector3(0,1.3,13)
 add(spawn,village)
 var scene := PackedScene.new()
 var err := scene.pack(village)
 if err == OK: err = ResourceSaver.save(scene,"res://scenes/village/riverside_village.tscn")
 print("Village saved: ",error_string(err),"; nodes: ",serial)
 village.free()
 quit(err)

func add(n: Node, parent: Node) -> void:
 parent.add_child(n)
 n.owner = village
 serial += 1

func group(label: String, parent: Node) -> Node3D:
 var n := Node3D.new()
 n.name = label
 add(n,parent)
 return n

func material(key: String, color: Color, grain: float = 0.0) -> void:
 var m := ShaderMaterial.new()
 m.shader = load("res://assets/village/natural_surface.gdshader")
 m.set_shader_parameter("base_color",color)
 m.set_shader_parameter("grain",grain)
 materials[key] = m

func textured_material(key: String, texture_name: String, tint: Color, tiling: float) -> void:
 var m := StandardMaterial3D.new()
 m.albedo_texture = load("res://demo/assets/textures/"+texture_name+"_alb_ht.png")
 m.albedo_color = tint
 m.normal_enabled = true
 m.normal_texture = load("res://demo/assets/textures/"+texture_name+"_nrm_rgh.png")
 m.normal_scale = 0.7
 m.roughness = 0.95
 m.uv1_triplanar = true
 m.uv1_world_triplanar = true
 m.uv1_scale = Vector3.ONE*tiling
 materials[key] = m

func box(label: String, parent: Node, pos: Vector3, size: Vector3, mat: String, solid: bool = false, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
 var n := MeshInstance3D.new()
 n.name = label
 n.position = pos
 n.rotation = rot
 var mesh := BoxMesh.new()
 mesh.size = size
 n.mesh = mesh
 n.material_override = materials[mat]
 add(n,parent)
 if solid:
  var body := StaticBody3D.new()
  body.name = "CollisionBody"
  add(body,n)
  var collision := CollisionShape3D.new()
  collision.name = "Shape"
  var shape := BoxShape3D.new()
  shape.size = size
  collision.shape = shape
  add(collision,body)
 return n

func cylinder(label: String, parent: Node, pos: Vector3, radius: float, height: float, mat: String, rot: Vector3 = Vector3.ZERO, top: float = -1.0) -> MeshInstance3D:
 var n := MeshInstance3D.new()
 n.name = label
 n.position = pos
 n.rotation = rot
 var mesh := CylinderMesh.new()
 mesh.bottom_radius = radius
 mesh.top_radius = radius if top < 0 else top
 mesh.height = height
 mesh.radial_segments = 12
 n.mesh = mesh
 n.material_override = materials[mat]
 add(n,parent)
 return n

func beam(parent: Node, a: Vector3, b: Vector3, width: float, mat: String) -> void:
 var n := box("TimberBrace",parent,(a+b)/2,Vector3(width,a.distance_to(b),width),mat)
 n.quaternion = Quaternion(Vector3.UP,(b-a).normalized())

func triangle_mesh(parent: Node, label: String, vertices: Array, mat: String, solid: bool = false) -> void:
 var surface := SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for v in vertices: surface.add_vertex(v)
 surface.generate_normals()
 var n := MeshInstance3D.new()
 n.name = label
 n.mesh = surface.commit()
 n.material_override = materials[mat]
 add(n,parent)
 if solid:
  n.create_trimesh_collision()
  for child in n.get_children():
   child.owner = village
   for sub in child.get_children(): sub.owner = village

func slope(parent: Node, edge: float, bottom: float) -> void:
 var a := Vector3(edge,0,-65)
 var b := Vector3(edge,0,65)
 var c := Vector3(bottom,-2,65)
 var d := Vector3(bottom,-2,-65)
 var verts := [a,b,c,a,c,d] if edge < bottom else [a,c,b,a,d,c]
 triangle_mesh(parent,"SlopingRiverBank",verts,"earth",true)

func house(label: String, pos: Vector3, w: float, length: float, wall: float, rise: float, angle: float = 0) -> void:
 var h := group(label,village)
 h.set_meta("village_house",true)
 h.position = pos
 h.rotation.y = angle
 box("StoneFooting",h,Vector3(0,0.12,0),Vector3(w+0.5,0.24,length+0.5),"stone",true)
 box("Floor",h,Vector3(0,0.28,0),Vector3(w,0.1,length),"planks",true)
 box("EntryStep",h,Vector3(0,0.09,length/2+0.7),Vector3(2.4,0.18,1.2),"stone",true)
 for side in [-1.0,1.0]:
  box("LongWall",h,Vector3(side*w/2,wall/2+0.3,0),Vector3(0.22,wall,length),"timber",true)
  for i in range(int(length/0.3)):
   box("WallBoard",h,Vector3(side*(w/2+0.13),wall/2+0.3,-length/2+i*0.3),Vector3(0.05,wall,0.025),"darkwood")
  for z in [-length/2,0.0,length/2]:
   box("WallPost",h,Vector3(side*w/2,wall/2+0.35,z),Vector3(0.3,wall+0.4,0.3),"darkwood")
  box("SillBeam",h,Vector3(side*(w/2+0.05),0.5,0),Vector3(0.3,0.2,length),"darkwood")
  box("EaveBeam",h,Vector3(side*(w/2+0.05),wall+0.3,0),Vector3(0.3,0.22,length+0.8),"darkwood")
 box("RearWall",h,Vector3(0,wall/2+0.3,-length/2),Vector3(w,wall,0.22),"timber",true)
 for side in [-1.0,1.0]:
  box("DoorSideWall",h,Vector3(side*(w/4+0.75),wall/2+0.3,length/2),Vector3(w/2-1.5,wall,0.22),"timber",true)
  box("DoorPost",h,Vector3(side*1.6,wall/2+0.3,length/2+0.07),Vector3(0.18,wall,0.35),"darkwood")
 box("DoorLintel",h,Vector3(0,wall,length/2),Vector3(3.2,0.4,0.25),"darkwood",true)
 for end in [-1.0,1.0]:
  var z: float = end*length/2
  var a := Vector3(-w/2,wall+0.3,z)
  var b := Vector3(w/2,wall+0.3,z)
  var c := Vector3(0,wall+rise+0.3,z)
  triangle_mesh(h,"TimberGable",[a,c,b,b,c,a],"timber")
  beam(h,a+Vector3(0,0,end*0.15),c+Vector3(0,0,end*0.15),0.22,"darkwood")
  beam(h,b+Vector3(0,0,end*0.15),c+Vector3(0,0,end*0.15),0.22,"darkwood")
 var pitch := atan2(rise,w/2)
 var roof_width := sqrt(pow(w/2+0.65,2)+pow(rise+0.4,2))
 for side in [-1.0,1.0]:
  box("TurfRoof",h,Vector3(side*(w/4+0.25),wall+rise/2+0.25,0),Vector3(roof_width,0.28,length+1.5),"turf",true,Vector3(0,0,-side*pitch))
  for z in [-length/2-0.75,length/2+0.75]:
   box("RoofEdge",h,Vector3(side*(w/4+0.25),wall+rise/2+0.28,z),Vector3(roof_width+0.1,0.18,0.18),"darkwood",false,Vector3(0,0,-side*pitch))
 # Bark edging and exposed rafters break up the clean roof silhouette.
 for z in range(-floori(length/2),floori(length/2)+1,2):
  for side in [-1.0,1.0]:
   beam(h,Vector3(0,wall+rise+0.34,z),Vector3(side*(w/2+0.6),wall+0.04,z),0.11,"weathered")
 for side in [-1.0,1.0]:
  for z in [-length/2+2.5, length/2-2.5]:
   box("ShutterRecess",h,Vector3(side*(w/2+0.15),2.0,z),Vector3(0.05,0.85,1.0),"darkwood")
   for j in range(4):
    box("ShutterSlat",h,Vector3(side*(w/2+0.19),2.0,z-0.37+j*0.25),Vector3(0.07,0.76,0.2),"weathered")
   box("WindowSill",h,Vector3(side*(w/2+0.24),1.53,z),Vector3(0.3,0.12,1.2),"planks")
 # Extra tables and supporting posts suit the much broader interior.
 for side in [-1.0,1.0]:
  box("RoofSupport",h,Vector3(side*w*0.26,wall/2+0.33,-length/2+2),Vector3(0.25,wall,0.25),"darkwood",true)
  box("DiningBench",h,Vector3(side*2.5,0.65,-2),Vector3(0.6,0.2,3.5),"planks",true)
  for z in [-3.3,-0.7]: box("BenchSupport",h,Vector3(side*2.5,0.44,z),Vector3(0.35,0.42,0.35),"darkwood")
 box("Ridge",h,Vector3(0,wall+rise+0.4,0),Vector3(0.24,0.25,length+2),"darkwood")
 for end in [-1.0,1.0]:
  beam(h,Vector3(0,wall+rise+0.3,end*(length/2+0.5)),Vector3(0,wall+rise+1,end*(length/2+1.1)),0.24,"darkwood")
 for side in [-1.0,1.0]:
  box("SleepingBench",h,Vector3(side*(w/2-0.8),0.6,-1),Vector3(1.1,0.55,length-3),"planks",true)
 box("Table",h,Vector3(0,1,-1),Vector3(1.3,0.16,2.8),"planks",true)
 for z in [-2.0,0.0]:
  box("TableLeg",h,Vector3(0,0.6,z),Vector3(0.2,0.8,0.2),"darkwood")
 # Beds, chests and shelves stay against the walls, leaving the entry aisle clear.
 for side in [-1.0,1.0]:
  box("WoolBedding",h,Vector3(side*(w/2-0.8),0.94,-length/2+2.3),Vector3(1.0,0.15,2.6),"linen")
  box("WoolBlanket",h,Vector3(side*(w/2-0.8),1.04,-length/2+2.6),Vector3(1.02,0.06,1.5),"red")
  box("StorageChest",h,Vector3(side*(w/2-1.7),0.7,-length/2+1.0),Vector3(1.1,0.7,0.7),"planks",true)
  box("ChestLid",h,Vector3(side*(w/2-1.7),1.08,-length/2+1.0),Vector3(1.16,0.12,0.76),"darkwood")
  box("WallShelf",h,Vector3(side*(w/2-0.45),1.8,2.0),Vector3(0.7,0.12,2.5),"planks")
  for j in range(4):
   cylinder("ClayCup",h,Vector3(side*(w/2-0.45),2.0,1.2+j*0.5),0.1,0.28,"earth",Vector3.ZERO,0.13)
 for z in [-1.7,-0.4]:
  cylinder("TableBowl",h,Vector3(0,1.17,z),0.2,0.16,"earth",Vector3.ZERO,0.26)
 barrel(h,Vector3(w/2-1,0.33,length/2-2))
 if "Smith" in label:
  box("ForgeBase",h,Vector3(-w/2+1.6,0.8,-length/2+2.3),Vector3(1.5,1,1.5),"stone",true)
  box("Anvil",h,Vector3(-w/2+1.6,1.4,-length/2+2.3),Vector3(1.1,0.3,0.5),"iron")
 if "Brewer" in label or "Store" in label:
  for j in range(3): barrel(h,Vector3(-w/2+1,0.33,-length/2+2+j*1.3))
 var light := OmniLight3D.new()
 light.name = "InteriorWarmth"
 light.position = Vector3(0,2,0)
 light.light_color = Color("ffc27a")
 light.light_energy = 0.7
 light.omni_range = length*0.65
 add(light,h)

func dock(pos: Vector3) -> void:
 var d := group("TimberLanding",village)
 d.position = pos
 for i in range(23):
  box("DeckPlank",d,Vector3(i*0.4,0.13,0),Vector3(0.37,0.24,3.4),"planks",true)
 for x in [0.0,3.6,7.2,8.8]:
  for z in [-1.45,1.45]:
   cylinder("DrivenPile",d,Vector3(x,-0.4,z),0.17,3.2,"darkwood")
 for z in [-1.1,1.1]:
  box("DeckSupport",d,Vector3(4.4,-0.1,z),Vector3(9.2,0.28,0.2),"darkwood")

func boat(pos: Vector3) -> void:
 var b := group("MooredClinkerBoat",village)
 b.position = pos
 # An open hull built from overlapping strakes, narrowed at both stems.
 for side in [-1.0,1.0]:
  for j in range(5):
   var y := j*0.18
   var width := 0.48+j*0.17
   for i in range(10):
    var z1 := -4.5+i*0.9
    var z2 := z1+0.9
    var x1: float = side*width*sqrt(maxf(0.015,1.0-pow(z1/4.65,2)))
    var x2: float = side*width*sqrt(maxf(0.015,1.0-pow(z2/4.65,2)))
    var a := Vector3(x1,y+pow(absf(z1)/4.5,4)*0.65,z1)
    var c := Vector3(x2,y+pow(absf(z2)/4.5,4)*0.65,z2)
    var n := box("ClinkerStrake",b,(a+c)/2,Vector3(0.11,0.23,a.distance_to(c)+0.03),"planks")
    n.rotation.y = atan2((c-a).x,(c-a).z)
 box("Keel",b,Vector3(0,-0.05,0),Vector3(0.3,0.2,8.6),"darkwood")
 for z in [-2.5,-1.0,0.5,2.0]:
  box("RowingBench",b,Vector3(0,0.55,z),Vector3(1.85,0.14,0.3),"timber")
 for z in [-4.45,4.45]:
  beam(b,Vector3(0,0.4,z),Vector3(0,2,z*1.12),0.2,"darkwood")
 box("Mast",b,Vector3(0,2.5,0),Vector3(0.13,5,0.13),"darkwood")
 box("FurledSail",b,Vector3(0,4.1,0),Vector3(3.2,0.24,0.24),"linen")
 beam(b,Vector3(-0.8,0.8,1),Vector3(-2.8,0.15,3),0.07,"timber")

func market(pos: Vector3) -> void:
 var m := group("MarketStall",village)
 m.position = pos
 for x in [-1.7,1.7]:
  for z in [-1.1,1.1]: box("AwningPost",m,Vector3(x,1.4,z),Vector3(0.12,2.8,0.12),"timber",true)
 box("CanvasAwning",m,Vector3(0,2.75,0),Vector3(3.8,0.07,2.8),"linen",false,Vector3(-0.12,0,0))
 box("Counter",m,Vector3(0,0.95,0),Vector3(3.3,0.18,1.5),"planks",true)
 for x in [-1.3,1.3]: box("CounterLeg",m,Vector3(x,0.48,0),Vector3(0.15,0.95,1.1),"timber")
 for i in range(5): cylinder("Pottery",m,Vector3(-1.1+i*0.5,1.21,0),0.18,0.4,"earth",Vector3.ZERO,0.12)

func well(pos: Vector3) -> void:
 var w := group("VillageWell",village)
 w.position = pos
 for i in range(12):
  var a := i*TAU/12
  box("WellStone",w,Vector3(cos(a),0.55,sin(a)),Vector3(0.53,1.1,0.4),"stone",true,Vector3(0,-a+PI/2,0))
 for x in [-1.4,1.4]: box("WellPost",w,Vector3(x,1.5,0),Vector3(0.2,3,0.2),"timber",true)
 box("Windlass",w,Vector3(0,2.1,0),Vector3(3.2,0.15,0.15),"darkwood")
 cylinder("Rope",w,Vector3(0,1.45,0),0.022,1.3,"linen")
 box("WellCover",w,Vector3(0,2.9,0),Vector3(3.5,0.14,2.3),"planks",false,Vector3(0,0,0.15))

func barrel(parent: Node, pos: Vector3) -> void:
 var b := group("Barrel",parent)
 b.position = pos
 cylinder("Staves",b,Vector3(0,0.55,0),0.4,1.1,"planks")
 for y in [0.13,0.54,0.96]: cylinder("IronHoop",b,Vector3(0,y,0),0.415,0.07,"iron")

func firepit(pos: Vector3) -> void:
 var f := group("GatheringHearth",village)
 f.position = pos
 for i in range(12):
  var a := i*TAU/12
  rock(f,Vector3(cos(a)*1.1,0.12,sin(a)*1.1),0.27)
 for i in range(4): cylinder("HearthLog",f,Vector3(0,0.15+i*0.06,0),0.12,1.6,"darkwood",Vector3(PI/2,i*1.1,0))
 for x in [-2.5,2.5]:
  box("GatheringBench",f,Vector3(x,0.6,0),Vector3(0.55,0.18,3),"planks",true)
  for z in [-1,1]: box("BenchLeg",f,Vector3(x,0.3,z),Vector3(0.3,0.6,0.3),"timber")

func rock(parent: Node, pos: Vector3, size: float) -> void:
 var n := MeshInstance3D.new()
 n.name = "WeatheredStone"
 var mesh := SphereMesh.new()
 mesh.radius = size
 mesh.height = size*1.5
 mesh.radial_segments = 7
 mesh.rings = 4
 n.mesh = mesh
 n.position = pos
 n.scale = Vector3(1.2,0.8,1)
 n.rotation = Vector3(rng.randf()*0.3,rng.randf()*TAU,rng.randf()*0.3)
 n.material_override = materials.stone
 add(n,parent)

func tree(parent: Node, pos: Vector3, size: float) -> void:
 var t := group("ScotsPine",parent)
 t.position = pos
 t.scale = Vector3.ONE*size
 cylinder("Trunk",t,Vector3(0,3.8,0),0.22,7.6,"timber",Vector3.ZERO,0.09)
 var verts: Array = []
 for tier in range(9):
  var y := 2.4+tier*0.56
  var radius := 2.5*(1.0-tier/10.0)
  var offset := rng.randf()*TAU
  for branch in range(11):
   var a := offset+branch*TAU/11
   var extent := radius*rng.randf_range(0.72,1.17)
   var center := Vector3(cos(a)*extent*0.58,y+rng.randf_range(-0.15,0.15),sin(a)*extent*0.58)
   var tip := Vector3(cos(a)*extent,y-0.35,sin(a)*extent)
   var left := Vector3(cos(a-0.3)*extent*0.6,y-0.25,sin(a-0.3)*extent*0.6)
   var right := Vector3(cos(a+0.3)*extent*0.6,y-0.25,sin(a+0.3)*extent*0.6)
   var peak := center+Vector3(0,0.9,0)
   var inner := Vector3(0,y+0.2,0)
   verts.append_array([peak,tip,left,peak,right,tip,peak,inner,right,peak,left,inner,tip,right,left])
 triangle_mesh(t,"IrregularPineBranches",verts,"pine")

func fence(parent: Node, a: Vector3, b: Vector3) -> void:
 for i in range(4):
  var p := a.lerp(b,i/3.0)
  box("FencePost",parent,p+Vector3(0,0.8,0),Vector3(0.15,1.6,0.15),"darkwood",true)
 for y in [0.5,1.2]: beam(parent,a+Vector3(0,y,0),b+Vector3(0,y,0),0.12,"timber")
