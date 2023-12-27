extends TileMap


const TILE_SIZE: int = 128

@export var width: int
@export var height: int

var playing = false
var dead_cell_atlas_index = 0
var live_cell_atlas_index = 1
var temp_field

func _ready() -> void:
	var width_px: int = width * TILE_SIZE
	var height_px: int = height * TILE_SIZE

	var camera = $Camera2D
	camera.position = Vector2(width_px, height_px) / 2

	temp_field = []
	for x in range(width):
		var temp_row = []
		for y in range(height):
			set_cell(0, Vector2(x, y), dead_cell_atlas_index, Vector2i(0, 0))
			temp_row.append(dead_cell_atlas_index)
		temp_field.append(temp_row)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_play"):
		playing = !playing
	if event.is_action_pressed("click"):
		var pos = (get_local_mouse_position() / TILE_SIZE).floor()  # get clicked tile
		var atlas_id = get_cell_source_id(0, pos)
		if atlas_id == dead_cell_atlas_index:
			set_cell(0, pos, live_cell_atlas_index, Vector2i(0, 0))
		else:
			set_cell(0, pos, dead_cell_atlas_index, Vector2i(0, 0))

func _process(delta: float) -> void:
	update_field()

func update_field():
	if not playing:
		return
	for x in range(width):
		for y in range(height):
			var live_neighbors = 0
			for x_offset in [-1, 0, 1]:
				for y_offset in [-1, 0, 1]:
					if x_offset != y_offset or x_offset != 0:
						var neighbor_cell_atlas_id = get_cell_source_id(0, Vector2(x + x_offset, y + y_offset))
						if neighbor_cell_atlas_id == live_cell_atlas_index:
							live_neighbors += 1

			var current_cell_atlas_id = get_cell_source_id(0, Vector2(x, y))
			if current_cell_atlas_id == live_cell_atlas_index:
				if live_neighbors in [2, 3]:
					temp_field[x][y] = 1
				else:
					temp_field[x][y] = 0
			else:  # current cell is dead
				if live_neighbors == 3:
					temp_field[x][y] = 1
				else:
					temp_field[x][y] = 0

	for x in range(width):
		for y in range(height):
			if temp_field[x][y] == dead_cell_atlas_index:
				set_cell(0, Vector2(x, y), dead_cell_atlas_index, Vector2i(0, 0))
			else:
				set_cell(0, Vector2(x, y), live_cell_atlas_index, Vector2i(0, 0))
