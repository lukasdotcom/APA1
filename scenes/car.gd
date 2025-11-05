extends CharacterBody2D

var acceleration : int = 500
var max_speed : int = 5000
var friction : float = .98
var break_friction : float = .92
var speed : int = 0
var rotation_speed : int = 1
var gear : int = 0
	
func _physics_process(delta):
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
	
	move_and_slide()
