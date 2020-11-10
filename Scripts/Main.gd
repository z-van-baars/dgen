extends Node

onready var width
onready var height

onready var tiles = []

func generate():
	$UILayer/WidthLabel.text = "Width: " + str(width)
	$UILayer/HeightLabel.text = "Height: " + str(height)
	for column in range(height):
		var row = []
		for tile in range(width):
			row.append(0)
		tiles.append(row)
	
	$Dungeon/TileMap.clear()
	var x = 0
	var y = 0
	for column in tiles:
		for tile in column:
			$Dungeon/TileMap.set_cellv(Vector2(x, y), tile)
			x += 1
		y += 1
		x = 0

func _on_MainMenu_set_dungeon_size(d_width, d_height):
	width = d_width
	height = d_height

	generate()
