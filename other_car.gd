extends CharacterBody2D

var state : String = 'parked'
var speed : int = 50000

func _ready():
	$timer.start()
	$sprite.modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))

func _physics_process(delta):
	if state == 'forward':
		var direction = Vector2.UP.rotated(self.rotation)
		self.velocity = speed * direction * delta
		move_and_slide()
	elif state == 'backward':
		var direction = Vector2.DOWN.rotated(self.rotation)
		self.velocity = speed * direction * delta
		move_and_slide()
	else:
		self.velocity = Vector2.ZERO
		move_and_slide()


func _on_timer_timeout():
	if state == 'parked':
		return
	elif state == 'forward':
		state = 'pause1'
		$timer.wait_time = 1
	elif state == 'pause1':
		state = 'backward'
		$timer.wait_time = 3
	elif state == 'backward':
		state = 'pause2'
		$timer.wait_time = 1
	else:
		state = 'forward'
		$timer.wait_time = 3
	
	$timer.start()
