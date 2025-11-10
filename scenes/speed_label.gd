extends Label

func _process(delta):
	self.text = str(%car.speed / 200) + " MPH"
