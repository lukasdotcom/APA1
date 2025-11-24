extends CharacterBody2D

var acceleration : int = 1000
var speed : int = 0
var max_speed : int = 5000
var friction : float = .98
var break_friction : float = .92
var rotation_speed : int = 1
var gear : int = 0

var path : Array = []
var nearby_cars : Array = []
	
func _physics_process(delta):
	if path != []:
		if len(self.nearby_cars) > 0:
			path = []
			%spaces.reset()
			%view.points = []
			self.max_speed = 5000
			self.speed = 0
			self.gear = 1
			$"../hmi".collision()
		elif Input.is_action_just_pressed("q"):
			path = []
			%spaces.reset()
			%view.points = []
			self.max_speed = 5000
			self.speed *= -1
			$"../hmi".toggle()
		elif Input.is_action_pressed("down"):
			self.max_speed *= .98
		elif (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") 
		or Input.is_action_just_pressed("up") or is_zero_approx(self.max_speed)):
				path = []
				%spaces.reset()
				%view.points = []
				self.max_speed = 5000
				self.speed *= -1
				$"../hmi".reset()
		else:
			gear = 2
			follow_path(delta, self.max_speed)
	else:
		if Input.is_action_just_pressed("q"):
			$"../hmi".toggle()

		movement(delta)

func _process(delta):
	if Input.is_action_just_pressed("space"):
		if gear < 2:
			gear += 1
		else:
			gear = 0

func movement(delta):
	if gear == 1:
		velocity = Vector2.ZERO
		self.speed = 0
		return

	var direction : Vector2 = Vector2.UP.rotated(rotation)
	
	# Do acceleration on gas
	if Input.is_action_pressed("up"):
		if gear == 0:
			speed += acceleration * delta
		elif gear == 2:
			speed -= acceleration * delta
	else:
		if Input.is_action_pressed("down"):
			speed *= break_friction
		else:
			speed *= friction
	
	if speed > max_speed:
		speed = max_speed
		
	if speed != 0:
		if Input.is_action_pressed("left"):
			rotation -= rotation_speed * delta
		elif Input.is_action_pressed("right"):
			rotation += rotation_speed * delta
		
	velocity = direction * speed
	self.speed = speed
	
	move_and_slide()

## Builds a path from the car to the space and
## saves it to self.path
##
## @param space space to build a path to
func build_path(space):
	var new_path = []
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
			new_path = [space.global_position, pull_forward, destination]
		else:
			staging_pos.x += 250
			pull_forward.x = space.global_position.x - 250
			destination = Vector2(pull_forward.x + 10, pull_forward.y)
			new_path = [space.global_position, pull_forward, destination]

		# Parallel spaces are always below car
		staging_pos.y -= 250
		
		# Add first curve
		var midpoint
		for i in range(21):
			var output = bezier(destination, staging_pos, "up", Vector2.ZERO, i / 20.0)
			midpoint = output[1]
			new_path.append(output[0])
		
		new_path.append(staging_pos)
		
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
			new_path.append(output[0])
		
		new_path.append(pre_park)
	else:
		var staging_pos = Vector2(space.global_position.x, space.global_position.y)
		var destination = Vector2.ZERO
	
		# Pre-park position to find first
		# Small offset point added to correct rotation
		if space.global_position.x > self.global_position.x:
			staging_pos.x -= 1000
			destination = Vector2(space.global_position.x - 10, space.global_position.y)
			new_path = [space.global_position, destination]
		else:
			staging_pos.x += 1000
			destination = Vector2(space.global_position.x + 10, space.global_position.y)
			new_path = [space.global_position, destination]

		# Get vertical offset based on car direction
		var direction = Vector2.UP.rotated(self.rotation)
		if direction.dot(Vector2.UP) > 0:
			staging_pos.y -= 500
		else:
			staging_pos.y += 500
		
		# Add first curve
		for i in range(21):
			var output = bezier(destination, staging_pos, "up", Vector2.ZERO, i / 20.0)
			new_path.append(output[0])
		
		new_path.append(staging_pos)

	self.path = new_path
	self.max_speed = 750

## Follows the saved path
func follow_path(delta, max_speed):
	# Do acceleration
	self.speed += acceleration * delta
	if self.speed > max_speed:
		self.speed = max_speed
		
	# Movement
	var step = min(self.speed * delta, global_position.distance_to(path[path.size() - 1]))
	var direction = (path[path.size() - 1] - self.global_position).normalized()
	self.global_position += direction * step
	
	# Rotation
	# Find if point is in front or behind to determine whether to drive
	# forwards or backwards
	var angle = 0
	if Vector2.UP.rotated(%car.rotation).dot(direction) >= 0:
		angle = wrapf(direction.angle() + PI/2 - self.rotation, -PI, PI)
		self.gear = 0
	else:
		angle = wrapf(direction.angle() - PI/2 - self.rotation, -PI, PI)
		self.gear = 2
		
	rotation += clamp(angle, -3 * delta, 3 * delta)

	# If lerp is near done, pop
	if global_position.distance_to(path[path.size() - 1]) <= step:
		global_position = path[path.size() - 1]
		path.pop_back()
		
		if self.path.size() == 0:
			self.gear = 1
			%view.points = []
			%spaces.reset()
			self.max_speed = 5000
			$"../hmi".reset()

func bezier(source, destination, direction, tangent, x):
	var midpoint = Vector2.ZERO
	if tangent != Vector2.ZERO:
		midpoint = tangent
	elif direction == "up":
		midpoint = Vector2(destination.x, source.y)
	else:
		midpoint = Vector2(source.x, destination.y)
	
	return [(1 -x) * (1 - x) * source + 2 * (1 - x) * x * midpoint + x * x * destination, midpoint]


func _on_spaces_execute_park(space):
	self.build_path(space)
	%view.build_path(space)
	
func _on_sensors_body_entered(body):
	if body != self and body != $"../boundaries":
		self.nearby_cars.append(body)

func _on_sensors_body_exited(body):
	if body != self and body != $"../boundaries":
		self.nearby_cars.erase(body)
