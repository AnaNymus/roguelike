extends Node2D

const NORTH = 0
const SOUTH = 1
const EAST = 2
const WEST = 3

var map

var params

#var f

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	map = self.get_node("TileMap")
	generate_map(Vector2(80, 60), 3, 4, 8)


# generate map of size sz
# connectivity c
# mindim minD
# maxdim maxD
func generate_map(sz, c, minD, maxD):
	params = {
		"mapsize": sz - Vector2(1, 1),
		"connectivity": c,
		"minDim": minD,
		"maxDim": maxD
		}
	
	for x in range(sz.x):
		for y in range(sz.y):
			map.set_cellv(Vector2(x, y), 1)
	
	# generate first feature: a room set randomly in the available space
	var x_sz = (randi()%(maxD-minD)) + minD
	var y_sz = (randi()%(maxD-minD)) + minD
	print(str(x_sz) + " " + str(y_sz))
	
	
	# this is the position of the top left corner
	#var x_pos = (randi()%(int(sz.x - x_sz)))
	#var y_pos = (randi()%(int(sz.y - y_sz)))
	var x_pos = int(sz.x/2)
	var y_pos = int(sz.y/2)
	
	var feat = {
		"type": "room",
		"top": y_pos,
		"bottom": y_pos + y_sz,
		"left": x_pos,
		"right": x_pos + x_sz
	}
	
	draw_feature(feat)
	
	var f = propagate(feat)
	
	print(get_percent_open())

