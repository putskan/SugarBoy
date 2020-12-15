extends KinematicBody2D
var motion = Vector2()
var moving_direction = 'up'
# node under trophy
var chocolate_counter

func _ready():
	chocolate_counter = get_tree().get_root().find_node("ChocolateCounter", true, false)
	chocolate_counter.add_chocolate_to_world()

func _on_Area2D_body_entered(body):
	if body.name == 'Player':
		chocolate_counter.chocolate_collected()
		queue_free()


func _physics_process(delta):
	if moving_direction == 'up':
		motion.y -= 0.5
		if motion.y == -15:
			moving_direction = 'down'
	else:
		motion.y += 0.5
		if motion.y == 15:
			moving_direction = 'up'
			
	motion = move_and_slide(motion)
	pass

