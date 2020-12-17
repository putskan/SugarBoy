extends MarginContainer
export(String, FILE, "*.tscn") var next_world

func _on_Start_Game_pressed():
	get_tree().change_scene(next_world)


func _on_Quit_pressed():
	get_tree().quit()
