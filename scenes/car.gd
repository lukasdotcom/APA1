extends CharacterBody2D

var acceleration : int = 1000
var speed : int = 0
var max_speed : int = 5000
var friction : float = .98
var break_friction : float = .92
var rotation_speed : int = 1
var gear : int = 0

var path : Array = []
	
func _physics_process(delta):
	if path != []:
		if Input.is_action_pressed("down"):
			self.max_speed *= .98
		if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or  is_zero_approx(self.max_speed):
				path = []
				%spaces.reset()
				self.gear = 1
				%view.points = []
				self.max_speed = 5000
		else:
			gear = 0
			follow_path(delta, self.max_speed)
	else:
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
	var staging_pos = Vector2(space.global_position.x, space.global_position.y)
	var destination = Vector2.ZERO
	
	# Pre-park position to find first
	# Small offset point added to correct rotation
	if space.global_position.x > self.global_position.x:
		staging_pos.x -= 1500
		destination = Vector2(space.global_position.x - 10, space.global_position.y)
		new_path = [space.global_position, destination]
	else:
		staging_pos.x += 1500
		destination = Vector2(space.global_position.x + 10, space.global_position.y)
		new_path = [space.global_position, destination]

	if space.global_position.y < self.global_position.y:
		staging_pos.y += 500
	else:
		staging_pos.y -= 500
	
	# Add first curve
	var midpoint
	for i in range(21):
		var output = bezier(destination, staging_pos, "up", Vector2.ZERO, i / 20.0)
		midpoint = output[1]
		new_path.append(output[0])
	
	new_path.append(staging_pos)
	
	# Second curve
	# Calculate tangent midpoint for smoother curve junction
	var tangent = 2 * staging_pos - midpoint
	for i in range(21):
		var output = bezier(staging_pos, self.global_position, "down", tangent, i / 20.0)
		new_path.append(output[0])
	
	
	self.path = new_path
	self.max_speed = 1000
	
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
	var angle = wrapf(direction.angle() + PI/2 - self.rotation, -PI, PI)
	rotation += clamp(angle, -3 * delta, 3 * delta)
	#self.rotation = direction.angle() + PI/2

	# If lerp is near done, pop
	if global_position.distance_to(path[path.size() - 1]) <= step:
		global_position = path[path.size() - 1]
		path.pop_back()
		
		if self.path.size() == 0:
			self.gear = 1
			%view.points = []
			%spaces.reset()
			self.max_speed = 5000

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
	
