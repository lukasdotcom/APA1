extends Label

func _process(delta):
	match %car.gear:
		0:
			text = "DRIVE"
		1:
			text = "PARK"
		2:
			text = "REVERSE"
		_:
			text = "ERROR"
