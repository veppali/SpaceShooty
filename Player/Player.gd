extends RigidBody2D

enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null
export (int) var engine_power
export (int) var max_shield
export (float) var shield_regen
export (PackedScene) var Bullet
export (float) var fire_rate

var thrust = Vector2()
var screensize = Vector2()

signal shoot
signal lives_changed
signal dead
signal shield_changed

var shield = 0 setget set_shield
var lives = 0 setget set_lives


var can_shoot = true

# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(ALIVE)
	screensize = get_viewport().get_visible_rect().size
	$GunTimer.wait_time = fire_rate

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.5
		ALIVE:
			$CollisionShape2D.disabled = false
			$Sprite.modulate.a = 1.0
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite.modulate.a = 0.5
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.disabled = true
			$Sprite.hide()
			linear_velocity = Vector2()
			emit_signal("dead")
	state = new_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	self.shield += shield_regen * delta
	
func get_input():
	thrust = Vector2()
	if state in [DEAD, INIT]:
		return#	
	if Input.is_action_pressed("thrust_up"):
		thrust = Vector2(0, -engine_power)
	if Input.is_action_pressed("thrust_down"):
		thrust = Vector2(0, engine_power)
	if Input.is_action_pressed("thrust_back"):
		thrust = Vector2(-engine_power, 0)
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power, 0)#	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
func shoot():
	if state == INVULNERABLE:
		return
	emit_signal("shoot", Bullet, $Muzzle.global_position, rotation)
	can_shoot = false
	$GunTimer.start()
	
func _integrate_forces(physics_state):
	set_applied_force(thrust)	
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screensize.x
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
	physics_state.set_transform(xform)

func _on_GunTimer_timeout():
	can_shoot = true

#sets the shield value and emits signal to the hud to update the shieldbar
func set_shield(value):
	if value > max_shield:
		value = max_shield
	shield = value	
	emit_signal("shield_changed", shield)
	if shield <= 0:
		$Explosion.show()
		$Explosion/AnimationPlayer.play("explosion")
		change_state(INVULNERABLE)
		self.lives -= 1
	
func set_lives(value):
	self.shield = max_shield
	lives = value
	emit_signal("lives_changed", lives)

func start():
	self.shield = max_shield
	$Sprite.show()
	self.lives = 3
	change_state(ALIVE)

func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.hide()

func _on_Player_body_entered(body):
	if body.is_in_group('rocks'):
		body.explode()
#		$Explosion.show()
#		$Explosion/AnimationPlayer.play("explosion")
		self.shield -= 25		
		if lives <= 0:
			change_state(DEAD)
		#else:
		#	change_state(INVULNERABLE)

func _on_InvulnerabilityTimer_timeout():
	change_state(ALIVE)
	

