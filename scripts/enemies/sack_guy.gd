extends CharacterBody2D
# Sack_Guy Script(enemy)
#declare export variables(repeated var)
@export var speed: float = 200
@export var gravity: float = 100
@export var patrol_dist: int = 128

#import the required nodes
@onready var sack_guy_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sack_guy_detection_range: Area2D = $DetectionRange
@onready var sack_guy_attack_range: Area2D = $AttackRange

# reference and condition variables(repeated var)
var player_node: Node2D
var player_detected: bool = false
var is_attacking: bool = false
var is_dying: bool = false
var is_dead: bool = false
var is_patrolling: bool = true
var is_chasing: bool = true

var patrol_start_pos: Vector2
var patrol_end_pos: Vector2
var patrol_direction: int = 1
var patrol_timer: float = 0
var delay_at_end: float = 0.5

func _ready() -> void:
	patrol_start_pos = global_position
	patrol_end_pos = global_position + Vector2(patrol_dist, 0)

func _physics_process(delta: float) -> void:
	enemy_state(delta)
	apply_gravity(gravity, 900)
	flip_character_node()
	death()
	
	update_animation()
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

#repeated function from other script
func apply_gravity(gravity: float, max_fall_speed: float) -> void:
	#function to handle gravity applied on the player
	if !is_on_floor() and velocity.y <= max_fall_speed:
		velocity.y += gravity

#repeated function
func run(
	player_position: Vector2,		#player co-ordinates
	run_direction: int = 1, 		#use 1 to run towards player and -1 to run away from player
	speed_multiplier: float = 1.5
	) -> void:
	
	var direction: Vector2 = (player_position - global_position).normalized()
	velocity.x = direction.x * speed * speed_multiplier * run_direction

# logic for patrolling between 2 points
func patrol(delta: float, speed_multiplier: float = 0.5) -> void:
	if patrol_timer > 0:
		patrol_timer -= delta
		velocity.x = 0
		return
	
	var target_pos: Vector2 = patrol_end_pos if patrol_direction == 1 else patrol_start_pos
	
	if global_position.distance_to(target_pos) < 5:
		patrol_direction *= -1
		patrol_timer = delay_at_end
	
	var diraction: Vector2 = (target_pos - global_position).normalized()
	velocity.x = diraction.x * speed * speed_multiplier

func attack() -> void:
	is_attacking = true
	# attack logic goes here

func death() -> void:
	#dummy logic to test the death animation
	if Input.is_action_just_pressed("ability") and !is_dying:
		is_dying = true

#repeated function
func flip_character_node():
	#logic to flip whole parent node along with collisoin shape and area2d nodes
	if velocity.x < 0:
		sack_guy_sprite.flip_h = false
		sack_guy_detection_range.scale.x = 1
		sack_guy_attack_range.scale.x = 1
	elif velocity.x > 0:
		sack_guy_sprite.flip_h = true
		sack_guy_detection_range.scale.x = -1
		sack_guy_attack_range.scale.x = -1

func update_animation() -> void:
	# this condition check for the priority animations and exits the update cycle early on if required
	if is_attacking or is_dying or is_dead:			# check variour flags to update animation accourdingly
		velocity.x = 0
		if is_dead:
			sack_guy_sprite.play('died')
		else:
			if is_attacking:
				sack_guy_sprite.play('attack')
			elif is_dying:
				sack_guy_sprite.play('death')
		return
	
	#standred animations
	if is_on_floor():
		if velocity.x == 0:
			sack_guy_sprite.play("idle")
		else:
			sack_guy_sprite.play('run')

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
	if sack_guy_sprite.animation == 'death':
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
