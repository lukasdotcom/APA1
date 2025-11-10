extends Node2D

signal clicked(space)
var clickable = false

## Sets highlight color of this parking space
##
## @param val string value, defaults to transparent
func set_outline_color(val : String):
	match val:
		"red":
			$outline.default_color = Color(1, 0, 0, 1)
			clickable = false
		"orange":
			$outline.default_color = Color(1, 0.5, 0, 1)
			# Valid spot, so make clickable
			clickable = true
		"green":
			$outline.default_color = Color(0, 1, 0, 1)
			clickable = false
		_:
			$outline.default_color = Color(1, 0, 0, 0)
			clickable = false
		
## Detects clicks when clickable
func _on_button_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and clickable:
		clicked.emit(self)
		set_outline_color("green")
