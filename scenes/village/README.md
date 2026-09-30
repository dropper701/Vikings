# Hrafn village in the mountain world

## Play the combined map

Press **F5**. `scenes/world.tscn` inherits `demo/Demo.tscn`, which is the grass-and-mountain map with the HUD shown in the reference screenshot. All three original terrain regions, the procedural mountain background, automatic rock/grass materials, and Terrain3D grass particles are inherited unchanged. The demo source scene and its terrain resources were not edited.

The player starts near (919, 3.41, -1810). **WASD** moves relative to the camera, **mouse** aims, **Shift** runs, **V** switches camera view, and **Escape** releases the mouse. Walking speed is 7 for village exploration. The world uses its own grounded movement controller: holding Space produces one jump and cannot fly or jump again on landing. Release and press Space again to jump. Demo flight/gravity toggles are not enabled in this world. Movement does not rotate the camera. The older custom controller in `scenes/player.gd` also has its WASD-induced camera reversal fixed.

## Village placement

`mountain_village.tscn` is instanced at (932, 0, -1810), rotated -90 degrees about Y. Buildings have lower walls and roof ridges, weathered shutters, exposed rafters, structural posts, and additional seating. Nearby flatter sites are selected to minimize foundation height; stone footings and entrance ramps fit the existing ground. Paths follow the terrain. The village has no replacement ground slab. Water fills the existing low basin at (906, 0, -1718), and a path leads down to the dock. Terrain heights and grass painting are not modified to fit the village.

The geometry is an editable first environment pass with ten broad, low-profile enterable buildings (16–22 metres wide, twice their previous widths) with approximately 3-metre doorway clearance, beds, blankets, chests, shelves, pottery, furniture, stalls, well, hearth, supplies, trees, a dock and decorative boat. There are no NPCs, interaction systems, swimming, or multiplayer additions. The basin has the original solid terrain underneath; water is visual, with layered noise ripples, depth-based colour and shoreline foam. Grass remains the original particle system and can still grow around paths and props. Major building and dock geometry has collision; small props and trees are decorative.

## Files and regeneration

- `scenes/world.tscn`: combined mountain map and village; project main scene.
- `mountain_village.tscn`: terrain-fitted village geometry.
- `riverside_village.tscn`: original reusable village layout.
- `village_preview.tscn`: separate flat-ground preview; run with F6, Tab to walk.
- `placeholder_world.tscn`: retained copy of the earlier flat checkerboard world.
- `world_village.tscn`: earlier bank variant, used only by that placeholder copy.

```sh
godot --headless --path . --script tools/build_village.gd
godot --headless --path . --script tools/fit_village_to_mountains.gd
godot --headless --path . --script tools/validate_world.gd
```

Regenerating overwrites the generated village scene files and their manual edits. It does not modify demo terrain maps. Save custom variants before regeneration. Refit if the terrain or village layout changes. World validation runs headlessly to isolate synthetic movement input from live keyboard focus. Visual rendering was checked separately in Godot.

The village reuses existing textures under `demo/assets/textures`; preserve that folder and its `asset_licenses.txt`. Custom shaders are under `assets/village`. For production, add LODs, optimize repeated meshes, and bake navigation after final placement.
