extends Camera2D

@onready var target = $"../Player"
@export var follow_rate : float = 2.0
@export var camera_zoom : float = 3.0  # Higher = more zoomed in

var shake_intensity : float = 0.0

func damage_shake():
    shake_intensity = 8

func _ready():
    # Set zoom level
    zoom = Vector2(camera_zoom, camera_zoom)
    # Start camera centered on player
    global_position = target.global_position

func _process(delta):
    if not is_instance_valid(target):
        return
    global_position = global_position.lerp(target.global_position, follow_rate * delta)

    if shake_intensity > 0:
        shake_intensity = lerpf(shake_intensity, 0, delta * 10)
        offset = _get_random_offset()

func _get_random_offset() -> Vector2:
    var x = randf_range(-shake_intensity, shake_intensity)
    var y = randf_range(-shake_intensity, shake_intensity)
    return Vector2(x, y)