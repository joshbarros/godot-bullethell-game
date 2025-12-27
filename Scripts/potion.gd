extends Area2D

## Potion types with different effects.
## HEALTH: Restores player HP
## SHOOT_SPEED: Increases fire rate and bullet speed
## MOVE_SPEED: Increases player movement speed
enum PotionType {
	HEALTH,
	SHOOT_SPEED,
	MOVE_SPEED
}

@export var type : PotionType
@export var value : float

## Create pulsing scale animation for visual feedback.
## Uses sin wave for smooth oscillation (±10% scale change).
## @param delta: Frame delta time (unused, uses system time)
func _process(delta):
	var t = Time.get_unix_time_from_system()
	var s = 1 + (sin(t * 10) * 0.1)

	scale.x = s
	scale.y = s

## Handle player collision with potion to apply effects.
## Checks if colliding body is in "Player" group.
## Applies effect based on potion type, plays sound, and destroys potion.
## @param body: The CharacterBody2D that entered the potion's Area2D
func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return

	if type == PotionType.HEALTH:
		body.heal(value)
	if type == PotionType.SHOOT_SPEED:
		body.shoot_rate /= value
		body.additional_bullet_speed += value
	if type == PotionType.MOVE_SPEED:
		body.max_speed *= value

	body.drink_potion()
	
	queue_free()
