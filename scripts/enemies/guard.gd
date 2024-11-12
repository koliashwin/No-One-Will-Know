extends "res://scripts/enemies/enemy_base.gd"

# Guard Script(enemy)
var guard_speed: float = 150
var guard_gravity: float = 100
var guard_patrol_dist: int = 128

#import the required nodes
@onready var guard_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var guard_detection_range: Area2D = $DetectionRange
@onready var guard_attack_range: Area2D = $AttackRange


func _ready() -> void:
	speed = guard_speed
	gravity = guard_gravity
	patrol_dist = guard_patrol_dist
	
	patrol_start_pos = global_position
	patrol_end_pos = global_position + Vector2(patrol_dist, 0)

func _physics_process(delta: float) -> void:
	enemy_state(delta)
	apply_gravity(gravity, 900)
	flip_character_node(guard_sprite, guard_detection_range, guard_attack_range)
	death()
	
	update_animation(guard_sprite)
	move_and_slide()

# function to manage various state conditions
func enemy_state(delta: float) -> void:
	if player_detected:
		is_patrolling = false
		if is_attacking:
			attack()
		elif is_chasing:
			run(player_node.position,1, 1.5)
	elif is_patrolling:
		patrol(delta)

func update_animation(character_sprite: AnimatedSprite2D) -> void:
	# this condition check for the priority animations and exits the update cycle early on if required
	if attack_death_animations(character_sprite):
		return
	
	#standred animations
	horizontal_movment_animations(character_sprite)

#chase/run awaw setup when player enters detection range
func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		player_node = body
		player_detected = true
		is_patrolling = false
		is_chasing = true

#chase/run awaw setup when player exits detection range
func _on_detection_range_body_exited(body: Node2D) -> void:
	if body.is_in_group('Player'):
		player_node = null
		player_detected = false
		is_patrolling = true
		is_chasing = false

#function to handlel animation end flags
func _on_animated_sprite_2d_animation_finished() -> void:
	if guard_sprite.animation == 'attack':
		is_attacking = false
	if guard_sprite.animation == 'death':
		is_dying = false
		is_dead = true

#attack setup when player enters attack range
func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		is_attacking = true
		#sack_guy_detection_range.monitoring = false

#attack setup when player exits attack range
func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group('Player'):
		pass
		#is_attacking = false
		#sack_guy_detection_range.monitoring = true
