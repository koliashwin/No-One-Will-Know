extends "res://scripts/enemies/enemy_base.gd"
# Sack_Guy Script(enemy)
#declare export variables(repeated var)
@export var sack_guy_speed: float = 120
@export var sack_guy_patrol_dist: int = 64
@export var sack_guy_health: int = 10

#import the required nodes
@onready var sack_guy_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sack_guy_detection_range: Area2D = $DetectionRange
@onready var sack_guy_attack_range: Area2D = $AttackRange
@onready var sack_guy_attack_cooldown: Timer = $AttackCooldown


func _ready() -> void:
	add_to_group('Enemies')
	
	speed = sack_guy_speed
	patrol_dist = sack_guy_patrol_dist
	health = sack_guy_health
	
	patrol_start_pos = global_position
	patrol_end_pos = global_position + Vector2(patrol_dist, 0)

func _physics_process(delta: float) -> void:
	enemy_state(delta)
	apply_gravity(gravity, 900)
	flip_character_node(sack_guy_sprite, sack_guy_attack_range, sack_guy_detection_range)
	
	update_animation(sack_guy_sprite)
	move_and_slide()

# function to manage various state conditions
func enemy_state(delta: float) -> void:
	if player_detected:
		is_patrolling = false
		if is_attacking:
			attack()
		elif is_chasing:
			run(player_node.position,1, 1.2)
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
	if sack_guy_sprite.animation == 'attack':
		is_attacking = false
		can_attack = false
		sack_guy_attack_range.set_deferred('monitoring', false)
		sack_guy_attack_cooldown.start()
	if sack_guy_sprite.animation == 'death':
		is_dying = false
		is_dead = true

#attack setup when player enters attack range
func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		if can_attack:
			is_attacking = true
		#sack_guy_detection_range.monitoring = false

#attack setup when player exits attack range
func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group('Player'):
		pass
		#is_attacking = false
		#sack_guy_detection_range.monitoring = true

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	sack_guy_attack_range.set_deferred('monitoring', true)
