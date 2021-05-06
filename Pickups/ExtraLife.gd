extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(pos):
	print_debug("life_debug_start")
	position = pos
# Called every frame. 'delta' is the elapsed time since the previous frame.

	
func _on_ExtraLife_body_entered(body):
	if body.is_in_group('rocks'):
		body.explode()
		queue_free()
	if body.name == 'Player':
		body.lives += 1
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
