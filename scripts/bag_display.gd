extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var itemlist
var pockets

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	itemlist = self.get_node("ItemList")
	pockets = self.get_node("pockets")
	
	pockets.add_item("botannicals")
	pockets.add_item("materials")
	pockets.add_item("melee weapons")
	pockets.add_item("range weapons")
	pockets.add_item("ammunition")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func new_item(item):
	itemlist.add_item(item.type)

func on_opened():
	self.visible = true
	itemlist.grab_focus()

func _on_close_pressed():
	self.visible = false
	self.get_parent().get_parent().mode = "overworld"
	# TODO: unlock parent controls
	



func _on_ItemList_item_activated(index):
	print(index)
	print(itemlist.get_item_text(index))
	



func _on_pockets_item_activated(index):
	print(pockets.get_item_text(index))
