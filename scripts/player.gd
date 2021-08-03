extends Node2D

const UP = 1
const DOWN = 2
const RIGHT = 3
const LEFT = 4

## VARIABLES

#position of player in map coordinates
var pos = Vector2(1, 1)
# direction the player is facing
var dir = 1

# STATS
var hp = 30
var maxhp = 30

var hunger = 100
var maxhunger = 100

#main node
var main

# timers
# TODO: may not be best here
var animationTimer = 0
var animationTimerMax = 0.2

# TODO: more advanced later
var bag = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	main = self.get_parent()

## UTILITY FUNCTIONS
func get_pos():
	return pos

func change_dir(d):
	dir = d
	self.get_node("Sprite").frame = dir - 1

## MOVEMENT FUNCTIONS

func move_up():
	animationTimer = animationTimerMax
	pos.y = pos.y - 1
	position = main.map2screen(pos)
	#print(pos)


func move_down():
	animationTimer = animationTimerMax
	pos.y = pos.y + 1
	position = main.map2screen(pos)
	#print(pos)

func move_left():
	animationTimer = animationTimerMax
	pos.x = pos.x - 1
	position = main.map2screen(pos)
	#print(pos)

func move_right():
	animationTimer = animationTimerMax
	pos.x = pos.x + 1
	position = main.map2screen(pos)
	#print(pos)

## INTERACT FUNCTIONS

func pickup_item(item):
	animationTimer = animationTimerMax
	# put item in bag
	bag.append(item)
	# remove item from world map
	item.get_parent().remove_child(item)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# countdown animationTimer if it has been set
	# if it reaches 0, reset the clock
	if animationTimer > 0:
		animationTimer = animationTimer - delta
		
		if animationTimer < 0:
			main.allInputLocked = false
