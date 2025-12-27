extends Control

## Handle quit button press to exit the game.
## Closes the entire application.
## Connected to QuitButton.pressed signal in menu.tscn.
func _on_quit_button_pressed() -> void:
	get_tree().quit()

## Handle play button press to start the game.
## Transitions from menu scene to main game scene.
## Connected to PlayButton.pressed signal in menu.tscn.
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
