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

var move_input : Vector2

var bullet_scene : PackedScene = preload("res://Scenes/bullet.tscn")

func _physics_process(_delta):
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if move_input.length() > 0:
		velocity = velocity.lerp(move_input * max_speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, braking)

	move_and_slide()

func _process(_delta):
	sprite.flip_h = get_global_mouse_position().x > global_position.x

	if Input.is_action_pressed("shoot"):
		if Time.get_unix_time_from_system() - last_shoot_time > shoot_rate:
			_shoot()

func _shoot():
	last_shoot_time = Time.get_unix_time_from_system()

	var bullet = bullet_pool.spawn()

	bullet.global_position = muzzle.global_position
	
	# Set bullet direction towards mouse
	var direction = (get_global_mouse_position() - muzzle.global_position).normalized()
	bullet.move_dir = direction

func take_damage(damage : int):
	current_hp -= damage

	if current_hp <= 0:
		print("Player Died")
