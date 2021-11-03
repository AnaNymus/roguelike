extends Node2D


# the tilemap object
var tilemap
var items
var static_tiles
var throw_border
var enemies

# the size of the map (# of tiles in each direction)
var mapSize

# an array detailing what items are in what cells
var groundLevel # the "floor": entities that the player can step on
var midLevel # the level that the player is on. Player cannot step on or over entites on this level

# Called when the node enters the scene tree for the first time.
func _ready():
	throw_border = self.get_node("throw_border")
	
	randomize()
	# TODO: later, once we sort out map generation, we will 
	# set this based on generated map size
	mapSize = Vector2(50, 50)
	
	get_new_map(mapSize)
	items = self.get_node("items")
	static_tiles = self.get_node("static_tiles")
	enemies = self.get_parent().get_node("enemies")
	
	groundLevel = create_2d_array(mapSize)
	midLevel = create_2d_array(mapSize)
	# set items in place
	gen_items(5)
	gen_features(5)
	gen_enemies(5)
	place_stairs()

# NOTE: retains old map size
func new_floor():
	# delete old floor
	self.remove_child(self.get_node("TileMap"))
	
	# delete remaining items
	delete_items()
	delete_features()
	delete_enemies()
	groundLevel = create_2d_array(mapSize)
	midLevel = create_2d_array(mapSize)
	
	# generate new floorplan
	get_new_map(mapSize)
	
	# place new items
	gen_items(5)
	gen_features(5)
	gen_enemies(5)
	# place new stairs
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
	

func place_player(pos):
	midLevel[pos.x][pos.y] = "player"

func move_player(pos, newpos):
	midLevel[pos.x][pos.y] = null
	midLevel[newpos.x][newpos.y] = "player"

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

func check_midLevel(pos):
	var t = midLevel[pos.x][pos.y]
	if t == null:
		return false
	else:
		return true

# checks item map for interactive elements (items, etc.)
func check_for_interactive(pos):
	# TODO: there will be multiple classes of interactive item later
	# but for now, only items
	return groundLevel[pos.x][pos.y]

func get_new_map(size):
	var i = preload("res://scenes/map_generator.tscn")
	
	var mg = i.instance()
	mg.generate_map(size, 3, 4, 8)
	
	var m = mg.get_node("TileMap")
	m.get_parent().remove_child(m)
	
	self.add_child(m)
	tilemap = m
	
func move_enemy(pos, newpos):
	midLevel[newpos.x][newpos.y] = midLevel[pos.x][pos.y]
	midLevel[pos.x][pos.y] = null
	

func delete_items():
	for item in items.get_children():
		item.get_parent().remove_child(item)

func delete_features():
	for feat in static_tiles.get_children():
		if not feat.type == "stairs":
			feat.get_parent().remove_child(feat)

## TODO: actually make this work
func delete_enemies():
	for enemy in enemies.get_children():
		enemy.get_parent().remove_child(enemy)

func remove_feature(pos):
	var feat = midLevel[pos.x][pos.y]
	midLevel[pos.x][pos.y] = null
	static_tiles.remove_child(feat)

func remove_enemy(pos):
	var enemy = midLevel[pos.x][pos.y]
	midLevel[pos.x][pos.y] = null
	enemies.remove_child(enemy)

# randomly places NUM items on accessible areas of the floor
# TODO: later, this should take a dictionary of item IDs and
# the number of each that should be placed
# for now, it will just place the generic item "item"
func gen_items(num):
	var countdown = num
	var i = preload("res://scenes/item.tscn")
	
	for x in range(num):
		var vec = get_open_tile()
		var item = i.instance()
		
		var r = randi()%5
		
		if r == 0:
			item.set_item_type("apple")
			item.set_pocket("botannical")
			item.set_sprite("res://sprites/apple.png")
		elif r == 1:
			item.set_item_type("dandelion")
			item.set_pocket("botannical")
			item.set_sprite("res://sprites/dandelion.png")
		elif r == 2:
			item.set_item_type("rock")
			item.set_pocket("material")
			item.set_sprite("res://sprites/rock.png")
		elif r == 3:
			item.set_item_type("stick")
			item.set_pocket("material")
			item.set_sprite("res://sprites/stick.png")
		else:
			item.set_item_type("fern")
			item.set_pocket("botannical")
			item.set_sprite("res://sprites/fern.png")
			
		items.add_child(item)
		item.position = tilemap.map_to_world(vec)
		groundLevel[vec.x][vec.y] = item
		countdown -= 1

func gen_features(num):
	var countdown = num
	var i = preload("res://scenes/feature.tscn")
	
	for x in range(num):
		var vec = get_open_tile()
		var item = i.instance()
		static_tiles.add_child(item)
		item.position = tilemap.map_to_world(vec)
		midLevel[vec.x][vec.y] = item
		countdown -= 1

## TODO: make this work
func gen_enemies(num):
	var i = preload("res://scenes/slime.tscn")
	
	for x in range(num):
		var vec = get_open_tile()
		var enemy = i.instance()
		enemies.add_child(enemy)
		enemy.position = tilemap.map_to_world(vec)
		midLevel[vec.x][vec.y] = enemy


func place_stairs():
	# TODO: keep things from overlapping!!!
	var vec = get_open_tile()
	#static_tiles.get_node("up_stairs").position = tilemap.map_to_world(vec)
	#static_tiles.get_node("up_stairs").setas_up()
	#groundLevel[vec.x][vec.y] = static_tiles.get_node("up_stairs")
	static_tiles.get_node("down_stairs").position = tilemap.map_to_world(vec)
	static_tiles.get_node("down_stairs").setas_down()
	groundLevel[vec.x][vec.y] = static_tiles.get_node("down_stairs")
	


func get_open_tile():
	while true:
		var vec = Vector2(randi()%int(mapSize.x), randi()%int(mapSize.y))
		if check_pos(vec):
			if check_for_interactive(vec) == null:
				if not check_midLevel(vec):
					return vec
