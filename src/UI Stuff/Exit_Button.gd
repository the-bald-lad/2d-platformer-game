extends Button

# Is called when the button is raised
func _on_Exit_button_up() -> void:
	get_tree().quit() # Quits the current tree, which closes the game
