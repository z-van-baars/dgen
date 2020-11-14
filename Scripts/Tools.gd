extends Node



func get_diagonal_neighbors(width, height, start_tile):
	var neighbors = []
	#Top Left
	neighbors.append(Vector2(start_tile.x - 1, start_tile.y - 1))
	#Top Center
	neighbors.append(Vector2(start_tile.x, start_tile.y - 1))
	#Top Right
	neighbors.append(Vector2(start_tile.x + 1, start_tile.y - 1))
	#Left
	neighbors.append(Vector2(start_tile.x - 1, start_tile.y))
	#Right
	neighbors.append(Vector2(start_tile.x + 1, start_tile.y))
	#Bottom Left
	neighbors.append(Vector2(start_tile.x - 1, start_tile.y + 1))
	#Bottom Center
	neighbors.append(Vector2(start_tile.x, start_tile.y + 1))
	#Bottom Right
	neighbors.append(Vector2(start_tile.x + 1, start_tile.y + 1))
	
	var valid_neighbors = []
	for each in neighbors:
		if each.x >= 0 and each.x < width and each.y >= 0 and each.y < height:
			valid_neighbors.append(each)
	return valid_neighbors

func get_straight_neighbors(width, height, start_tile):
	var neighbors = []
	#Top
	neighbors.append(Vector2(start_tile.x, start_tile.y - 1))
	#Left
	neighbors.append(Vector2(start_tile.x - 1, start_tile.y))
	#Right
	neighbors.append(Vector2(start_tile.x + 1, start_tile.y))
	#Bottom
	neighbors.append(Vector2(start_tile.x, start_tile.y + 1))

	var valid_neighbors = []
	for each in neighbors:
		if each.x >= 0 and each.x < width and each.y >= 0 and each.y < height:
			valid_neighbors.append(each)
	return valid_neighbors
	
func find_open_tiles(tiles):
	var open_tiles = []
	for y in range(0, tiles.size(), 1):
		for x in range(0, tiles[0].size(), 1):
			if tiles[y][x] == 1:
				open_tiles.append(Vector2(x, y))
	return open_tiles
	
func check_area_includes(tiles, x_dim, y_dim, start_x, start_y, tile_ids):
	for y in range(start_y, start_y + y_dim, 1):
		for x in range(start_x, start_x + x_dim, 1):
			if tiles[y][x] in tile_ids:
				return true
	return false

