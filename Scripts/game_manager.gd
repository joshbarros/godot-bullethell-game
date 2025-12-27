extends Node2D

var elapsed_time : float

@onready var elapsed_time_text : Label = $CanvasLayer/ElapsedTimeText
@onready var end_screen = $CanvasLayer/EndScreen
@onready var end_text : Label = $CanvasLayer/EndScreen/EndText

## Initialize game state by hiding the end screen.
## Called once when the main scene loads.
func _ready():
	end_screen.visible = false

## Track elapsed game time and update UI display.
## Runs every frame to accumulate time survived.
## @param delta: Frame delta time to add to elapsed_time
func _process(delta):
	elapsed_time += delta
	elapsed_time_text.text = "Time: %.1f s" % elapsed_time

## Trigger game over state, pause game, and show end screen.
## Called by player.gd when player HP reaches 0.
## Uses get_tree().paused to stop all gameplay (except UI with process_mode=3).
func set_game_over():
	get_tree().paused = true
	end_screen.visible = true
	end_text.text = "Game Over!\nTime Survived: %.1f s" % elapsed_time

## Handle retry button press to restart the game.
## Unpauses the game tree and reloads the main scene.
## Connected to RetryButton.pressed signal in main.tscn.
func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
