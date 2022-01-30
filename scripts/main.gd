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

const PRESS_DOWN = 1
const PRESS_DOWN_LEFT = 2
const PRESS_LEFT = 3
const PRESS_UP_LEFT = 4
const PRESS_UP = 5
const PRESS_UP_RIGHT = 6
const PRESS_RIGHT = 7
const PRESS_DOWN_RIGHT = 8

const SELECT = 9
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

# how often to update animations
const framerate = 0.1

### VARIABLES ###

# TODO: will need more granular locks eventually
# ex. lock player movement, but allow button press to advance text.
# ex. lock player movement, but allow inventory exploration

# set to true to ignore all player input
var allInputLocked = false
# set to true when it is the enemies' turn
var enemyLocked = false
# set to true to allow player to turn in place
var turnLocked = false

# options
# overworld, bag, hotbar
var mode = "overworld"

# timer to control animation things
var animation_timer = 0.0
# things that have an animate() function that should be called
var animated_entities = []

# keeps track of all entities that are taking some sort of turn
# all should have a variable "acting" that is set to true when 
# they are performing an action
# enemyLocked is set to true when actions are being performed
# and is set to false once all entities in entities with actions 
# have acting = false
var entities_with_actions = []

# entities
var player
var map
var global
var enemies

# Called when the node enters the scene tree for the first time.
func _ready():
	global = get_node("/root/global")
	player = self.get_node("player")
	map = self.get_node("map")
	enemies = self.get_node("enemies")
	
	player.pos = map.get_open_tile()
	map.place_player(player.pos)
	player.position = map2screen(player.pos)
	entities_with_actions.append(player)
	animated_entities.append(player)
	
	## TODO: add player to entities_with_actions
	
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
	
	# TODO: debug to remove later
	if Input.is_action_pressed("debug_initiate_throw"):
		mode = "throw"
		map.throw_border.visible = true
		map.throw_border.position = map2screen(player.which_tile_facing())
		# TODO: make border visible 
	if Input.is_action_pressed("debug_end_throw"):
		mode = "overworld"
		map.throw_border.visible = false
	
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

func input_move(input):
	# move buttons
	if input >= PRESS_DOWN and input <= PRESS_DOWN_RIGHT:
		var dir = input - 1
		player.change_dir(dir)
		if not turnLocked:
			if not map.check_midLevel(player.which_tile_facing()):
				if map.check_pos(player.get_pos() + global.DIR[dir]):
					allInputLocked = true
					map.move_player(player.get_pos(), player.which_tile_facing())
					player.move_player(dir)
					enemy_turn()
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
				map.groundLevel[screen2map(item.position).x][screen2map(item.position).y] = null
				player.pickup_item(item)
				enemy_turn()
	elif input == INTERACT:
		## TODO: this function is general-purpose and needs to be expanded
		# for now, it should just print out whatever item is in front of the player
		# in the future, it will be the function for speaking to entities
		# opening doors/chests, etc
		var w = player.which_tile_facing()
		print(map.groundLevel[w.x][w.y])
		print(map.midLevel[w.x][w.y])
		allInputLocked = true
		player.animationTimer = player.animationTimerMax
		enemy_turn()
	elif input == MELEE_ATTACK:
		print("attack")
		var w = player.which_tile_facing()
		allInputLocked = true
		player.animationTimer = player.animationTimerMax
		var i = preload("res://scenes/melee_attack.tscn")
		var at = i.instance()
		self.add_child(at)
		at.position = map2screen(w)
		
		var f = map.check_midLevel(w)
		
		if f:
			var feat = map.midLevel[w.x][w.y]
			if feat.type == "tree":
				feat.take_damage(5)
			elif feat.type == "slime":
				feat.take_damage(5)
		enemy_turn()
		## TODO: this will be the general purpose function for attacking an enemy with a melee weapon
		# the item in the player's hand will be used to calculate damage
		# non-weapon items will default to 1 damage, but may have additional effects
		# items with the tag "fragile" break if being used this way
		# the action fails if there is no enemy or other entity in the tile the player faces. 
		# in this case, fragile items do not break, and a turn is not used up (we'll be nice)
	elif input == OPEN_BAG:
		mode = "bag"
		player.get_node("bag_display").on_opened()

func input_throw(input):
	## TODO: cap the distance from player, make variable based on object and player stats
	var max_distance = 6
	
	var throw_pos = screen2map(map.throw_border.position)
	
	if input == PRESS_UP:
		var d = sqrt(pow(player.pos.x - throw_pos.x, 2) + pow(player.pos.y - (throw_pos.y - 1), 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(0, -1))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax
	elif input == PRESS_DOWN:
		var d = sqrt(pow(player.pos.x - throw_pos.x, 2) + pow(player.pos.y - (throw_pos.y + 1), 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(0, 1))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax
	elif input == PRESS_LEFT:
		var d = sqrt(pow(player.pos.x - (throw_pos.x - 1), 2) + pow(player.pos.y - throw_pos.y, 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(-1, 0))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax
	elif input == PRESS_RIGHT:
		var d = sqrt(pow(player.pos.x - (throw_pos.x + 1), 2) + pow(player.pos.y - throw_pos.y, 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(1, 0))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax
	elif input == PRESS_UP_LEFT:
		var d = sqrt(pow(player.pos.x - (throw_pos.x - 1), 2) + pow(player.pos.y - (throw_pos.y - 1), 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(-1, -1))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax
	elif input == PRESS_UP_RIGHT:
		var d = sqrt(pow(player.pos.x - (throw_pos.x + 1), 2) + pow(player.pos.y - (throw_pos.y - 1), 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(1, -1))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax
	elif input == PRESS_DOWN_LEFT:
		var d = sqrt(pow(player.pos.x - (throw_pos.x - 1), 2) + pow(player.pos.y - (throw_pos.y + 1), 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(-1, 1))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax
	elif input == PRESS_DOWN_RIGHT:
		var d = sqrt(pow(player.pos.x - (throw_pos.x + 1), 2) + pow(player.pos.y - (throw_pos.y + 1), 2))
		
		if d < max_distance:
			map.throw_border.position += map2screen(Vector2(1, 1))
			allInputLocked = true
			player.animationTimer = player.animationTimerMax

func enemy_turn():
	enemyLocked = true
	for x in enemies.get_children():
		x.take_turn()

# called every frame
func _physics_process(delta):
	var input = get_player_input()
	
	## TODO: reformat
	# so, physics process will parse the "modes" of input
	# if the bag is open, it will go to input_bag()
	# if the player is free to move, input_move()
	# etc. 
	# that way we can separate the different input functions neatly
	
	#check to see if player input can be processed
	if enemyLocked:
		var unlock = true
		for e in entities_with_actions:
			if e.acting:
				unlock = false
		
		if unlock:
			enemyLocked = false
	
	if not enemyLocked:
	# if there was player input, carry it out
		if input > 0:
			if mode == "overworld":
				input_move(input)
			elif mode == "throw":
				input_throw(input)
		## TODO: check mode first
		
	
	## handle animation things
	animation_timer += delta
	if animation_timer >= framerate:
		animation_timer = 0
		for entity in animated_entities:
			entity.animate()
	
