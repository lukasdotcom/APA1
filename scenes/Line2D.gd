extends Line2D

## Builds a path from the car to the space and
## saves it to self.path
##
## @param space space to build a path to
func build_path(space):
	var path = []
	if space.type == 'parallel':
		var staging_pos = Vector2(space.global_position.x, space.global_position.y)
		var destination = Vector2.ZERO
		var pull_forward = space.global_position
		var direction = Vector2.UP.rotated(%car.rotation)
		
		# Pre-park position to find first
		# Small offset point added to correct rotation
		if direction.dot(Vector2.LEFT) > 0:
			staging_pos.x -= 250
			pull_forward.x = space.global_position.x + 250
			destination = Vector2(pull_forward.x - 10, pull_forward.y)
			path = [space.global_position, destination]
		else:
			staging_pos.x += 250
			pull_forward.x = space.global_position.x - 250
			destination = Vector2(pull_forward.x + 10, pull_forward.y)
			path = [space.global_position, pull_forward, destination]

		staging_pos.y -= 250
		var destination_2 = Vector2(staging_pos.x, staging_pos.y + 10)
		
		# Add first curve
		var midpoint
		for i in range(21):
			var output = bezier(destination, staging_pos, "up", Vector2.ZERO, i / 20.0)
			midpoint = output[1]
			path.append(output[0])
		
		path.append(staging_pos)
		
		var pre_park = Vector2.ZERO
		if direction.dot(Vector2.LEFT) < 0:
			pre_park = Vector2(space.global_position.x + 1500, space.global_position.y - 500)
		else:
			pre_park = Vector2(space.global_position.x - 1500, space.global_position.y - 500)
	
		# Second curve
		# Calculate tangent midpoint for smoother curve junction
		var tangent = 2 * staging_pos - midpoint
		for i in range(21):
			var output = bezier(staging_pos, pre_park, "down", tangent, i / 20.0)
			path.append(output[0])
		
		path.append(pre_park)
	else:
		var staging_pos = Vector2(space.global_position.x, space.global_position.y)
		var destination = Vector2.ZERO
	
		# Pre-park position to find first
		# Small offset point added to correct rotation
		if space.global_position.x > %car.global_position.x:
			staging_pos.x -= 1000
			destination = Vector2(space.global_position.x - 10, space.global_position.y)
			path = [space.global_position, destination]
		else:
			staging_pos.x += 1000
			destination = Vector2(space.global_position.x + 10, space.global_position.y)
			path = [space.global_position, destination]

		# Get vertical offset based on car direction
		var direction = Vector2.UP.rotated(%car.rotation)
		if direction.dot(Vector2.UP) > 0:
			staging_pos.y -= 500
		else:
			staging_pos.y += 500
		
		# Add first curve
		for i in range(21):
			var output = bezier(destination, staging_pos, "up", Vector2.ZERO, i / 20.0)
			path.append(output[0])

		path.append(staging_pos)

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
