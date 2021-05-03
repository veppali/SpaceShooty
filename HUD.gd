extends CanvasLayer
signal start_game

onready var lives_counter = [$MarginContainer/ScoreCounter/LivesCounter/L1, $MarginContainer/ScoreCounter/LivesCounter/L2, $MarginContainer/ScoreCounter/LivesCounter/L3]
onready var ShieldBar = $MarginContainer/ScoreCounter/ShieldBar
var red_bar = preload("res://assets/shield_red.png")
var blue_bar = preload("res://assets/shield_blue.png")

func update_shield(value):
	value = value
	ShieldBar.texture_progress = blue_bar
	if value < 40:		
		ShieldBar.texture_progress = red_bar		
	ShieldBar.value = value

func show_message(message):
	$MessageLabel.text = message
	$MessageLabel.show()
	$MessageTimer.start()
	
func update_score(value):
	$MarginContainer/ScoreCounter/Scorelabel.text = str(value)	
	
func update_lives(value):
	for item in range(3):
		lives_counter[item].visible = value > item
	 
func game_over():
	show_message("Game over")
	yield($MessageTimer, "timeout")
	$StartButton.show()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")


func _on_MessageTimer_timeout():
	$MessageLabel.hide()
	$MessageLabel.text = ''
