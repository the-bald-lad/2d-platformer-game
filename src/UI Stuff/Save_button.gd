extends Button

func _ready():
	text = "Save Game"

func _on_Save_button_up():
	text = PlayerStats.save_game()
