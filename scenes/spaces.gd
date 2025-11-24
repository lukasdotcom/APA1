extends Node

signal execute_park(space)

var space_scene : PackedScene = preload("res://scenes/space.tscn")
var car_scene : PackedScene = preload("res://scenes/other_car.tscn")
var spaces : Array = []

func _ready():
	spawn_spaces()
	
func spawn_spaces():
	for i in range(8):
		var space_l = space_scene.instantiate()
		space_l.global_position = Vector2(-5240, -2980 + 520 * i)
		space_l.rotation_degrees = -90
		space_l.z_index = -1
		if randi_range(0, 1) == 0:
			var car = car_scene.instantiate()
			car.global_position = Vector2(-5240, -2980 + 520 * i)
			car.rotation_degrees = -90
			var roll = randi_range(0, 3)
			if roll == 0:
				car.state = 'backward'
			$"../cars".add_child(car)
			if roll != 0:
				space_l.occupied = true
		add_child(space_l)
		spaces.append(space_l)
		if i < 6:
			var space_r = space_scene.instantiate()
			space_r.global_position = Vector2(5240, -2980 + 520 * i)
			space_r.rotation_degrees = 90
			space_r.z_index = -1
			if randi_range(0, 3) == 0:
				var car = car_scene.instantiate()
				car.global_position = Vector2(5240, -2980 + 520 * i)
				car.rotation_degrees = 90
				var roll = randi_range(0, 3)
				if roll == 0:
					car.state = 'backward'
				$"../cars".add_child(car)
				if roll != 0:
					space_r.occupied = true
			add_child(space_r)
			spaces.append(space_r)

	for i in range(5):
		var space = space_scene.instantiate()
		space.global_position = Vector2(-4550 + 1300 * i, 2990)
		space.type = 'parallel'
		space.z_index = -1
		space.rotation_degrees = 90
		if randi_range(0, 3) == 0:
			var car = car_scene.instantiate()
			car.global_position = Vector2(-4550 + 1300 * i, 2990)
			car.rotation_degrees = 90
			$"../cars".add_child(car)
			space.occupied = true
		add_child(space)
		spaces.append(space)
	
		
func reset():
	for space in spaces:
		space.set_outline_color("transparent")


## Finds valid spots to engage APA and highlights them
## based on the car's current location
func _on_hmi_find_spots():
	self.reset()
	var car_position = %car.global_position
	
	var closest_space = null
	var min_distance = 100000
	for space in spaces:
		if ((space.type == 'normal'
			 and not space.occupied
			 and abs(space.global_position.x - car_position.x) > 500
			 and abs(space.global_position.x - car_position.x) < 1500
			 and abs(space.global_position.y - car_position.y) < 2000)
			or (space.type == 'parallel'
				and not space.occupied
				and abs(space.global_position.x - car_position.x) < 3000
				and abs(space.global_position.y - car_position.y) > 500
				and abs(space.global_position.y - car_position.y) < 1500)):
			# Determine if this space is the closest valid space
			var dist = space.global_position.distance_to(car_position)
			if dist < min_distance:
				min_distance = dist
				closest_space = space

	if closest_space != null and closest_space.global_position.distance_to(car_position) < 2500:
		closest_space.set_outline_color("orange")
		%view.build_path(closest_space)
		$"../hmi".confirm_path(closest_space)
	else:
		$"../hmi".reset()
		%view.points = []

func _on_hmi_reset_spots():
	reset()
