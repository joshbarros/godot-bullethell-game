extends CharacterBody2D

@export var current_hp : int = 50
@export var max_hp : int = 50

@export var max_speed : float = 100.0
@export var acceleration : float = 0.2
@export var braking : float = 0.15

@export var shoot_rate : float = 0.1
var last_shoot_time : float = 0.0

@onready var sprite : Sprite2D = $Sprite
@onready var muzzle = $Muzzle
@onready var bullet_pool = $PlayerBulletPool
@onready var health_bar : ProgressBar = $HealthBar

@onready var shoot_audio : AudioStreamPlayer = $"../ShootAudio"
@onready var damaged_audio : AudioStreamPlayer = $"../DamagedAudio"
@onready var potion_audio : AudioStreamPlayer = $"../PotionAudio"

var move_input : Vector2
var additional_bullet_speed : float
var game_over : bool = false

## Initialize player health bar with max values.
## Called once when the node enters the scene tree.
func _ready():
	health_bar.max_value = max_hp
	health_bar.value = current_hp

var bullet_scene : PackedScene = preload("res://Scenes/bullet.tscn")

## Handle player movement with WASD input.
## Uses lerp for smooth acceleration and braking.
## Stops processing if game is over.
## @param _delta: Frame delta time (unused, movement uses lerp weights)
func _physics_process(_delta):
	if game_over:
		return
	
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if move_input.length() > 0:
		velocity = velocity.lerp(move_input * max_speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, braking)

	move_and_slide()

## Handle sprite flipping, shooting input, and wobble animation.
## Runs every frame to check for mouse position and shoot action.
## @param _delta: Frame delta time (unused in current implementation)
func _process(_delta):
	if game_over:
		return
	
	sprite.flip_h = get_global_mouse_position().x > global_position.x

	if Input.is_action_pressed("shoot"):
		if Time.get_unix_time_from_system() - last_shoot_time > shoot_rate:
			_shoot()

	_move_wobble()

## Create a subtle wobble effect on the player sprite during movement.
## Uses sin wave based on system time for smooth oscillation.
## Resets rotation to 0 when player is stationary.
func _move_wobble():
	if move_input.length() == 0:
		sprite.rotation_degrees = 0
		return
	
	var t = Time.get_unix_time_from_system()
	var rot = sin(t * 20) * 2
	
	sprite.rotation_degrees = rot

## Spawn a bullet from the object pool and shoot it toward the mouse cursor.
## Applies additional bullet speed from power-ups and plays shoot sound.
## Respects shoot_rate cooldown (tracked by last_shoot_time).
func _shoot():
	last_shoot_time = Time.get_unix_time_from_system()

	var bullet = bullet_pool.spawn()

	bullet.global_position = muzzle.global_position
	
	# Set bullet direction towards mouse
	var direction = (get_global_mouse_position() - muzzle.global_position).normalized()
	bullet.move_dir = direction
	bullet.additional_speed = additional_bullet_speed

	shoot_audio.play()

## Handle player taking damage from enemies or enemy bullets.
## Triggers game over if HP reaches 0, otherwise plays damage feedback.
## @param damage: Amount of HP to subtract from current_hp
func take_damage(damage : int):
	current_hp -= damage

	if current_hp <= 0:
		game_over = true
		get_tree().get_first_node_in_group("GameManager").set_game_over()
	else:
		_damage_flash()
		health_bar.value = current_hp
		damaged_audio.play()
		$"../Camera2D".damage_shake()

## Visual feedback for player taking damage.
## Briefly flashes the sprite red for 0.1 seconds then returns to white.
## Uses async/await for timing.
func _damage_flash():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

## Restore player health from health potions.
## Clamps current_hp to max_hp to prevent overhealing.
## Updates health bar UI to reflect new HP.
## @param amount: HP to restore (typically 20)
func heal(amount : int):
	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp
	
	health_bar.value = current_hp

## Play sound effect when collecting any potion type.
## Called by potion.gd after applying potion effects.
func drink_potion():
	potion_audio.play()
