extends Node

@export var enemy_pool : Node
@export var spawn_points : Array[Node2D]

@export var start_enemies_per_second : float = 0.5
@export var enemies_per_second_increase_rate : float = 0.01

@onready var enemies_per_second : float = start_enemies_per_second
var spawn_rate : float

@onready var spawn_timer : Timer = $SpawnTimer

func _ready():
    spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    _on_spawn_timer_timeout()

func _process(delta):
    enemies_per_second += enemies_per_second_increase_rate * delta
    spawn_rate = 1.0 / enemies_per_second

func _on_spawn_timer_timeout():
    var enemy = enemy_pool.spawn()
    var spawn_point = spawn_points[randi_range(0, len(spawn_points) - 1)].global_position
    enemy.global_position = spawn_point

    spawn_timer.start(spawn_rate)