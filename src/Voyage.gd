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

signal hit_enemy

func _physics_process(delta):
	motion.y += GRAVITY
	if not is_dead:
		# jumping mechanism
		if is_on_floor():
			jumps_time_counter += 1
			# multiply by 60 becuase _physics_process iterates 60 times per second
			if jumps_time_counter == SECONDS_BETWEEN_JUMPS * 60:
				jumps_time_counter = 0
				motion.y = JUMP_HEIGHT
				
			elif jumps_time_counter > (SECONDS_BETWEEN_JUMPS - 1) * 60:
				$AnimatedSprite.play("idle_n_jump")
				
			else:
				$AnimatedSprite.play("dizzy")
		else:
			# jumping
			$AnimatedSprite.play("idle_n_jump")
		
	motion = move_and_slide(motion, UP)
	
func die():
	is_dead = true
	$AnimatedSprite.play("dizzy")
	$AnimatedSprite.set_rotation_degrees(90)


func _on_Area2D_body_entered(body):
	pass


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



