extends CharacterBody2D
#Player Script
#declar export variables
@export var speed: float = 500
@export var gravity: float = 100
@export var jump_force: float = 1500
@export var max_fall_speed: float = 900
@export var attack_power: int = 3
@export var health: int = 5
@export var max_health: int = 5

#condition check variables (flags)
var is_attacking: bool = false
var is_dying: bool = false
var is_dead: bool = false

#import the required nodes
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_attack_range: Area2D = $AttackArea
@onready var player_attack_area_shape: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready() -> void:
	add_to_group('Player')

func _physics_process(delta: float) -> void:
	
	#Horizontal movment logic
	var horizontal_diraction: int = Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_diraction * speed
	apply_gravity(gravity, max_fall_speed)
	jump()
	attack()
	flip_player_node()
	
	update_animation()
	move_and_slide()

func apply_gravity(gravity: float, max_fall_speed: float) -> void:
	#function to handle gravity applied on the player
	if !is_on_floor() and velocity.y <= max_fall_speed:
		velocity.y += gravity

func jump() -> void:
	#jump logic
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_force

func attack() -> void:
	if Input.is_action_just_pressed("attack") and !is_attacking and !is_dying and !is_dead:
		is_attacking = true
		player_attack_area_shape.disabled = false

#function to heal or hurt player use the negative value to hurt and positive value to heal
func hurt_heal(helth_points: int) -> void:
	health = clamp(health + helth_points, 0, max_health)
	if health <= 0:
		death()

#death logic
func death() ->void:
	is_dying = true

func flip_player_node() -> void:
	# flip the sprite based and attack area on direction player facing
	if !is_dying and !is_dead:
		if velocity.x < 0:
			player_sprite.flip_h = true
			player_attack_range.scale.x = -1
		elif velocity.x > 0:
			player_sprite.flip_h = false
			player_attack_range.scale.x = 1

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
		player_attack_area_shape.disabled = true
	if player_sprite.animation == 'death':
		is_dying = false
		is_dead = true

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		if body.has_method("hurt") and !body.is_dead:
			body.hurt(attack_power)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		var damage: int = body.attack_power
		if !body.is_dead and !body.is_dying:
			hurt_heal(-damage)
