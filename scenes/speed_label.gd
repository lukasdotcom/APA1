extends Label

func _process(delta):
	self.text = str(abs(%car.speed / 150)) + " MPH"
