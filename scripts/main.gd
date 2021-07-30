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

### VARIABLES ###

# TODO: will need more granular locks eventually
# ex. lock player movement, but allow button press to advance text.
# ex. lock player movement, but allow inventory exploration

# set to true to ignore all player input
var allInputLocked = false



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
	if !allInputLocked:
		## TODO: what is priority order for inputs?
		
		if Input.is_action_pressed("ui_up"):
			return PRESS_UP
		elif Input.is_action_pressed("ui_down"):
			return PRESS_DOWN
		elif Input.is_action_pressed("ui_left"):
			return PRESS_LEFT
		elif Input.is_action_pressed("ui_right"):
			return PRESS_RIGHT
		elif Input.is_action_pressed("ui_select"):
			return SELECT
		else:
			return -1
	else:
		return -1



# called every frame
func _physics_process(delta):
	var input = get_player_input()
	
	# if there was player input, carry it out
	if input > 0:
		
		## TODO: check mode first
		
		# move buttons
		if input == PRESS_UP:
			if map.check_pos(player.get_pos() + Vector2(0, -1)):
				allInputLocked = true
				player.move_up()
		elif input == PRESS_DOWN:
			if map.check_pos(player.get_pos() + Vector2(0, 1)):
				allInputLocked = true
				player.move_down()
		elif input == PRESS_LEFT:
			if map.check_pos(player.get_pos() + Vector2(-1, 0)):
				allInputLocked = true
				player.move_left()
		elif input == PRESS_RIGHT:
			if map.check_pos(player.get_pos() + Vector2(1, 0)):
				allInputLocked = true
				player.move_right()
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
					player.pickup_item(item)
			
