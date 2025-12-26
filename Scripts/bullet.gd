extends Area2D

@export var speed : float = 200.0
@export var owner_group : String
@onready var destroy_timer : Timer = $DestroyTimer

var move_dir : Vector2

func _process(delta):
    translate(move_dir * speed * delta)

    rotation = move_dir.angle()

func _on_body_entered(body):
    if body.is_in_group(owner_group):
        return
        
    if body.has_method("take_damage"):
        body.take_damage(1)
    
    visible = false

func _on_destroy_timer_timeout():
    visible = false

func _on_visibility_changed():
    if visible == true and destroy_timer:
        destroy_timer.start()