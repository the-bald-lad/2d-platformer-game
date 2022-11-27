extends Control

func _on_Load_button_up():
	var file: File = File.new() # Creates new File type
	
	if file.open(PlayerStats.save_path, File.READ) == OK:
		print(file.READ)
	
	get_node("VBoxContainer/Load").text = PlayerStats.load_game()
