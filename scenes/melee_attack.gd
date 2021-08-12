extends Sprite


const FRAMERATE = 0.1

var animationTimer = 0
var nframes = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	self.frame = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	animationTimer += delta
	
	if animationTimer >=FRAMERATE:
		animationTimer = 0
		
		if self.frame < nframes-1:
			self.frame += 1
		else:
			self.get_parent().remove_child(self)
