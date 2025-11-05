extends CharacterBody2D

var acceleration : int
var terminal_velocity : int
var friction : float
var break_friction : float

func _ready():
	acceleration = 200
	terminal_velocity = 2000
	friction = .98
	break_friction = .92
	
func _physics_process(delta):
	movement(delta)
	
func movement(delta):
	
	# Calculate direction of steering hitbox
	var segment = $car_front_hitbox.shape as SegmentShape2D
	var direction : Vector2 = (segment.b - segment.a).normalized()
	
	# Do acceleration on gas
	if Input.is_action_pressed("up"):
		velocity += direction * acceleration * delta
		
	if Input.is_action_pressed("left"):
		rotation -= 5 * delta
	elif Input.is_action_pressed("right"):
		rotation += 5 * delta
		
	if Input.is_action_pressed("space"):
		velocity.x *= break_friction
		velocity.y *= break_friction
	else:
		if direction.x == 0:
			velocity.x *= friction
		if direction.y == 0:
			velocity.y *= friction
	
	if velocity.x > terminal_velocity:
		velocity.x = terminal_velocity
	elif velocity.x < -1 * terminal_velocity:
		velocity.x = -1 * terminal_velocity
	if velocity.y > terminal_velocity:
		velocity.y = terminal_velocity
	elif velocity.y < -1 * terminal_velocity:
		velocity.y = -1 * terminal_velocity
	
	move_and_slide()
