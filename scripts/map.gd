extends Node2D


# the tilemap object
var tilemap
var items
var static_tiles

# the size of the map (# of tiles in each direction)
var mapSize

# an array detailing what items are in what cells
var itemMap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	# TODO: later, once we sort out map generation, we will 
	# set this based on generated map size
	mapSize = Vector2(50, 50)
	
	get_new_map(mapSize)
	items = self.get_node("items")
	
	static_tiles = self.get_node("static_tiles")
	
	
	itemMap = create_2d_array(mapSize)
	# set items in place
	gen_items(5)
	place_stairs()

## UTILITY FUNCTIONs ##

# builds an empty 2D array
# used for keeping track of item locations and whatnot
func create_2d_array(size):
	var a = []
	
	for x in range(size.x):
		a.append([])
		a[x].resize(size.y)
		
	return a
	

# returns TRUE if space can be moved into
# returns FALSE if space is wall
# TODO: also return false if space is occupied by another entity
func check_pos(pos):
	var t = tilemap.get_cellv(pos)
	if t == 0:
		return true
	elif t == 1:
		return false
	else:
		return false

# checks item map for interactive elements (items, etc.)
func check_for_interactive(pos):
	# TODO: there will be multiple classes of interactive item later
	# but for now, only items
	return itemMap[pos.x][pos.y]

func get_new_map(size):
	var i = preload("res://scenes/map_generator.tscn")
	
	var mg = i.instance()
	mg.generate_map(size, 3, 4, 8)
	
	var m = mg.get_node("TileMap")
	m.get_parent().remove_child(m)
	
	self.add_child(m)
	tilemap = m
	
	


# randomly places NUM items on accessible areas of the floor
# TODO: later, this should take a dictionary of item IDs and
# the number of each that should be placed
# for now, it will just place the generic item "item"
func gen_items(num):
	var countdown = num
	var i = preload("res://scenes/item.tscn")
	
	while countdown > 0:
		var vec = Vector2(randi()%int(mapSize.x), randi()%int(mapSize.y))
		
		if check_pos(vec):
			#TODO check that map elements don't overlap
			
			var item = i.instance()
			items.add_child(item)
			item.position = tilemap.map_to_world(vec)
			itemMap[vec.x][vec.y] = item
			countdown -= 1
	
func place_stairs():
	# TODO: keep things from overlapping!!!
	var vec = get_open_tile()
	#static_tiles.get_node("up_stairs").position = tilemap.map_to_world(vec)
	#static_tiles.get_node("up_stairs").setas_up()
	#itemMap[vec.x][vec.y] = static_tiles.get_node("up_stairs")
	
	vec = get_open_tile()
	static_tiles.get_node("down_stairs").position = tilemap.map_to_world(vec)
	static_tiles.get_node("down_stairs").setas_down()
	itemMap[vec.x][vec.y] = static_tiles.get_node("down_stairs")
	


func get_open_tile():
	while true:
		var vec = Vector2(randi()%int(mapSize.x), randi()%int(mapSize.y))
		if check_pos(vec):
			return vec
