extends Node

signal find_spots()
signal reset_spots()

func reset():
	$find_spots_button.visible = true
	$info_prompt.visible = false
	reset_spots.emit()

func _process(delta):
	if %car.gear == 1:
		self.visible = true
	else:
		self.visible = false
		reset()

func _on_find_spots_button_pressed():
	$find_spots_button.visible = false
	$info_prompt.visible = true
	$info_prompt.text = "Valid spots are outlined in orange.
						Invalid spots are outlined in Red.
						
						Select a valid spot to initiate automated parking."
	find_spots.emit()
