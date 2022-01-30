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

var anim_mode = "idle"

#main node
var main
var status
var sprite

# timers
# TODO: may not be best here
var animationTimer = 0
var animationTimerMax = 0.2

# set to true whenever player is taking an action (to let animation play out)
var acting = false
var hframes = 4

# TODO: more advanced later
var bag
## TODO TODO TODO: put player on the map, literally!!!!!!!
# Called when the node enters the scene tree for the first time.
func _ready():

	main = self.get_parent()
	status = self.get_node("status_panel")
	bag = self.get_node("bag_display")
	sprite = self.get_node("Sprite")
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
	self.sprite.frame = dir * hframes

## MOVEMENT FUNCTIONS

## TODO: this is way too clunky
# also we need to put offset into this thing

func move_player(d):
	acting = true
	anim_mode = "move"
	animationTimer = animationTimerMax
	pos = pos + global.DIR[d]
	position = main.map2screen(pos)
	self.sprite.position = global.DIR[d] * -global.tileSize
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
	return pos + global.DIR[dir]
	

func animate():
	var resid = self.get_node("Sprite").frame % hframes
	if anim_mode == "idle":
		pass
	elif anim_mode == "move":
		if resid == 3:
			self.sprite.frame -= 3
			self.sprite.position = Vector2(0, 0)
			anim_mode = "idle"
			acting = false
		else:
			## TODO: only have offset if slime can move into space
			self.sprite.frame += 1
			self.sprite.position += 0.25 *global.tileSize * global.DIR[dir]
	elif anim_mode == "attack":
		pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	# countdown animationTimer if it has been set
	# if it reaches 0, reset the clock
	if animationTimer > 0:
		animationTimer = animationTimer - delta

		if animationTimer < 0:
			main.allInputLocked = false
