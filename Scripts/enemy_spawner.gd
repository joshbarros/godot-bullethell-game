extends Node

@export var enemy_pools : Array[Node]
@export var enemy_spawn_weights : Array[int]
@export var spawn_points : Array[Node2D]

@export var start_enemies_per_second : float = 0.5
@export var enemies_per_second_increase_rate : float = 0.01

@onready var enemies_per_second : float = start_enemies_per_second
var spawn_rate : float

@onready var spawn_timer : Timer = $SpawnTimer

## Initialize spawn timer and trigger first spawn.
## Connects timeout signal and immediately calls spawn function.
func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_on_spawn_timer_timeout()

## Gradually increase enemy spawn rate over time for difficulty scaling.
## Calculates new spawn_rate (1/enemies_per_second) each frame.
## @param delta: Frame delta time used for gradual increase
func _process(delta):
	enemies_per_second += enemies_per_second_increase_rate * delta
	spawn_rate = 1.0 / enemies_per_second

## Select a random enemy type index using weighted random selection.
## Enemies with higher weights in enemy_spawn_weights are more likely.
## Example: weights [10, 1] means 10:1 ratio (normal:boss).
## @return int: Index of the selected enemy pool
func _get_random_enemy_index():
	var total_weight = 0
	for weight in enemy_spawn_weights:
		total_weight += weight

	var rand_value = randi_range(0, total_weight - 1)
	var cumulative_weight = 0

	for i in enemy_spawn_weights.size():
		cumulative_weight += enemy_spawn_weights[i]
		if rand_value < cumulative_weight:
			return i

	return 0  # Fallback, should not reach here

## Spawn an enemy at a random spawn point with weighted type selection.
## Gets enemy from appropriate pool based on _get_random_enemy_index().
## Restarts spawn timer with current spawn_rate.
## Connected to SpawnTimer.timeout signal.
func _on_spawn_timer_timeout():
	var enemy = enemy_pools[_get_random_enemy_index()].spawn()
	var spawn_point = spawn_points[randi_range(0, len(spawn_points) - 1)].global_position
	enemy.global_position = spawn_point

	spawn_timer.start(spawn_rate)