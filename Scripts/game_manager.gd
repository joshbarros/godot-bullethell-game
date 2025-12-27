extends Node2D

var elapsed_time : float

@onready var elapsed_time_text : Label = $CanvasLayer/ElapsedTimeText
@onready var end_screen = $CanvasLayer/EndScreen
@onready var end_text : Label = $CanvasLayer/EndScreen/EndText

func _ready():
	end_screen.visible = false

func _process(delta):
	elapsed_time += delta
	elapsed_time_text.text = "Time: %.1f s" % elapsed_time

func set_game_over():
	get_tree().paused = true
	end_screen.visible = true
	end_text.text = "Game Over!\nTime Survived: %.1f s" % elapsed_time

func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
