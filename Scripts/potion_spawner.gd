extends Node

@export var potion_scenes : Array[PackedScene]

@export var min_bounds : Vector2
@export var max_bounds : Vector2


## Spawn a random potion type at a random position within bounds.
## Selects from potion_scenes array (health, shoot speed, move speed).
## Position is randomized between min_bounds and max_bounds.
## Connected to SpawnTimer.timeout signal (2 second intervals).
func _on_spawn_timer_timeout() -> void:
	var potion = potion_scenes[randi() % len(potion_scenes)].instantiate()
	add_child(potion)

	var spawn_x = randf_range(min_bounds.x, max_bounds.x)
	var spawn_y = randf_range(min_bounds.y, max_bounds.y)

	potion.global_position = Vector2(spawn_x, spawn_y)
