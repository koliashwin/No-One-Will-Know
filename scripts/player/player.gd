extends CharacterBody2D

#declar export variables
@export var speed: float = 500
@export var gravity: float = 100
@export var jump_force: float = 1500

#import the required nodes
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	#Horizontal movment logic
	var horizontal_diraction: int = Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_diraction * speed
	
	jump()
	attack()
	
	update_animation()
	move_and_slide()

func apply_gravity(gravity: float, max_fall_speed: float) -> void:
	#function to handle gravity applied on the player
	if !is_on_floor() and velocity.y <= max_fall_speed:
		velocity.y += gravity

func jump() -> void:
	apply_gravity(gravity, gravity*10)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_force

func attack() -> void:
	if Input.is_action_just_pressed("attack"):
		velocity.x = 0
		# attack logic goes here


func update_animation() -> void:
	
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false
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
