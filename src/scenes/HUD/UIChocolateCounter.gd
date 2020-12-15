extends NinePatchRect

func _ready():
	var chocolate_counter = get_tree().get_root().find_node("ChocolateCounter", true, false)
	chocolate_counter.connect("remaining_chocolates_changed", self, "change_counter_number")


func change_counter_number(new_number):
	$Label.set_text('x%d' % new_number)
