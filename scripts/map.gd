extends Node2D


# the tilemap object
var tilemap
var items

# the size of the map (# of tiles in each direction)
var mapSize

# an array detailing what items are in what cells
var itemMap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	tilemap = self.get_node("TileMap")
	items = self.get_node("items")
	
	# TODO: later, once we sort out map generation, we will 
	# set this based on generated map size
	mapSize = Vector2(31, 18)
	
	itemMap = create_2d_array(mapSize)
	# set items in place
	gen_items(5)

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
	
	
