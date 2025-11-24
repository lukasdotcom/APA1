extends Node

signal find_spots()
signal reset_spots()

var selected_space = null
var show : bool = false
var searching : bool = true

func reset():
	$yes_button.visible = false
	$info_prompt.text = "Searching for a valid spot..."
	self.selected_space = null
	self.searching = true
	reset_spots.emit()

func toggle():
	self.reset()
	%view.points = []
	if self.show:
		self.show = false
		self.visible = false
	else:
		self.show = true
		self.visible = true

func _process(delta):
	if self.searching and self.show:
		find_spots.emit()

func confirm_path(space):
	$info_prompt.text = "Confirm Displayed Path?"
	$yes_button.visible = true
	self.selected_space = space

func _on_yes_button_pressed():
	$"../car".build_path(self.selected_space)
	$yes_button.visible = false
	self.selected_space.set_outline_color('green')
	self.searching = false
	$info_prompt.text = "Executing Parking Maneuver..."

func collision():
	self.reset()
	self.searching = false
	$"info_prompt".text = "ERROR: OBSTRUCTION DETECTED"
	await get_tree().create_timer(3).timeout
	self.reset()
	self.searching = true
