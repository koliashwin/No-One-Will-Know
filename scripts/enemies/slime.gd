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
	speed = slime_speed

func _physics_process(delta: float) -> void:
	if player_detected:
		run(player_node.position, -1, 1)
	apply_gravity(gravity, 1000)
	flip_slime_node()
	
	update_animation()
	move_and_slide()

#func apply_gravity(gravity: float, max_fall_speed: float) -> void:
	##function to handle gravity applied on the player
	#if !is_on_floor() and velocity.y <= max_fall_speed:
		#velocity.y += gravity

#func run(
	#player_position: Vector2, 		#player co-ordinates
	#run_direction: int = 1, 		#use 1 to run towards player and -1 to run away from player
	#speed_multiplayer: float = 1.5
	#) -> void:
	#
	#var direction: Vector2 = (player_position - global_position).normalized()
	#velocity.x = direction.x * speed * speed_multiplayer * run_direction

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
		#print(player_node.position)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('Player'):
		player_node = null
		player_detected = false
		#print(player_node.position)

func update_animation() -> void:
	#logic for priority animations
	if is_surprised:
		slime_sprite.play('surprised')
		return
	
	horizontal_movment_animations(slime_sprite)

func _on_animated_sprite_2d_animation_finished() -> void:
	if slime_sprite.animation == 'surprised':
		is_surprised = false
