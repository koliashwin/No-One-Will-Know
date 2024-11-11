extends CharacterBody2D
#Player Script
#declar export variables
@export var speed: float = 500
@export var gravity: float = 100
@export var jump_force: float = 1500
@export var max_fall_speed: float = 900

#condition check variables (flags)
var is_attacking: bool = false
var is_dying: bool = false
var is_dead: bool = false

#import the required nodes
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group('Player')

func _physics_process(delta: float) -> void:
	
	#Horizontal movment logic
	var horizontal_diraction: int = Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_diraction * speed
	
	jump()
	attack()
	death()
	
	update_animation()
	move_and_slide()

func apply_gravity(gravity: float, max_fall_speed: float) -> void:
	#function to handle gravity applied on the player
	if !is_on_floor() and velocity.y <= max_fall_speed:
		velocity.y += gravity

func jump() -> void:
	apply_gravity(gravity, max_fall_speed)
	
	#jump logic
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_force

func attack() -> void:
	# dummy attack logic to test animation
	if Input.is_action_just_pressed("attack") and !is_attacking:
		is_attacking = true
		# attack logic goes here

func death() ->void:
	#dummy logic to test the death animation
	if Input.is_action_just_pressed("ability") and !is_dying:
		is_dying = true

func update_animation() -> void:
	# this condition check for the priority animations and exits the update cycle early on if required
	if is_attacking or is_dying or is_dead:			# check variour flags to update animation accourdingly
		velocity.x = 0
		if is_dead:
			player_sprite.play('died')
		else:
			if is_attacking:
				player_sprite.play('attack')
			elif is_dying:
				player_sprite.play('death')
		return
	
	# flip the sprite based on direction its facing
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false
	
	# standared character animation logic
	if is_on_floor():
		if velocity.x == 0:
			player_sprite.play("idle")
		else:
			player_sprite.play('run')
	else:
		if velocity.y < 0:
			player_sprite.play('jump')
		else:
			player_sprite.play('fall')


func _on_animated_sprite_2d_animation_finished() -> void:
	# set/update flags according to some animation logic
	if player_sprite.animation == 'attack':
		is_attacking = false
	if player_sprite.animation == 'death':
		is_dying = false
		is_dead = true
