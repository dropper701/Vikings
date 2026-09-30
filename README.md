# Vikings
A funny, chaotic 1–4 player Viking co-op adventure set in a realistic open world.

## Riverside village and mountain map

Press **F5** in Godot to run `scenes/world.tscn`. It now inherits `demo/Demo.tscn`, the grass-and-mountain map matching the teammate's reference, and adds the village beside an existing natural basin. The landscape's original terrain data, grass system, materials and mountain background remain in place.

Use **WASD** and the mouse; **Shift** runs, **V** changes camera view, and **Escape** releases the mouse. The player starts in the village with movement speed 7. **Space** performs one grounded jump; holding it does not fly. There are ten furnished houses with taller, wider entrances.

See [village setup](scenes/village/README.md). The earlier flat placeholder world is retained separately at `scenes/village/placeholder_world.tscn`.
