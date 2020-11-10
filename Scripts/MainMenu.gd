extends Control

signal set_dungeon_size

onready var width = 100
onready var height = 100

func _ready():
	get_tree().paused = true


func _on_ReadyButton_pressed():
	if not check_input($WidthField.text) or not check_input($HeightField.text):
		width = 100
		height = 100
		$WidthField.text = ""
		$WidthField.placeholder_text = "100"
		$HeightField.text = ""
		$HeightField.placeholder_text = "100"
		return
	else:
		width = int($WidthField.text)
		height = int($HeightField.text)
		hide()
		get_tree().paused = false
		emit_signal("set_dungeon_size", width, height)
	

func check_input(input_text):
	if not int(input_text) is int:
		$Message.text = "Please enter a whole number between 1 and 200."
		return false
	else:
		return true
		
