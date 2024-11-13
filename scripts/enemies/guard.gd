extends "res://scripts/enemies/enemy_base.gd"

# Guard Script(enemy)
@export var guard_speed: float = 150
@export var guard_health: int = 10
@export var guard_lookout_time: float = 2

#import the required nodes
@onready var guard_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var guard_detection_range: Area2D = $DetectionRange
@onready var guard_attack_range: Area2D = $AttackRange
@onready var guard_attack_cooldown: Timer = $AttackCooldown
@onready var guard_lookout_timer: Timer = $SwitchDirection

func _ready() -> void:
	add_to_group('Enemies')
	
	speed = guard_speed
	health = guard_health
	
	guard_lookout_timer.wait_time = guard_lookout_time
	guard_lookout_timer.start()
	#patrol_start_pos = global_position
	#patrol_end_pos = global_position + Vector2(patrol_dist, 0)

func _physics_process(delta: float) -> void:
	apply_gravity(gravity, 900)
	enemy_state()
	
	update_animation(guard_sprite)
	move_and_slide()

func enemy_state():
	if can_attack and player_detected:
		attack()

func update_animation(character_sprite: AnimatedSprite2D) -> void:
	# this condition check for the priority animations and exits the update cycle early on if required
	if attack_death_animations(character_sprite):
		return
	
	#standred animations
	horizontal_movment_animations(character_sprite)

#function to handlel animation end flags
func _on_animated_sprite_2d_animation_finished() -> void:
	if guard_sprite.animation == 'attack':
		is_attacking = false
		can_attack = false
		#guard_attack_range.set_deferred('monitoring', false)
		guard_attack_cooldown.start()
	if guard_sprite.animation == 'death':
		is_dying = false
		is_dead = true

#attack setup when player enters attack range
func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		player_detected = true
		guard_lookout_timer.stop()
		if can_attack:
			is_attacking = true
		#sack_guy_detection_range.monitoring = false

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	#guard_attack_range.set_deferred('monitoring', true)
	#is_attacking = false

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group('Player'):
		player_detected = false
		guard_lookout_timer.start()

func _on_switch_direction_timeout() -> void:
	if !is_dead:
		self.scale.x = -1
		guard_lookout_timer.start()
