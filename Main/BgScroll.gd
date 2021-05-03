extends TextureRect

export(float) var scroll_speed = 0.005

# Called when the node enters the scene tree for the first time.
func _ready():
	self.material.set_shader_param("scroll_speed", scroll_speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
