extends Camera2D

@onready var target = $"../Player"
@export var follow_rate : float = 2.0
@export var camera_zoom : float = 3.0  # Higher = more zoomed in

func _ready():
    # Set zoom level
    zoom = Vector2(camera_zoom, camera_zoom)
    # Start camera centered on player
    global_position = target.global_position

func _process(delta):
    if not is_instance_valid(target):
        return
    global_position = global_position.lerp(target.global_position, follow_rate * delta)