extends Camera2D

@onready var target = $"../Player"
@export var follow_rate : float = 2.0
@export var camera_zoom : float = 3.0  # Higher = more zoomed in

var shake_intensity : float = 0.0

## Trigger camera shake effect for damage feedback.
## Sets shake_intensity to 8, which decays over time in _process().
## Called by player.gd when player takes damage.
func damage_shake():
	shake_intensity = 8

## Initialize camera zoom and starting position.
## Centers camera on player at game start.
func _ready():
	# Set zoom level
	zoom = Vector2(camera_zoom, camera_zoom)
	# Start camera centered on player
	global_position = target.global_position

## Smoothly follow player with lerp and apply screen shake effect.
## Only runs if target (player) is still valid (prevents "previously freed" error).
## Shake effect uses random offset that decays over time.
## @param delta: Frame delta time for lerp and shake decay
func _process(delta):
	if not is_instance_valid(target):
		return
	global_position = global_position.lerp(target.global_position, follow_rate * delta)

	if shake_intensity > 0:
		shake_intensity = lerpf(shake_intensity, 0, delta * 10)
		offset = _get_random_offset()

## Generate random camera offset for shake effect.
## Creates random x/y values within shake_intensity range.
## @return Vector2: Random offset for camera shake
func _get_random_offset() -> Vector2:
	var x = randf_range(-shake_intensity, shake_intensity)
	var y = randf_range(-shake_intensity, shake_intensity)
	return Vector2(x, y)