extends KinematicBody2D
export(String, FILE, "*.tscn") var next_world
var motion = Vector2()
var moving_direction = 'up'
# changes when chocolates collected
var can_finish_world = false

func _on_Area2D_body_entered(body):
	if body.name == 'Player':
		if can_finish_world:
			get_tree().change_scene(next_world)
		else:
			$Sprite.modulate = Color(0.7, 0.08, 0.2)


func _on_Area2D_body_exited(body):
	$Sprite.modulate = Color(1,1,1)


func _physics_process(delta):
	if moving_direction == 'up':
		motion.y -= 0.5
		if motion.y == -30:
			moving_direction = 'down'
	else:
		motion.y += 0.5
		if motion.y == 30:
			moving_direction = 'up'
			
	motion = move_and_slide(motion)
	pass


func _on_ChocolateCounter_all_chocolates_collected():
	can_finish_world = true
