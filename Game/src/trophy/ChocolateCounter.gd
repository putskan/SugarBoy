extends Node2D

var chocolates_to_collect = 0
signal remaining_chocolates_changed(chocolates_to_collect)
signal all_chocolates_collected
signal chocolate_collected


func _ready():
	# trick to make sure world was loaded
	yield(get_tree(), "idle_frame")
	# edge case: check if there are no chocolates in the map
	if chocolates_to_collect == 0:
		emit_signal("all_chocolates_collected")
	# init chocolates in HUD, etc
	emit_signal('remaining_chocolates_changed', chocolates_to_collect)

func add_chocolate_to_world():
	chocolates_to_collect += 1
	emit_signal('remaining_chocolates_changed', chocolates_to_collect)


func chocolate_collected():
	# every time user collects chocolate
	chocolates_to_collect -= 1
	if chocolates_to_collect == 0:
		emit_signal("all_chocolates_collected")
	emit_signal('remaining_chocolates_changed', chocolates_to_collect)
	# for sound
	emit_signal("chocolate_collected")
