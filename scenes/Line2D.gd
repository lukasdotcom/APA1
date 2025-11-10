extends Line2D

## Builds a path from the car to the space and
## saves it to self.path
##
## @param space space to build a path to
func build_path(space):
	var path = []
	var staging_pos = Vector2(space.global_position.x, space.global_position.y)
	var destination = Vector2.ZERO
	
	# Pre-park position to find first
	# Small offset point added to correct rotation
	if space.global_position.x > %car.global_position.x:
		staging_pos.x -= 1500
		destination = Vector2(space.global_position.x - 10, space.global_position.y)
		path = [space.global_position, destination]
	else:
		staging_pos.x += 1500
		destination = Vector2(space.global_position.x + 10, space.global_position.y)
		path = [space.global_position, destination]

	var destination_2 = Vector2.ZERO
	if space.global_position.y < %car.global_position.y:
		staging_pos.y += 500
		destination_2 = Vector2(staging_pos.x, staging_pos.y + 10)
	else:
		staging_pos.y -= 500
		destination_2 = Vector2(staging_pos.x, staging_pos.y - 10)
	
	# Add first curve
	var midpoint
	for i in range(21):
		var output = bezier(destination, staging_pos, "up", Vector2.ZERO, i / 20.0)
		midpoint = output[1]
		path.append(output[0])
	
	path.append(staging_pos)
	
	# Second curve
	var tangent = 2 * staging_pos - midpoint
	for i in range(21):
		var output = bezier(staging_pos, %car.global_position, "down", tangent, i / 20.0)
		path.append(output[0])
	
	path.append(%car.global_position)
	self.points = path

func bezier(source, destination, direction, tangent, x):
	var midpoint = Vector2.ZERO
	if tangent != Vector2.ZERO:
		midpoint = tangent
	elif direction == "up":
		midpoint = Vector2(destination.x, source.y)
	else:
		midpoint = Vector2(source.x, destination.y)
	
	return [(1 -x) * (1 - x) * source + 2 * (1 - x) * x * midpoint + x * x * destination, midpoint]
