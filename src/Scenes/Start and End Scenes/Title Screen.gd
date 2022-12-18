extends Control

# Variables for loading lastest save game
var file: File = File.new()

# Is called when when is lifted
func _on_Continue_button_up():
	if file.open(PlayerStats.save_path, File.READ) == OK: # Checks that file could be opened correctly
		print(file.READ)
	get_node("Button Container/Continue").text = PlayerStats.load_game() # Loaded save game, updates button text
