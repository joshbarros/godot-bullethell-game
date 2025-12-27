extends Area2D

@export var speed : float = 200.0
@export var owner_group : String
@onready var destroy_timer : Timer = $DestroyTimer

var additional_speed : float = 0

var move_dir : Vector2

## Move bullet in its assigned direction and rotate sprite to match.
## Adds speed + additional_speed (from shoot speed potion) for velocity.
## @param delta: Frame delta time for movement calculation
func _process(delta):
	translate(move_dir * (speed + additional_speed) * delta)

	rotation = move_dir.angle()

## Handle bullet collision with player or enemies.
## Ignores collision with owner (prevents friendly fire).
## Calls take_damage(1) on hit target and hides bullet (returns to pool).
## @param body: The CharacterBody2D that entered the bullet's Area2D
func _on_body_entered(body):
	if body.is_in_group(owner_group):
		return
		
	if body.has_method("take_damage"):
		body.take_damage(1)
	
	visible = false

## Auto-destroy bullet after timeout if it doesn't hit anything.
## Hides bullet (returns to pool) to prevent infinite bullets.
## Connected to DestroyTimer.timeout signal.
func _on_destroy_timer_timeout():
	visible = false

## Reset bullet state when spawned from pool or returned to pool.
## Starts destroy timer when bullet becomes visible.
## Resets additional_speed to 0 for fresh state.
## Connected to visibility_changed signal.
func _on_visibility_changed():
	if visible == true and destroy_timer:
		destroy_timer.start()
		additional_speed = 0