extends Button

# For going back to the game
func _on_Button_button_up():
	# Gets pause menu and removes it from processing queue
	get_tree().current_scene.get_node("CanvasLayer2/Pause Menu").queue_free() 
	
	# Allows processing to continue in the game
	PlayerStats.get_tree().paused = false
