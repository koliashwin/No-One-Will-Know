extends "res://scripts/enemies/enemy_base.gd"
# Slime Script(enemy)
#declare export variables
@export var slime_speed: float = 200

# reference and condition variables
var is_surprised: bool = false

# import required nodes
@onready var slime_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slime_detection_range: Area2D = $DetectionRange

func _ready() -> void:
	add_to_group('Enemies')
	
	speed = slime_speed

func _physics_process(delta: float) -> void:
	if player_detected:
		run(player_node.position, -1, 1)
	apply_gravity(gravity, 1000)
	flip_slime_node()
	
	update_animation()
	move_and_slide()

func flip_slime_node():
	#logic to flip whole parent node along with collisoin shape and area2d nodes
	if velocity.x < 0 and !is_surprised:
		slime_sprite.flip_h = false
		slime_detection_range.scale.x = 1
	elif velocity.x > 0 and !is_surprised:
		slime_sprite.flip_h = true
		slime_detection_range.scale.x = -1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		player_node = body
		player_detected = true
		is_surprised = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('Player'):
		player_node = null
		player_detected = false

func update_animation() -> void:
	#logic for priority animations
	if is_surprised:
		slime_sprite.play('surprised')
		return
	
	horizontal_movment_animations(slime_sprite)

func _on_animated_sprite_2d_animation_finished() -> void:
	if slime_sprite.animation == 'surprised':
		is_surprised = false
