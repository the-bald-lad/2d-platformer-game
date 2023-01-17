extends Node

# Variables for changing button aspects
var file_name # Taken when button is generated

# When button is pressed
func _pressed() -> void:
	# Prints file loaded for debugging
	print("Load File: " + file_name)
	
	# Changes text, only seen if save does not load
	self.text = PlayerStats.load_game(file_name)
