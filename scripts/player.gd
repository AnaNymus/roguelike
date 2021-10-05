extends Node2D

const FRONT = 0
const FRONT_LEFT = 1
const LEFT = 2
const BACK_LEFT = 3
const BACK = 4
const BACK_RIGHT = 5
const RIGHT = 6
const FRONT_RIGHT = 7

## VARIABLES

#position of player in map coordinates
var pos = Vector2(1, 1)
# direction the player is facing
var dir = FRONT

# STATS
var hp = 30
var maxhp = 30

var hunger = 100
var maxhunger = 100

const HUNGER_TURNS = 5
var hungerCounter = 0

#main node
var main
var status

# timers
# TODO: may not be best here
var animationTimer = 0
var animationTimerMax = 0.2

# TODO: more advanced later
var bag

# Called when the node enters the scene tree for the first time.
func _ready():

	main = self.get_parent()
	status = self.get_node("status_panel")
	bag = self.get_node("bag_display")
	update_status_panel()


## UTILITY FUNCTIONS
func get_pos():
	return pos

## STATUS UPDATE FUNCTIONS
func update_status_panel():
	status.get_node("hp_label").text = "HP: " + str(hp) + " / " + str(maxhp)
	status.get_node("hunger_label").text = "Hunger: " + str(hunger) + " / " + str(maxhunger)

# when an action is performed, make hunger tick down by one
# TODO: when hunger = 0, what happens?
func hunger_tick():
	hungerCounter += 1

	if hungerCounter >= HUNGER_TURNS:
		hungerCounter = 0
		hunger = hunger - 1

	if hunger <= 0:
		hunger = 0
		# DO SOMETHING ELSE

	update_status_panel()

func restore_hunger(a):
	hunger = hunger + a
	if hunger > maxhunger:
		hunger = maxhunger
	update_status_panel()

func restore_hp(a):
	hp = hp + a
	if hp > maxhp:
		hp = maxhp
	update_status_panel()

func change_dir(d):
	dir = d
	self.get_node("Sprite").frame = dir

## MOVEMENT FUNCTIONS

func move_up():
	animationTimer = animationTimerMax
	pos.y = pos.y - 1
	position = main.map2screen(pos)
	hunger_tick()
	#print(pos)


func move_down():
	animationTimer = animationTimerMax
	pos.y = pos.y + 1
	position = main.map2screen(pos)
	hunger_tick()
	#print(pos)

func move_left():
	animationTimer = animationTimerMax
	pos.x = pos.x - 1
	position = main.map2screen(pos)
	hunger_tick()
	#print(pos)

func move_right():
	animationTimer = animationTimerMax
	pos.x = pos.x + 1
	position = main.map2screen(pos)
	hunger_tick()
	#print(pos)

func move_up_right():
	animationTimer = animationTimerMax
	pos.x = pos.x + 1
	pos.y = pos.y - 1
	position = main.map2screen(pos)
	hunger_tick()

func move_down_right():
	animationTimer = animationTimerMax
	pos.x = pos.x + 1
	pos.y = pos.y + 1
	position = main.map2screen(pos)
	hunger_tick()

func move_up_left():
	animationTimer = animationTimerMax
	pos.x = pos.x - 1
	pos.y = pos.y - 1
	position = main.map2screen(pos)
	hunger_tick()

func move_down_left():
	animationTimer = animationTimerMax
	pos.x = pos.x - 1
	pos.y = pos.y + 1
	position = main.map2screen(pos)
	hunger_tick()

## INTERACT FUNCTIONS

func pickup_item(item):
	animationTimer = animationTimerMax
	
	# put item in bag
	# TODO: item details should be stored in main
	if item.pocket == "botannical":
		if bag.has_bot(item.type):
			bag.botannicals[item.type] += 1
		else:
			bag.botannicals[item.type] = 1
	elif item.pocket == "material":
		if bag.has_mat(item.type):
			bag.materials[item.type] += 1
		else:
			bag.materials[item.type] = 1
	elif item.pocket == "weapon":
		if bag.has_wp(item.type):
			bag.weapons[item.type] += 1
		else:
			bag.weapons[item.type] = 1
	# remove item from world map
	item.get_parent().remove_child(item)

	hunger_tick()

# returns the pos of the tile directly in front of player
func which_tile_facing():
	if dir == FRONT:
		return pos + Vector2(0, 1)
	elif dir == FRONT_LEFT:
		return pos + Vector2(-1, 1)
	elif dir == LEFT:
		return pos + Vector2(-1, 0)
	elif dir == BACK_LEFT:
		return pos + Vector2(-1, -1)
	elif dir == BACK:
		return pos + Vector2(0, -1)
	elif dir == BACK_RIGHT:
		return pos + Vector2(1, -1)
	elif dir == RIGHT:
		return pos + Vector2(1, 0)
	elif dir == FRONT_RIGHT:
		return pos + Vector2(1, 1)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	# countdown animationTimer if it has been set
	# if it reaches 0, reset the clock
	if animationTimer > 0:
		animationTimer = animationTimer - delta

		if animationTimer < 0:
			main.allInputLocked = false
