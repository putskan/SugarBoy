extends KinematicBody2D

const DEATH_BY_MEELE = false
const DEATH_BY_JUMP = false
const JUMP_HEIGHT = -1300
const GRAVITY = 100
const SECONDS_BETWEEN_JUMPS = 2
const UP = Vector2(0, -1)
var motion = Vector2()
# counts till equals to seconds specified in SECONDS_BETWEEN_JUMPS 
var jumps_time_counter = 0
var hp = 3
var is_dead = false
var hit_player_recently = false
onready var down_raycasts = $BounceOnPlayer.get_children()
onready var player = get_tree().get_root().find_node('Player', true, false)

signal hit_enemy

func _ready():
	player.connect('get_hit', self, 'hit_player')
	
func _physics_process(delta):
	if is_dead:
		return
	motion.y += GRAVITY
	# jumping mechanism
	if is_on_floor():
		jumps_time_counter += 1
		# multiply by 60 becuase _physics_process iterates 60 times per second
		if jumps_time_counter == SECONDS_BETWEEN_JUMPS * 60:
			jumps_time_counter = 0
			jump()
			
		elif jumps_time_counter > (SECONDS_BETWEEN_JUMPS - 1) * 60:
			$AnimatedSprite.play("idle_n_jump")
			
		else:
			$AnimatedSprite.play("dizzy")
			
		# currently above player
		if hit_player_recently and is_above_player():
			#if hitting_player:
			#	jump()
			motion.x += 40
		else:
			hit_player_recently = false
			motion.x = 0
	
	else:
		# jumping
		$AnimatedSprite.play("idle_n_jump")
		
	motion = move_and_slide(motion, UP)


func jump():
	motion.y = JUMP_HEIGHT


func die():
	is_dead = true
	$AnimatedSprite.play("dizzy")
	$AnimatedSprite.set_rotation_degrees(90)


func is_above_player():
	# called only on player hit (remote signal)
	for ray in down_raycasts:
		if ray.is_colliding() and ray.get_collider().name == 'Player':
			return true
	return false

func hit_player():
	hit_player_recently = true

func _on_Area2D_area_entered(area):
	if area.name == 'MeleeAttackArea':
		emit_signal("hit_enemy")
		hp -= 1
		$AnimatedSprite.modulate = Color(6,1,1)
		$AnimatedSprite.modulate = Color(0.4, 0.2, 0.2, 0.85)
		if hp == 0:
			die()
		
func _on_Area2D_area_exited(area):
	if area.name == 'MeleeAttackArea':
		$AnimatedSprite.modulate = Color(1,1,1)


func _on_AnimatedSprite_animation_finished():
	if is_dead:
		queue_free()

