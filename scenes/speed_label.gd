extends Label

func _process(delta):
	self.text = str(%car.speed / 100) + " MPH"
