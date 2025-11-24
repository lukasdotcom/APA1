extends Node2D

signal clicked(space)
var clickable : bool = false
var type : String = 'normal'
var occupied : bool = false

func _ready():
	if self.type == 'normal':
		$line4.visible = false
		$line5.visible = false
	else:
		$line1.visible = false
		$line2.visible = false
		$line3.visible = false
		$outline.points = [Vector2(-250, -640), Vector2(250, -640), Vector2(250, 640), Vector2(-250, 640)]

## Sets highlight color of this parking space
##
## @param val string value, defaults to transparent
func set_outline_color(val : String):
	match val:
		"red":
			$outline.default_color = Color(1, 0, 0, 1)
			self.clickable = false
		"orange":
			$outline.default_color = Color(1, 0.5, 0, 1)
			# Valid spot, so make clickable
			self.clickable = true
		"green":
			$outline.default_color = Color(0, 1, 0, 1)
			self.clickable = false
		_:
			$outline.default_color = Color(1, 0, 0, 0)
			self.clickable = false
		
## Detects clicks when clickable
func _on_button_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and clickable:
		clicked.emit(self)
		set_outline_color("green")
