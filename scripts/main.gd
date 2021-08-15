extends Node2D

## WHAT THIS SCRIPT DOES
#process player input
#control turn system
#facilitate interaction between entities in world

### CONSTANTS ###

# the length of the side of one tile on the map
# for reference
const tileSize = 32

# button press codes
const PRESS_UP = 1
const PRESS_DOWN = 2
const PRESS_RIGHT = 3
const PRESS_LEFT = 4
const SELECT = 5
const PRESS_UP_LEFT = 6
const PRESS_DOWN_LEFT = 7
const PRESS_UP_RIGHT = 8
const PRESS_DOWN_RIGHT = 9
const INTERACT = 10
const MELEE_ATTACK = 11
const OPEN_BAG = 12

# character direction codes
const FRONT = 0
const FRONT_LEFT = 1
const LEFT = 2
const BACK_LEFT = 3
const BACK = 4
const BACK_RIGHT = 5
const RIGHT = 6
const FRONT_RIGHT = 7

### VARIABLES ###

# TODO: will need more granular locks eventually
# ex. lock player movement, but allow button press to advance text.
# ex. lock player movement, but allow inventory exploration

# set to true to ignore all player input
var allInputLocked = false

# set to true to allow player to turn in place
var turnLocked = false

# options
# overworld, bag, hotbar
var mode = "overworld"


# entities
var player
var map

# Called when the node enters the scene tree for the first time.
func _ready():
	player = self.get_node("player")
	map = self.get_node("map")
	
	player.pos = map.get_open_tile()
	player.position = map2screen(player.pos)

### UTILITY FUNCTIONS ###

# convert screen coordinates to map coordinates
func screen2map(pos):
	return Vector2(int(pos.x/tileSize), int(pos.y/tileSize))

# convert map coordinates to screen coordinates
func map2screen(pos):
	return Vector2(pos.x*32, pos.y*32)

### PLAYER INPUT FUNCTIONS ###
func get_player_input():
	if Input.is_action_just_pressed("ui_turn"):
		turnLocked = true
		print("lock")
	elif Input.is_action_just_released("ui_turn"):
		turnLocked = false
		print("unlock")
	
	if !allInputLocked:
		## TODO: what is priority order for inputs?
		
		if Input.is_action_pressed("ui_up"):
			if Input.is_action_pressed("ui_left"):
				return PRESS_UP_LEFT
			elif Input.is_action_pressed("ui_right"):
				return PRESS_UP_RIGHT
			else:
				return PRESS_UP
		elif Input.is_action_pressed("ui_down"):
			if Input.is_action_pressed("ui_left"):
				return PRESS_DOWN_LEFT
			elif Input.is_action_pressed("ui_right"):
				return PRESS_DOWN_RIGHT
			else:
				return PRESS_DOWN
		elif Input.is_action_pressed("ui_left"):
			return PRESS_LEFT
		elif Input.is_action_pressed("ui_right"):
			return PRESS_RIGHT
		elif Input.is_action_pressed("ui_select"):
			return SELECT
		elif Input.is_action_pressed("ui_interact"):
			return INTERACT
		elif Input.is_action_pressed("ui_attack"):
			return MELEE_ATTACK
		elif Input.is_action_pressed("ui_open_bag"):
			return OPEN_BAG
		else:
			return -1
	else:
		return -1

func input_bag(input):
	# move buttons
	if input == PRESS_UP:
		player.change_dir(BACK)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(0, -1)):
					allInputLocked = true
					player.move_up()
	elif input == PRESS_DOWN:
		player.change_dir(FRONT)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(0, 1)):
					allInputLocked = true
					player.move_down()
	elif input == PRESS_LEFT:
		player.change_dir(LEFT)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(-1, 0)):
					allInputLocked = true
					player.move_left()
	elif input == PRESS_RIGHT:
		player.change_dir(RIGHT)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(1, 0)):
					allInputLocked = true
					player.move_right()
	## TODO: player should not be able to clip corners
	elif input == PRESS_UP_LEFT:
		player.change_dir(BACK_LEFT)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(-1, -1)):
					allInputLocked = true
					player.move_up_left()
	elif input == PRESS_UP_RIGHT:
		player.change_dir(BACK_RIGHT)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(1, -1)):
					allInputLocked = true
					player.move_up_right()
	elif input == PRESS_DOWN_LEFT:
		player.change_dir(FRONT_LEFT)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(-1, 1)):
					allInputLocked = true
					player.move_down_left()
	elif input == PRESS_DOWN_RIGHT:
		player.change_dir(FRONT_RIGHT)
		if not turnLocked:
			if not map.check_for_features(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + Vector2(1, 1)):
					allInputLocked = true
					player.move_down_right()
	# interact
	elif input == SELECT:
		var item = map.check_for_interactive(player.get_pos())
		
		if !(item == null):
			if(item.type == "stairs"):
				map.new_floor()
				player.pos = map.get_open_tile()
				player.position = map2screen(player.pos)
			else:
				allInputLocked = true
				map.itemMap[screen2map(item.position).x][screen2map(item.position).y] = null
				player.pickup_item(item)
	elif input == INTERACT:
		## TODO: this function is general-purpose and needs to be expanded
		# for now, it should just print out whatever item is in front of the player
		# in the future, it will be the function for speaking to entities
		# opening doors/chests, etc
		var w = player.which_tile_facing()
		print(map.itemMap[w.x][w.y])
		print(map.featureMap[w.x][w.y])
		allInputLocked = true
		player.animationTimer = player.animationTimerMax
	elif input == MELEE_ATTACK:
		print("attack")
		var w = player.which_tile_facing()
		allInputLocked = true
		player.animationTimer = player.animationTimerMax
		var i = preload("res://scenes/melee_attack.tscn")
		var at = i.instance()
		self.add_child(at)
		at.position = map2screen(w)
		
		var f = map.check_for_features(w)
		
		if f:
			var feat = map.featureMap[w.x][w.y]
			if feat.type == "tree":
				feat.take_damage(5)
		## TODO: this will be the general purpose function for attacking an enemy with a melee weapon
		# the item in the player's hand will be used to calculate damage
		# non-weapon items will default to 1 damage, but may have additional effects
		# items with the tag "fragile" break if being used this way
		# the action fails if there is no enemy or other entity in the tile the player faces. 
		# in this case, fragile items do not break, and a turn is not used up (we'll be nice)
	elif input == OPEN_BAG:
		mode = "bag"
		player.get_node("bag_display").on_opened()

# called every frame
func _physics_process(delta):
	var input = get_player_input()
	
	## TODO: reformat
	# so, physics process will parse the "modes" of input
	# if the bag is open, it will go to input_bag()
	# if the player is free to move, input_move()
	# etc. 
	# that way we can separate the different input functions neatly
	
	
	# if there was player input, carry it out
	if input > 0:
		if mode == "overworld":
			input_bag(input)
		## TODO: check mode first
		
		
			
