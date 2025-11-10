extends Node

signal execute_park(space)

var space_scene : PackedScene = preload("res://scenes/space.tscn")
var spaces : Array = []

func _ready():
	spawn_spaces()
	
func spawn_spaces():
	for i in range(12):
		var space_l = space_scene.instantiate()
		var space_r = space_scene.instantiate()
		space_l.global_position = Vector2(-5240, -2980 + 520 * i)
		space_l.rotation_degrees = -90
		space_l.z_index = -1
		space_r.global_position = Vector2(5240, -2980 + 520 * i)
		space_r.rotation_degrees = 90
		space_r.z_index = -1
		space_l.clicked.connect(Callable(self, "_on_space_selected"))
		space_r.clicked.connect(Callable(self, "_on_space_selected"))
		add_child(space_l)
		add_child(space_r)
		spaces.append(space_l)
		spaces.append(space_r)
		
func reset():
	for space in spaces:
		space.set_outline_color("transparent")


## Finds valid spots to engage APA and highlights them
## based on the car's current location
func _on_hmi_find_spots():
	var car_position = %car.global_position
	var car_direction = Vector2.UP.rotated(%car.rotation)
	car_position += car_direction * 500
	
	for space in spaces:
		# Get vector from car to space
		var vec = (space.global_position - car_position).normalized()
		# Use dot product to determine if space is in front of car
		# cos(65) = 0.42, searching 65 degree cone in front
		if car_direction.dot(vec) >= 0.5:
			space.set_outline_color("orange")
		else:
			space.set_outline_color("red")
		
## Executes when a child space is selected
func _on_space_selected(body):
	for space in spaces:
		if space != body:
			space.set_outline_color("transparent")
	
	execute_park.emit(body)


func _on_hmi_reset_spots():
	reset()
