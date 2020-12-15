extends HBoxContainer
var player

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	# listen for health changes
	player.connect("health_changed", self, "change_health")
	
func change_health(new_health):
	$NinePatchRect/HPNumber.set_text('%d/100' % new_health)
	$HPBar.set_value(new_health)
	
