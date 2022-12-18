extends Button

# Is called when first loaded into game
func _ready():
	text = "Save Game" # Updates button text

# Called when button is lifted
func _on_Save_button_up():
	text = PlayerStats.save_game() # Updates text to state of saving game from global save function
