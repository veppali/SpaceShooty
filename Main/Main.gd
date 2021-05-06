extends Node2D

var screensize = Vector2()
var level = 0
var score = 0
var playing = false


export (PackedScene) var Rock
export (PackedScene) var Enemy
export (PackedScene) var ExtraLife
# Called when the node enters the scene tree for the first time.

func new_game():
	for rock in $Rocks.get_children():
		rock.queue_free()
	level = 0
	score = 0
	#$HUD.update_score(score)
	$Player.start()
	$HUD.show_message("Get Ready")
	yield($HUD/MessageTimer, "timeout")
	playing = true
	new_level()
	
func new_level():
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in range(level):
		spawn_rock(3)	
	$EnemyTimer.wait_time = rand_range(5, 10)
	$EnemyTimer.start()
		
func _process(delta):
	if playing and $Rocks.get_child_count() == 0:
		new_level()
		
func game_over():
	playing = false
	$HUD.game_over()

func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	for i in range (3):
		spawn_rock(3)

func spawn_rock(size, pos=null, vel=null):
	if !pos:
		$RockPath/RockSpawn.set_offset(randi())
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1, 0).rotated(rand_range(0, 2*PI)) * rand_range(100, 150)
	var r = Rock.instance()
	r.screensize = screensize
	r.start(pos, vel, size)
	$Rocks.call_deferred("add_child",r)
	r.connect('exploded', self, '_on_Rock_exploded')
	
func _on_Player_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos, dir)
	add_child(b)


func _on_Rock_exploded(size, radius, pos, vel):
	if size <=1:
		return
	for offset in [-1, 1]:
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size -1, newpos, newvel)

func pause_game():
	get_tree().paused = true
	$HUD/MessageLabel.text ="Paused"
	$HUD/MessageLabel.show()
	
func continue_game():
	$HUD/MessageLabel.text = ""
	$HUD/MessageLabel.hide()
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			continue_game()
		else:
			pause_game()

func spawn_health(extralife, pos):
	var h = extralife.instance()
	h.start(pos)
	call_deferred("add_child", h)
	

func _on_EnemyTimer_timeout():
	var e = Enemy.instance()
	add_child(e)
	e.target = $Player
	e.connect('shoot', self, '_on_Player_shoot')
	e.connect('spawn_health', self, 'spawn_health')	
	$EnemyTimer.wait_time = rand_range(10, 20)
	$EnemyTimer.start()
