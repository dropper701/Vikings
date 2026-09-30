extends "res://demo/src/UI.gd"

func _process(_delta: float) -> void:
 $Label.text = "FPS: %d" % Engine.get_frames_per_second()
 if visible_mode == 1:
  $Label.text += "\n\nHRAFN VILLAGE\nWASD: Walk   Shift: Run\nMouse: Look   Space: Jump\nV: Camera view\nEscape: Release mouse\nF9: Hide controls"
