extends Node

signal gen_finished

onready var rng = RandomNumberGenerator.new()
onready var width
onready var height
onready var tiles = []

onready var large_room_max = 10
onready var medium_room_max = 5
onready var small_room_max = 3
onready var max_retries = 20

onready var room_data = {
	"Number": {"Large": 1,
			   "Medium": 2,
			   "Small": 3},
	"Max": {"Large": 12,
			"Medium": 9,
			"Small": 5},
	"Failures": {"Large": 0,
				 "Medium": 0,
				 "Small": 0}}

func _ready():
	rng.randomize()


func clear():
	$UILayer/WidthLabel.text = "Width: " + str(width)
	$UILayer/HeightLabel.text = "Height: " + str(height)
	room_data["Number"]["Large"] = int(width / 20)
	room_data["Number"]["Medium"] = int(width / 15)
	room_data["Number"]["Small"] = int(width / 2)
	tiles = []
	for each in ["Large",
				 "Medium",
				 "Small"]:
		room_data["Failures"][each] = 0

	for column in range(height):
		var row = []
		for tile in range(width):
			row.append(1)
		tiles.append(row)
	for tile in range(0, height, 1):
		tiles[tile][0] = 9
		tiles[tile][width - 1] = 9
	for tile in range(0, width, 1):
		tiles[0][tile] = 9
		tiles[height - 1][tile] = 9
	$Dungeon/TileMap.clear()

func generate_rooms():
	for each in ["Large",
				 "Medium",
				 "Small"]:
					
		for ii in range(room_data["Number"][each]):
			print(each)
			var tries = 0
			var placed = false
			var x_dim = rng.randi_range(
				int(room_data["Max"][each] * 0.6),
				room_data["Max"][each])
			var y_dim = rng.randi_range(
				int(room_data["Max"][each] * 0.6),
				room_data["Max"][each])

			while tries < max_retries and not placed:
				print("try")
				var rand_x = rng.randi_range(
					1,
					width - (x_dim + 1))
				var rand_y = rng.randi_range(
					1,
					height - (y_dim + 1))
				
				if check_area(x_dim, y_dim, rand_x, rand_y):
					print("Success")
					placed = true
					set_room(x_dim, y_dim, rand_x, rand_y)
				else:
					room_data["Failures"][each] += 1
					print("Failure")
				
				tries += 1
			
	render_tilemap()
	emit_signal("gen_finished", room_data)

func get_neighbors(start_tile):
	var neighbors = []
	neighbors.append(Vector2(start_tile.x - 1, start_tile.y - 1))
	neighbors.append(Vector2(start_tile.x, start_tile.y - 1))
	neighbors.append(Vector2(start_tile.x + 1, start_tile.y - 1))
	neighbors.append(Vector2(start_tile.x - 1, start_tile.y))
	neighbors.append(Vector2(start_tile.x + 1, start_tile.y))
	neighbors.append(Vector2(start_tile.x - 1, start_tile.y + 1))
	neighbors.append(Vector2(start_tile.x, start_tile.y + 1))
	neighbors.append(Vector2(start_tile.x + 1, start_tile.y + 1))
	
	var valid_neighbors = []
	for each in neighbors:
		if each.x >= 0 and each.x < width and each.y >= 0 and each.y < height:
			valid_neighbors.append(each)
	return valid_neighbors

func find_open_tiles():
	var open_tiles = []
	for y in range(0, height, 1):
		for x in range(0, width, 1):
			if tiles[y][x] == 1:
				open_tiles.append(Vector2(x, y))
	return open_tiles


func pathable(tile):
	var neighbors = get_neighbors(tile)
	for each in neighbors:
		if tiles[each.y][each.x] == 1:
			return true
	return false

func carve_halls():
	var all_carved = false
	while not all_carved:
		var open_tiles = find_open_tiles()
		
		var random_start = open_tiles[rng.randi_range(0, open_tiles.size() - 1)]
		var frontier = []
		tiles[random_start.y][random_start.x] = 0
		for each in get_neighbors(random_start):
			if pathable(each):
				frontier.append(each)
		var current_tile = random_start
		while not frontier.size() == 0:
			current_tile = frontier.pop_front()
			for each in get_neighbors(current_tile):
				if pathable(each):
					frontier.append(each)
		render_tilemap()


func cull_halls():
	pass


func set_room(x_dim, y_dim, start_x, start_y):
	for y in range(start_y, start_y + y_dim, 1):
		for x in range(start_x, start_x + x_dim, 1):
			tiles[y][x] = 0
	for y in range(start_y - 1, start_y + y_dim + 1, 1):
		tiles[y][start_x - 1] = 9
		tiles[y][start_x + x_dim] = 9
	for x in range(start_x - 1, start_x + x_dim + 1, 1):
		tiles[start_y - 1][x] = 9
		tiles[start_y + y_dim][x] = 9


func render_tilemap():
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
	clear()
	generate_rooms()
	carve_halls()
	render_tilemap()

func check_area(x_dim, y_dim, start_x, start_y):
	for y in range(start_y, start_y + y_dim, 1):
		for x in range(start_x, start_x + x_dim, 1):
			if tiles[y][x] != 1:
				return false
	return true

func _on_RegenButton_pressed():
	clear()
	generate_rooms()
	carve_halls()
	render_tilemap()
