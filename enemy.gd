extends CharacterBody2D
class_name enemyd
@export var patrol_speed = 50
@export var chase_speed = 100
@export var attack_power = 10
@export var max_hp = 20
@export var attack_cooldown: float = 1.0
var current_hp
enum State { PATROL, CHASE, ATTACK }
var state = State.PATROL
var player = null
func _ready():
	current_hp = max_hp
	add_to_group("Enemy")  # mark for player absorb
# Random initial patrol direction
	randomize()
	if randi() % 2 == 0:
		velocity.x = patrol_speed
		$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = -patrol_speed
		$AnimatedSprite2D.flip_h = true

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	match state:
		State.PATROL:
			patrol_behavior()
		State.CHASE:
			chase_behavior()
		State.ATTACK:
			attack_behavior()
	move_and_slide()  # apply movement each frame:contentReference[oaicite:25]{index=25}

# Patrol: walk back and forth on platform
func patrol_behavior():
	$AnimatedSprite2D.play("Walk")# Turn at edges/walls
	if not $GroundRay.is_colliding():
		velocity.x = -velocity.x
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
	if $RightWallRay.is_colliding():
		velocity.x = -abs(patrol_speed)
		$AnimatedSprite2D.flip_h = true
	if $LeftWallRay.is_colliding():
		velocity.x = abs(patrol_speed)
		$AnimatedSprite2D.flip_h = false
# Optionally, occasionally idle: implement with a Timer if needed.
# Chase: move toward the player horizontally
func chase_behavior():
	if player:
		var dir_x = player.position.x - position.x
		if dir_x > 0:
			velocity.x = chase_speed
			$AnimatedSprite2D.flip_h = false
		else:
			velocity.x = -chase_speed
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("Walk")

# Attack: stop and play melee animation
func attack_behavior():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("attack")
	
# Damage application can be handled by AttackArea signal or on AnimationPlayer cue
func _on_DetectArea_body_entered(body):
	if body.is_in_group():
		player = body
		state = State.CHASE

func _on_DetectArea_body_exited(body):
	if body == player:
		player = null
		state = State.PATROL

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player"):
		state = State.ATTACK
		player = body
		body.take_damage(attack_power)  # example damage call

func _on_AttackArea_body_exited(body):
	if body == player:
		state = State.CHASE

func _on_AnimationPlayer_animation_finished(anim_name):
	if state == State.ATTACK and anim_name == "attack":
		state = State.CHASE

func take_damage(amount):
	current_hp -= amount
	if current_hp <= 0:
		die()

func die():
	$AnimatedSprite2D.play("Death")
	queue_free()
