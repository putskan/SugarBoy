extends KinematicBody2D

const JUMP_HEIGHT = -600
const MOVE_MAX_SPEED = 500
const MOVE_ACCELERATION = 25
const GRAVITY = 19
const UP = Vector2(0, -1)
const death_animation = "ko"
const cause_to_damage = {
	'SpikesArea': 999,
	'VoyageArea': 50,
	'fall_out_of_world': 999
}
var motion = Vector2()
var is_attacking = false
var attack_animations = ['attack', 'attack2']
var is_dead = false
var health = 100
var is_invulnerable = false
var areas_currently_colliding = []
var death_prerequisites =  {
	"finished_death_animation": false,
	"finished_death_audio": false
}

signal health_changed(new_health)
signal player_jump
signal hit_enemy
signal get_hit
signal die

func _ready():
	var sound_effects = get_tree().get_root().find_node("SoundEffects", true, false)
	var complete_trophy = get_tree().get_root().find_node("CompleteTrophy", true, false)
	sound_effects.connect("death_sound_finished", self, "death_sound_finished")
	complete_trophy.connect("player_finishing_level", self, "hide_player")

# runs 60 times a second
func _physics_process(delta):
	if is_dead:
		for value in death_prerequisites.values():
			if not value:
				return
				
		die_p2()
		return
		
	handle_motion()
	handle_attack()
	handle_fall_out_of_world()	
	handle_animation_flip()
	handle_animation_type(motion)
	# apply motion to player. UP direction must be specified for physics to word ("is on floor")
	motion = move_and_slide(motion, UP)


func handle_motion():
	# change motion if needed (not yet applied to user)
	motion.y += GRAVITY
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + MOVE_ACCELERATION, MOVE_MAX_SPEED) 

	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - MOVE_ACCELERATION, -MOVE_MAX_SPEED) 

	else:
		motion.x = 0

	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		jump()


func jump():
	motion.y = JUMP_HEIGHT
	emit_signal("player_jump")


func handle_attack():
	if Input.is_action_pressed("attack"):
		is_attacking = true
		$AnimatedSprite/MeleeAttackArea/CollisionShape2D.disabled = false
		

func handle_animation_type(motion):
	# handle most animation types (e.g., run, idle, jump)
	if is_attacking:
		$AnimatedSprite.play(attack_animations[0])
		return
		
	if not is_on_floor():
		if motion.y < 0:
			$AnimatedSprite.play("jump")
			return
		else:
			$AnimatedSprite.play("fall")
			return
			
	if motion.x != 0:
		$AnimatedSprite.play("run")
		return
	
	$AnimatedSprite.play("idle")


func handle_animation_flip():
	# handle animation vertical/horizontal flips
	if Input.is_action_pressed("ui_right"):
		$AnimatedSprite.flip_h = false
		$AnimatedSprite/MeleeAttackArea.rotation_degrees = 0
		
	if Input.is_action_pressed("ui_left"):
		$AnimatedSprite.flip_h = true
		$AnimatedSprite/MeleeAttackArea.rotation_degrees = -180


func handle_fall_out_of_world():
	# check if player fell out of world and handle accordingly (kill)
	var player_pos = self.get_position()
	var lowest_point = get_world_lowest_point(self.get_parent())
	if player_pos.y > lowest_point + 1000:
		handle_damage("fall_out_of_world")
		return true


func get_world_lowest_point(world_node):
	# return the lowest position in the world (positive float, mostly)
	var world_lowest_point = 0
	for n in world_node.get_children():
		if n.name == "TileMap":
			var tile_rect = n.get_used_rect()
			world_lowest_point = max(world_lowest_point, n.map_to_world(tile_rect.position)[1] + n.map_to_world(tile_rect.size)[1])
	
	assert(world_lowest_point != 0, "ERROR: no lowest point found in map.");
	return world_lowest_point


func _on_AnimatedSprite_animation_finished():
	if is_dead:
		# die only after death animation finished
		$AnimatedSprite.play("death_frame")
		$AnimatedSprite.stop()
		death_prerequisites["finished_death_animation"] = true
		return
		
	if $AnimatedSprite.animation in attack_animations:
		is_attacking = false
		$AnimatedSprite/MeleeAttackArea/CollisionShape2D.disabled = true
		# change next animation
		attack_animations.push_front(attack_animations.pop_back())


func handle_damage(damage_cause):
	if not damage_cause in cause_to_damage.keys():
		# not hit by enemy
		return false
	emit_signal("get_hit")
	bounce_back(damage_cause)
	var dmg = cause_to_damage[damage_cause]
	health = max(health - dmg, 0)
	emit_signal("health_changed", health)
	if health == 0:
		die_p1()
		return
	take_damage_blinking_animation()


func take_damage_blinking_animation():
	# Flicker 4 times, while being invulnerable to enemies
	is_invulnerable = true
	for i in 7:
		modulate.a = 0.5
		for j in 5:
			yield(get_tree(), "idle_frame")
		modulate.a = 1.0
		for j in 5:
			yield(get_tree(), "idle_frame")
	is_invulnerable = false
	
	# deal damage again if player haven't stopped colliding with the enemy
	if len(areas_currently_colliding) > 0:
		handle_damage(areas_currently_colliding[0].name)


func bounce_back(damage_cause):
	# bounce back from enemies
	motion.y *= -1
	motion.x *= -1
	motion = move_and_slide(motion, UP)


func die_p1():
	is_dead = true
	is_invulnerable = true
	emit_signal("die")
	# caught in _on_AnimatedSprite_animation_finished
	$AnimatedSprite.play(death_animation)


func die_p2():
	get_tree().reload_current_scene()


func _on_HitArea_area_entered(area):
	areas_currently_colliding.append(area)
	if not is_invulnerable:
		handle_damage(area.name)


func _on_HitArea_area_exited(area):
	areas_currently_colliding.erase(area)


func _on_MeleeAttackArea_area_entered(area):
	# Raise signal if attacking an enemy
	if area.get_parent().get_node_or_null("Enemy"):
		emit_signal("hit_enemy")


func death_sound_finished():
	death_prerequisites["finished_death_audio"] = true


func hide_player():
	set_modulate(Color(1, 1, 1, 0))
	set_physics_process(false)
	is_invulnerable = true
