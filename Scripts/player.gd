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

var move_input : Vector2
var additional_bullet_speed : float
var game_over : bool = false

func _ready():
	health_bar.max_value = max_hp
	health_bar.value = current_hp

var bullet_scene : PackedScene = preload("res://Scenes/bullet.tscn")

func _physics_process(_delta):
	if game_over:
		return
	
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if move_input.length() > 0:
		velocity = velocity.lerp(move_input * max_speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, braking)

	move_and_slide()

func _process(_delta):
	if game_over:
		return
	
	sprite.flip_h = get_global_mouse_position().x > global_position.x

	if Input.is_action_pressed("shoot"):
		if Time.get_unix_time_from_system() - last_shoot_time > shoot_rate:
			_shoot()

	_move_wobble()

func _move_wobble():
	if move_input.length() == 0:
		sprite.rotation_degrees = 0
		return
	
	var t = Time.get_unix_time_from_system()
	var rot = sin(t * 20) * 2
	
	sprite.rotation_degrees = rot

func _shoot():
	last_shoot_time = Time.get_unix_time_from_system()

	var bullet = bullet_pool.spawn()

	bullet.global_position = muzzle.global_position
	
	# Set bullet direction towards mouse
	var direction = (get_global_mouse_position() - muzzle.global_position).normalized()
	bullet.move_dir = direction
	bullet.additional_speed = additional_bullet_speed

func take_damage(damage : int):
	current_hp -= damage

	if current_hp <= 0:
		game_over = true
		get_tree().get_first_node_in_group("GameManager").set_game_over()
	else:
		_damage_flash()
		health_bar.value = current_hp

func _damage_flash():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

func heal(amount : int):
	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp
	
	health_bar.value = current_hp
