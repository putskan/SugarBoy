extends RayCast2D

func _ready():
	# don't collide with ancestors
	var root_node = get_tree().get_root()
	var parent = get_parent()
	while parent != root_node:
		parent = parent.get_parent()
		add_exception(parent)
	
