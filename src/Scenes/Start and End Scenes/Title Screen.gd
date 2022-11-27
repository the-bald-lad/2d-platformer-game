extends Control

var file: File = File.new()

func _on_Continue_button_up():
	if file.open(PlayerStats.save_path, File.READ) == OK:
		print(file.READ)
	
	get_node("Button Container/Continue").text = PlayerStats.load_game()
