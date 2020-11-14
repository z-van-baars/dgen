extends Node

signal gen_finished

onready var tools = get_tree().root.get_node("Main/Tools")
onready var rng = RandomNumberGenerator.new()
onready var width
onready var height
onready var tiles = []

onready var large_room_max = 10
onready var medium_room_max = 5
onready var small_room_max = 3
onready var max_retries = 20

onready var hall_disengage_chance = 0

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
			var x_dim = rng.randi_range(
				int(room_data["Max"][each] * 0.6),
				room_data["Max"][each])
			var y_dim = rng.randi_range(
				int(room_data["Max"][each] * 0.6),
				room_data["Max"][each])
			place_room(x_dim, y_dim, each)
	render_tilemap()
	emit_signal("gen_finished", room_data)

func place_room(x_dim, y_dim, room_type):
	var tries = 0
	var placed = false
	while tries < max_retries and not placed:
		var rand_x = rng.randi_range(
			1,
			width - (x_dim + 1))
		var rand_y = rng.randi_range(
			1,
			height - (y_dim + 1))
		
		if not tools.check_area_includes(
			tiles, x_dim, y_dim, rand_x, rand_y, [0, 9]):
			# Tile Type 0 means area is already claimed by another room
			placed = true
			set_room(x_dim, y_dim, rand_x, rand_y)
		else:
			room_data["Failures"][room_type] += 1
		
		tries += 1

func pathable(tile, parent_tile):

	var constructions = [0, 2, -1]
	if tiles[tile.y][tile.x] in constructions or tiles[tile.y][tile.x] == 9:
		return false
	var neighbors = tools.get_straight_neighbors(
		width, height, tile)
	var built_neighbors = 0
	for each in neighbors:
		if tiles[each.y][each.x] in constructions:
			built_neighbors += 1
			if built_neighbors > 1:
				return false
	var diagonal_neighbors = tools.get_diagonal_neighbors(
		width, height, tile)
	
	var built_diagonals = []
	for each in diagonal_neighbors:
		if tiles[each.y][each.x] in constructions:
			built_diagonals.append(each)
			if built_diagonals.size() > 2:
				return false
			elif built_diagonals.size() > 0 and built_diagonals.size() <= 2:
				for diag_neighbor in built_diagonals:
					if diag_neighbor not in tools.get_straight_neighbors(
						width, height, parent_tile):
						return false

	return true

func carve_halls():
	var all_carved = false
	new_hall()

func new_hall():
	var open_tiles = tools.find_open_tiles(tiles)
	var hall_starts = []
	for o_tile in open_tiles:
		if pathable(o_tile):
			hall_starts.append(o_tile)
	if hall_starts.size() == 0:
		return
	var random_start = hall_starts[rng.randi_range(
		0, hall_starts.size() - 1)]
	var frontier = []
	tiles[random_start.y][random_start.x] = 2
	for each in tools.get_straight_neighbors(
		width, height, random_start):
		if pathable(each):
			frontier.append(each)
	var current_tile = random_start
	while frontier.size() != 0:

		if randi()%100 < hall_disengage_chance:
			current_tile = frontier.pop_front()
		else:

			var current_neighbors = tools.get_straight_neighbors(width, height, current_tile)
			var valid_current_neighbors = []
			for each in current_neighbors:
				if pathable(each):
					valid_current_neighbors.append(each)
			if valid_current_neighbors.size() > 0:
				current_tile = valid_current_neighbors[rng.randi_range(0, valid_current_neighbors.size() - 1)]
				frontier.erase(current_tile)
			else:
				current_tile = frontier.pop_front()

		tiles[current_tile.y][current_tile.x] = 2
		for each in tools.get_straight_neighbors(
			width, height, current_tile):
			if pathable(each):
				frontier.append(each)

		var new_frontier = []
		for each in frontier:
			if pathable(each):
				new_frontier.append(each)
		frontier = new_frontier
		


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


func _on_RegenButton_pressed():
	clear()
	generate_rooms()
	carve_halls()
	render_tilemap()



func _input(event):
	if event.is_action_pressed("space"):
		carve_halls()
		render_tilemap()
