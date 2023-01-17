extends Control

# Variables for loading lastest save game
var file: String = PlayerStats.get_latest_enc_pass("user://saves/")

# Is called when when is lifted
func _on_Continue_button_up():
	get_node("Button Container/Continue").text = PlayerStats.load_game(file) # Loaded save game, updates button text