# feat is feature
# params is dict of sz, c, minD, maxD
func propagate(feat):
	# repeat to the degree of connectivity
	#var cont = true
	#while cont:
	for i in range(params["connectivity"]):
		#yield(get_tree().create_timer(0.2), "timeout")
		
		# pick a wall
		var face
		
		var newFeat = {
			"type":"none"
			}
		
		if feat["type"] == "room":
			# we can build on any of the 4 faces
			face = randi()%4
			
			# 90% chance corridor, 10% chance room
			var t = randi()%10
			
			if t == 0: # make it a room
				newFeat["type"] = "room"
				
				var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
				
				#place it on the side of the old feature
				if face == NORTH:
					var top = feat["top"] - 1 - size.y
					var bottom = feat["top"] - 1
					
					var left = randi()%(int(feat["right"] - (feat["left"] - size.x + 1))) + feat["left"] - size.x + 1
					var right = left + size.x
					
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
					
				elif face == SOUTH:
					var top = feat["bottom"] + 1
					var bottom = feat["bottom"] + 1 + size.y
					
					var left = randi()%(int(feat["right"] - (feat["left"] - size.x + 1))) + feat["left"] - size.x + 1
					var right = left + size.x
					
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
				elif face == EAST:
					var top = randi()%(int(feat["bottom"] - (feat["top"] - size.y + 1))) + feat["top"] - size.y + 1
					var bottom = top + size.y
					
					var left = feat["right"] + 1
					var right = left + size.x
					
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
					
				elif face == WEST:
					var top = randi()%(int(feat["bottom"] - (feat["top"] - size.y + 1))) + feat["top"] - size.y + 1
					var bottom = top + size.y
					
					var right = feat["left"] - 1
					var left = right - size.x
					
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
				
				
			else: # make new feat a corridor
				if face == NORTH or face == SOUTH:
					newFeat["type"] = "corridor_NS"
					
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					var left = randi()%(int(feat["right"] - feat["left"])) + feat["left"]
					
					if face == NORTH:
						var top = feat["top"]-1-length
						var bottom = feat["top"] - 1
						
						newFeat["top"] = top
						newFeat["bottom"] = bottom
						
						newFeat["left"] = left
						newFeat["right"] = left
						
						
					elif face == SOUTH:
						var top = feat["bottom"]+1
						var bottom = feat["bottom"]+1+length
						
						newFeat["top"] = top
						newFeat["bottom"] = bottom
					
						newFeat["left"] = left
						newFeat["right"] = left
					
					
				else:
					newFeat["type"] = "corridor_EW"
					
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					var top = randi()%(int(feat["bottom"]-feat["top"])) + feat["top"]
					
					if face == EAST:
						var left = feat["right"] + 1
						var right = feat["right"] + 1 + length
						
						newFeat["top"] = top
						newFeat["bottom"] = top
					
						newFeat["left"] = left
						newFeat["right"] = right
						
					elif face == WEST:
						var left = feat["left"] - 1 - length
						var right = feat["left"] - 1
						
						newFeat["top"] = top
						newFeat["bottom"] = top
					
						newFeat["left"] = left
						newFeat["right"] = right
						
				
			
			
		elif feat["type"] == "corridor_NS":
			face = randi()%4
			
			if face == NORTH:
				
				# let's say that there's a 75% chance of a room ending a corridor
				# otherwise, it's another corridor
				if randi()%4 == 1: # corridor, can be NS or EW (but more likely EW
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					if randi()%4 == 1:
						newFeat["type"] = "corridor_NS"
						
						newFeat["top"] = feat["top"] - 1 - length
						newFeat["bottom"] = feat["top"] - 1
						
						newFeat["left"] = feat["left"]
						newFeat["right"] = feat["left"]
						
						
					else:
						newFeat["type"] = "corridor_EW"
						
						var left = feat["left"] - randi()%(length)
						
						newFeat["top"] = feat["top"] - 1
						newFeat["bottom"] = feat["top"] - 1
						
						newFeat["left"] = left
						newFeat["right"] = left + length
						
				else: # room
					newFeat["type"] = "room"
					
					var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
					
					var left = feat["left"] - randi()%int(size.x)
					var right = left + size.x
					
					var bottom = feat["top"] - 1
					var top = bottom - size.y
					
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
				
				
			elif face == SOUTH:
				# let's say that there's a 75% chance of a room ending a corridor
				# otherwise, it's another corridor
				if randi()%4 == 1: # corridor, can be NS or EW (but more likely EW
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					if randi()%4 == 1:
						newFeat["type"] = "corridor_NS"
						
						newFeat["top"] = feat["bottom"] + 1
						newFeat["bottom"] = feat["bottom"] + 1 + length
						
						newFeat["left"] = feat["left"]
						newFeat["right"] = feat["left"]
						
					else:
						newFeat["type"] = "corridor_EW"
						
						var left = feat["left"] - randi()%(length)
						
						newFeat["top"] = feat["bottom"] + 1
						newFeat["bottom"] = feat["bottom"] + 1
					
						newFeat["left"] = left
						newFeat["right"] = left + length
						
					
					
				else: # room
					newFeat["type"] = "room"
					
					var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
					
					var left = feat["left"] - randi()%int(size.x)
					var right = left + size.x
					
					var bottom = feat["top"] + 1 + size.y
					var top = feat["top"] + 1 
					
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
			elif face == EAST:
				## TODO: something is wrong with this
				
				#EW corridor is the only option
				newFeat["type"] = "corridor_EW"
				var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
				
				var left = feat["left"] + 1
				var right = left + length
				
				var top = randi()%(int(feat["bottom"] - feat["top"])) + feat["top"]
				var bottom = top
				
				newFeat["top"] = top
				newFeat["bottom"] = bottom
				
				newFeat["left"] = left
				newFeat["right"] = right
				
			elif face == WEST:
				## TODO: something is wrong with this
				
				#EW corridor is the only option
				newFeat["type"] = "corridor_EW"
				var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
				
				var right = feat["left"] - 1
				var left = right - length
				
				var top = randi()%(int(feat["bottom"] - feat["top"])) + feat["top"]
				var bottom = top
				
				newFeat["top"] = top
				newFeat["bottom"] = bottom
					
				newFeat["left"] = left
				newFeat["right"] = right
			
		elif feat["type"] == "corridor_EW":
			face = randi()%4
			
			if face == NORTH:
				# NS corridor is only option
				newFeat["type"] = "corridor_NS"
				var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
				
				var bottom = feat["top"]-1
				var top = bottom - length
				
				var left = randi()%(int(feat["right"] - feat["left"])) + feat["left"]
				
				newFeat["top"] = top
				newFeat["bottom"] = bottom
				
				newFeat["left"] = left
				newFeat["right"] = left
				
			elif face == SOUTH:
				newFeat["type"] = "corridor_NS"
				var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
				
				var top = feat["top"] + 1
				var bottom = top + length
				
				var left = randi()%(int(feat["right"] - feat["left"])) + feat["left"]
				
				newFeat["top"] = top
				newFeat["bottom"] = bottom
				
				newFeat["left"] = left
				newFeat["right"] = left
				
				
			elif face == EAST:
				# let's say that there's a 75% chance of a room ending a corridor
				# otherwise, it's another corridor
				if randi()%4 == 1: # corridor, can be NS or EW (but more likely EW
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					if randi()%4 == 1:
						newFeat["type"] = "corridor_EW"
						
						newFeat["top"] = feat["top"]
						newFeat["bottom"] = feat["top"]
						
						newFeat["left"] = feat["left"] + 1
						newFeat["right"] = feat["left"] + 1 + length
						
					else:
						newFeat["type"] = "corridor_NS"
						
						var top = feat["top"] - randi()%length
						
						newFeat["top"] = top
						newFeat["bottom"] = top + length
						
						newFeat["left"] = feat["left"] + 1
						newFeat["right"] = feat["left"] + 1
						
					
					
				else: # room
					newFeat["type"] = "room"
					
					var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
					
					var left = feat["right"] + 1
					var right = left + size.x
					
					var top = feat["top"] - randi()%int(size.y)
					var bottom = top + size.y
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
			elif face == WEST:
				# let's say that there's a 75% chance of a room ending a corridor
				# otherwise, it's another corridor
				if randi()%4 == 1: # corridor, can be NS or EW (but more likely EW
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					if randi()%4 == 1:
						newFeat["type"] = "corridor_EW"
						
						newFeat["top"] = feat["top"]
						newFeat["bottom"] = feat["top"]
						
						newFeat["left"] = feat["left"] - 1 - length
						newFeat["right"] = feat["left"] - 1
						
					else:
						newFeat["type"] = "corridor_NS"
						
						var top = feat["top"] - randi()%length
						
						newFeat["top"] = top
						newFeat["bottom"] = top + length
						
						newFeat["left"] = feat["left"] - 1
						newFeat["right"] = feat["left"] - 1
					
					
				else: # room
					newFeat["type"] = "room"
					
					var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
					
					var right = feat["right"] - 1
					var left = right - size.x
					
					var top = feat["top"] - randi()%int(size.y)
					var bottom = top + size.y
					
					newFeat["top"] = top
					newFeat["bottom"] = bottom
					
					newFeat["left"] = left
					newFeat["right"] = right
		
		# now we have a new feature described
		# we need to check that it will fit into the described space
		# TODO: we could, to increase connectivity, allow a small percentage of overlaps
		# to still be drawn. tbd
		if check_overlap(newFeat):
			draw_feature(newFeat)
			#cont = false
			#return newFeat
			var t = propagate(newFeat)
	return true


# checks the area feat will occupy,
# returns true if it is all wall
# returns false if there are already features in it
func check_overlap(feat):
	if feat["left"] < 0 or feat["top"] < 0 or feat["right"] >= params["mapsize"].x or feat["bottom"] >= params["mapsize"].y:
		return false
	
	
	for x in range(feat["left"], feat["right"] + 1):
		for y in range(feat["top"], feat["bottom"] + 1):
			if map.get_cellv(Vector2(x, y)) == 0:
				return false
	return true

#draws the given feature to the map
func draw_feature(feat):
	for x in range(feat["left"], feat["right"] + 1):
		for y in range(feat["top"], feat["bottom"] + 1):
			map.set_cellv(Vector2(x, y), 0)
	
	

# returns the percentage of tiles that are open squares
func get_percent_open():
	var sum = 0
	
	for x in range(params["mapsize"].x):
		for y in range(params["mapsize"].y):
			if map.get_cellv(Vector2(x, y)) == 0:
				sum = sum + 1
	
	return sum/(params["mapsize"].x * params["mapsize"].y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		print(get_percent_open())
	
