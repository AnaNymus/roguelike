extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var itemlist
var pockets

# which pocket are we displaying currently?
var display_mode = "botannicals"

var botannicals = {"apple": 1, "dandelion": 2, "fern": 3}
var materials = {"stick": 5, "rock": 5}
var weapons = {"sword": 1}

var global
var player

var current_item

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	itemlist = self.get_node("ItemList")
	pockets = self.get_node("pockets")
	global = get_node("/root/global")
	player = self.get_parent()
	
	pockets.add_item("botannicals")
	pockets.add_item("materials")
	pockets.add_item("weapons")
	
	reset_itemlist()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func new_item(item):
	itemlist.add_item(item.type)

func reset_itemlist():
	itemlist.clear()
	
	var d = get_pocket()
	
	for i in d.keys():
		itemlist.add_item(i)
	

func get_pocket():
	if display_mode == "botannicals":
		return botannicals
	elif display_mode == "materials":
		return materials
	elif display_mode == "weapons":
		return weapons

func has_bot(t):
	if botannicals.has(t):
		return true
	else:
		return false

func has_mat(t):
	if materials.has(t):
		return true
	else:
		return false

func has_wp(t):
	if weapons.has(t):
		return true
	else:
		return false



func on_opened():
	self.visible = true
	itemlist.grab_focus()

func _on_close_pressed():
	self.visible = false
	self.get_parent().get_parent().mode = "overworld"

func _on_ItemList_item_activated(index):
	var d = get_pocket()
	var name = itemlist.get_item_text(index)
	
	self.get_node("info/num_items").text = "In bag: " + str(d[itemlist.get_item_text(index)])
	self.get_node("info/item_name").text = name
	
	var i
	
	if display_mode == "botannicals":
		i = global.botannical
		self.get_node("info/flavor_text").text = i[name].flavor_text
		self.get_node("info/effects").text = i[name].effect
		self.get_node("info/item").texture = load(i[name].large_sprite)
	elif display_mode == "materials":
		i = global.material
		self.get_node("info/flavor_text").text = i[name].flavor_text
		self.get_node("info/effects").text = ""
		if i[name].tags.has("thrown"):
			self.get_node("info/effects").text += ("It can be thrown for " + str(i[name].throwing_damage) + " damage. ")
		if i[name].tags.has("fragile"):
			self.get_node("info/effects").text += "It looks like it would break easily. "
		self.get_node("info/item").texture = load(i[name].large_sprite)
		
	elif display_mode == "weapons":
		i = global.weapon
	
	current_item = i[name]
	



func _on_pockets_item_activated(index):
	display_mode = pockets.get_item_text(index)
	reset_itemlist()
	


func _on_use_pressed():
	var d = get_pocket()
	var item_num = d[current_item.type]
	
	if item_num > 0:
	
		if current_item.pocket == "botannical":
			if current_item.effect == "restore hunger":
				player.restore_hunger(10)
				d[current_item.type] -= 1
			elif current_item.effect == "restore hp":
				player.restore_hp(3)
				d[current_item.type] -= 1
		elif current_item.pocket == "material":
			print("use this in crafting!")
	
	else:
		print("You don't have any of those!")
	
