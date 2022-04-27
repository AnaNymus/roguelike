extends Node2D

const FRONT = 0
const FRONT_LEFT = 1
const LEFT = 2
const BACK_LEFT = 3
const BACK = 4
const BACK_RIGHT = 5
const RIGHT = 6
const FRONT_RIGHT = 7

const hframes = 14

var type = "slime"

var maxhp = 15
var currenthp = 15

# set to true whenever player is taking an action (to let animation play out
var acting = false

var map
var main
var sprite
var global

# the direction the sprite is facing right now
var dir
# governs how the slime animates
# options are: idle, move, attack, death
var anim_mode = "idle"

# Called when the node enters the scene tree for the first time.
func _ready():
	map = self.get_parent().get_parent().get_node("map")
	main = self.get_parent().get_parent()
	sprite = self.get_node("Sprite")
	global = get_node("/root/global")
	
	dir = global.FRONT

func take_damage(dmg):
	currenthp -= dmg
	
	if currenthp <= 0:
		anim_mode = "die"

func take_turn():
	#TODO: make more complex
	acting = true
	if not anim_mode == "die":
		move_random()

func end_action():
	acting = false

func animate():
	var resid = sprite.frame % hframes
	
	if anim_mode == "idle":
		if resid == 0:
			if randi()%3 == 0:
				sprite.frame += 4
		elif resid == 4:
			if randi()%3 == 0:
				sprite.frame += 1
		else:
			if randi()%3 == 0:
				sprite.frame -= 5
	elif anim_mode == "move":
		if resid == 3:
			sprite.frame -= 3
			self.sprite.offset = Vector2(0, 0)
			end_action()
			anim_mode = "idle"
			##TODO end action
		else:
			## TODO: only have offset if slime can move into space
			sprite.frame += 1
			self.sprite.offset += 0.25 *global.tileSize * global.DIR[dir]
	elif anim_mode == "attack":
		if resid == 0:
			sprite.frame += 6
		elif resid < 9:
			sprite.frame += 1
		else:
			sprite.frame -= 9
	elif anim_mode == "die":
		if resid == 0:
			sprite.frame += 10
		elif resid < 14:
			sprite.frame += 1
		else:
			
			# TODO: remove from lists in main
			map.remove_enemy(map.get_parent().screen2map(self.position))


func move_random():
	var pos = main.screen2map(self.position)
	
	var free_dir = []
	for i in range(8):
		if not map.check_midLevel(pos + global.DIR[i]):
			if map.check_pos(pos + global.DIR[i]):
				free_dir.append(i)
	
	if len(free_dir) == 0:
		end_action()
		return
	
	dir = free_dir[randi()%len(free_dir)]
	
	sprite.frame = dir*hframes
	anim_mode = "move"
	if not map.check_midLevel(pos + global.DIR[dir]):
		if map.check_pos(pos + global.DIR[dir]):
			map.move_enemy(pos, pos + global.DIR[dir])
			self.position = main.map2screen(pos + global.DIR[dir])
			self.sprite.offset = global.DIR[dir] * -global.tileSize
