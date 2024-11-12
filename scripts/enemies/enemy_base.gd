extends CharacterBody2D
# Enemy Base script
#declare export variables
var speed: float = 200
var gravity: float = 100
var patrol_dist: int = 128

# reference and condition variables(flags)
var player_node: Node2D
var player_detected: bool = false
var is_attacking: bool = false
var is_dying: bool = false
var is_dead: bool = false
var is_patrolling: bool = true
var is_chasing: bool = true

#patrol variables
var patrol_start_pos: Vector2
var patrol_end_pos: Vector2
var patrol_direction: int = 1
var patrol_timer: float = 0
var delay_at_end: float = 0.5

func apply_gravity(gravity: float, max_fall_speed: float) -> void:
	#function to handle gravity applied on the player
	if !is_on_floor() and velocity.y <= max_fall_speed:
		velocity.y += gravity

#function to run towards or away from the player
func run(
	player_position: Vector2,		#player co-ordinates
	run_direction: int = 1, 		#use 1 to run towards player and -1 to run away from player
	speed_multiplier: float = 1.5
	) -> void:
	
	var direction: Vector2 = (player_position - global_position).normalized()
	velocity.x = direction.x * speed * speed_multiplier * run_direction

# function to patrol between 2 points
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

# dummy attack function
func attack() -> void:
	is_attacking = true
	# attack logic goes here

# dummy death function
func death() -> void:
	#dummy logic to test the death animation
	if Input.is_action_just_pressed("ability") and !is_dying:
		is_dying = true

#function to flip charater sprites and collision shapes 
func flip_character_node(
	character_sprite: AnimatedSprite2D, 
	character_attack_range: Area2D, 
	character_detection_range: Area2D
	) -> void:
	#logic to flip whole parent node along with collisoin shape and area2d nodes
	if velocity.x < 0:
		character_sprite.flip_h = false
		character_attack_range.scale.x = 1
		character_detection_range.scale.x = 1
	elif velocity.x > 0:
		character_sprite.flip_h = true
		character_attack_range.scale.x = -1
		character_detection_range.scale.x = -1

#function to play run or idle animations
func horizontal_movment_animations(character_sprite: AnimatedSprite2D) -> void:
	if is_on_floor():
		if velocity.x == 0:
			character_sprite.play("idle")
		else:
			character_sprite.play('run')

# functin for attack and death animations
func attack_death_animations(character_sprite: AnimatedSprite2D) -> bool:
	if is_attacking or is_dying or is_dead:			# check variour flags to update animation accourdingly
		velocity.x = 0
		if is_dead:
			character_sprite.play('died')
		else:
			if is_attacking:
				character_sprite.play('attack')
			elif is_dying:
				character_sprite.play('death')
		return true
	return false
