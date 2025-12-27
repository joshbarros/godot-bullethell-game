extends CharacterBody2D

@export var current_hp : int = 5
@export var max_hp : int = 5

@export var max_speed : float
@export var acceleration : float
@export var drag : float

@export var stop_range : float

@export var shoot_rate : float
var last_shoot_time : float
@export var shoot_range : float

@export var flip_sprite : bool = false

@onready var avoidance_ray : RayCast2D = $AvoidanceRay
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var sprite : Sprite2D = $Sprite
@onready var bullet_pool = $EnemyBulletPool
@onready var muzzle = $Muzzle
@onready var health_bar : ProgressBar = $HealthBar

var damaged_audio : AudioStreamPlayer

var player_dist : float
var player_dir : Vector2

## Initialize enemy health bar and connect visibility signal for object pooling.
## Gets reference to damaged audio from Main scene.
## Called once when enemy spawns or respawns from pool.
func _ready():
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	visibility_changed.connect(_on_visibility_changed)
	
	# Get the DamagedAudio from Main scene
	damaged_audio = get_tree().root.get_node("Main/DamagedAudio")

## Track player position, flip sprite, check shooting range, and animate.
## Only runs when enemy is visible and player reference is valid.
## Updates player_dist and player_dir for use in physics_process.
## @param delta: Frame delta time (unused in current implementation)
func _process(delta):
	if not visible:
		return
	
	if not is_instance_valid(player):
		return
	
	player_dist = global_position.distance_to(player.global_position)
	player_dir = global_position.direction_to(player.global_position)

	if flip_sprite:
		sprite.flip_h = player_dir.x > 0
	else:
		sprite.flip_h = player_dir.x < 0

	if player_dist < shoot_range:
		if Time.get_unix_time_from_system() - last_shoot_time > shoot_rate:
			_shoot()
	
	_move_wobble()

## Handle enemy movement with player tracking and obstacle avoidance.
## Applies acceleration toward player or avoidance direction.
## Uses drag to slow down when near player (stop_range).
## @param delta: Frame delta time (unused, uses direct velocity modification)
func _physics_process(delta):
	if not player:
		return
	
	var move_dir = player_dir
	var local_avoidance = _local_avoidance()

	if local_avoidance.length() > 0:
		move_dir = local_avoidance

	if velocity.length() < max_speed and player_dist > stop_range:
		velocity += move_dir * acceleration
	else:
		velocity *= drag
	
	move_and_slide()

## Calculate avoidance direction to prevent enemies from getting stuck on obstacles.
## Uses a raycast toward player to detect collisions with walls/obstacles.
## Returns perpendicular direction to obstacle if detected.
## @return Vector2: Avoidance direction (Vector2.ZERO if no obstacle)
func _local_avoidance() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO
	
	avoidance_ray.target_position = to_local(player.global_position).normalized()
	avoidance_ray.target_position *= 80

	if not avoidance_ray.is_colliding():
		return Vector2.ZERO
	
	var obstacle = avoidance_ray.get_collider()

	if obstacle == player:
		return Vector2.ZERO
	
	var obstacle_point = avoidance_ray.get_collision_point()
	var obstacle_dir = global_position.direction_to(obstacle_point)

	return Vector2(-obstacle_dir.y, obstacle_dir.x)

## Spawn a bullet from the enemy's object pool and shoot toward player.
## Respects shoot_rate cooldown (tracked by last_shoot_time).
## Bullet direction is calculated from muzzle position to player position.
func _shoot():
	last_shoot_time = Time.get_unix_time_from_system()

	var bullet = bullet_pool.spawn()
	bullet.global_position = muzzle.global_position

	bullet.move_dir = muzzle.global_position.direction_to(player.global_position)

## Create a subtle wobble effect on the enemy sprite during movement.
## Uses sin wave based on system time for smooth oscillation.
## Resets rotation to 0 when enemy is stationary.
func _move_wobble():
	if velocity.length() == 0:
		sprite.rotation_degrees = 0
		return
	
	var t = Time.get_unix_time_from_system()
	var rot = sin(t * 20) * 2
	
	sprite.rotation_degrees = rot

## Handle enemy taking damage from player bullets.
## Hides enemy (returns to pool) if HP reaches 0, otherwise plays damage feedback.
## @param damage: Amount of HP to subtract from current_hp
func take_damage(damage : int):
	current_hp -= damage

	if current_hp <= 0:
		visible = false
	else:
		_damage_flash()
		if damaged_audio:
			damaged_audio.play()
		health_bar.value = current_hp

## Visual feedback for enemy taking damage.
## Briefly flashes the sprite black for 0.1 seconds then returns to white.
## Uses async/await for timing.
func _damage_flash():
	sprite.modulate = Color.BLACK
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

## Handle enemy respawning from object pool or being returned to pool.
## When visible: Enable processing, reset HP and health bar.
## When hidden: Disable processing, move off-screen to prevent collisions.
## Connected to visibility_changed signal in _ready().
func _on_visibility_changed():
	if visible:
		set_process(true)
		set_physics_process(true)

		current_hp = max_hp
		health_bar.value = current_hp
	else:
		set_process(false)
		set_physics_process(false)

		global_position = Vector2(0, 999999)
