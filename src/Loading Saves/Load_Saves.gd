extends Control

# Called when button is lifted
func _on_Load_button_up():
	var file: File = File.new() # Creates new File type, for accessing files in a given directory
	
	# Checking file opens correctly
	if file.open(PlayerStats.save_path, File.READ) == OK:
		print(file.READ)
	
	get_node("VBoxContainer/Load").text = PlayerStats.load_game() # Loads save game, calls from global script
