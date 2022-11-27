extends Node

# Signals
signal score_updated # For detecting when the score is updated
signal death_occured # For detecting when the player has died
signal level_finished # For detecting when the level score needs to be added to the total score
signal bullets_updated # For when a bullet is fired
signal reseting # For when the level score needs to go back to 0

# Global Player Statistics
var total_score: int = 0 setget update_total_score # Total score of the game
var level_score: int = 0 setget set_score # Score for the current level, is added to total when level is complete
var deaths:      int = 0 setget set_death # Total amounts of player deaths
var bullets:     int = 8 setget set_bullets # Amount of bullets for player

var next_level: String = "res://src/Scenes/Level.tscn"

# Variables for HUD
var levels_list = ["res://src/Scenes/Level.tscn", 
				   "res://src/Scenes/Level_2.tscn", 
				   "res://src/Scenes/Level_3.tscn",
				   "res://src/Scenes/Level_3_Empty.tscn",
				   "res://src/Scenes/Wall_Level.tscn"]

# Variables for Keybinding
var dir = Directory.new() # For copying files to other locations
var resource_keybind_filepath = "res://keybinds.ini" # For default keybinds
var keybind_filepath          = "user://keybinds.ini" # For current keybinds
var configfile # For setting the game configurations

var keybinds = {} # For storing the keybinds in use

# Variables for the pause menu
var pause_menu = preload("res://src/Settings and Pause Menus/Pause_Menu.tscn") # Allows for easy access to the pause menu
var pause_key  = KEY_ESCAPE # Key for pausing the game

# Variables for Saving Game
var encryption_password: String = "a"

const dir_path: String  = "user://saves/"

var save_path: String  = dir_path + "save.dat"
var level_path: String = dir_path + "new_level.tscn"

# Happens when game is first launced
func _ready() -> void:
	# Copys from read-only resource directory to the writable user directory
	var keybind_file_status = dir.copy(resource_keybind_filepath, "user://keybinds.ini") 

	# Quits game if config copys incorrectly
	# warning-ignore:standalone_ternary
	print("Keybinds copy was sucessful") if keybind_file_status == 0 else get_tree().quit(-1)

	configfile = ConfigFile.new() # Creates new configuration file
	if configfile.load(keybind_filepath) == OK: # Checks that the file loads correctly
		for key in configfile.get_section_keys("keybinds"): # Goes through each keybind in the config file
			var key_value = configfile.get_value("keybinds", key) # Gets integer value of key in use for each key bind
			print(key, ": ", OS.get_scancode_string(key_value)) # Outputs to console for testing

			if str(key_value) != "":
				keybinds[key] = key_value # sets a new keybind in the dictionary
			else:
				keybinds[key] = null
	else: # Config file has not loaded correctly
		print(configfile.load(keybind_filepath)) # Outputs standard error
		get_tree().quit(-1) # Quits game with error code
	
	set_key_binds() # Calls function to set keybinds to the game

# Happens Every Frame
func _physics_process(_delta) -> void:
	if get_tree().current_scene.filename in levels_list: # Checks for if current scene is in list of levels
		get_node("Hud/Label").text = "Ammo: %s" % (bullets) # Places HUD onto screen
	else:
		get_node("Hud/Label").text = "" # Removes HUD from screen if not a level

# For checking inputs during play in the game
func _input(_event) -> void:
	if Input.is_key_pressed(pause_key): # Checks if the esapce key is pressed
		# Adds pause menu to a node in the current level, that is always above everything else in the scene
		get_tree().current_scene.get_node("CanvasLayer2").add_child(pause_menu.instance()) 
		
		# Pauses processing time for the game
		get_tree().paused = true
	if Input.is_action_just_pressed("reload") and bullets != 8: # Checks for if reload key is pressed
		bullets = 8 # Resets bullets to 8
		get_node("Reload").play()

# For setting the keybinds to the game
func set_key_binds() -> void:
	for key in keybinds.keys(): # Goes through each key in the dictionary
		var value = keybinds[key] # Gets current keybind
		
		var actionlist = InputMap.get_action_list(key) # Gets old keybind

		if !actionlist.empty(): # Checking for if the keybind already exists
			InputMap.action_erase_event(key, actionlist[0]) # Removes old keybind

		if value != null:
			var new_key = InputEventKey.new() # Creates new keybind
			new_key.set_scancode(value) # Sets it to the correct value
			InputMap.action_add_event(key, new_key) # Assigns it to the correct inputmap event

# For writing keybind changes to the config file
func write_config() -> void:
	for key in keybinds.keys(): # Goes through each keybind
		var key_value = keybinds[key] # Gets value of key that is binded to the action
		if key_value != null:
			configfile.set_value("keybinds", key, key_value) # Sets keybind to the updated key
		else:
			configfile.set_value("keybinds", key, "") # Sets keybind to null
	configfile.save(keybind_filepath) # Saves file to correct location

# For saving the game to a file
func save_game() -> String:
	# Directory creation and deletion
	var save_dir: Directory = Directory.new() # Creates new Directory type
	
	# For file reading and writing
	var file: File = File.new() # Creates new File type
	var level_file: = File.new() # Creates second File type
	
	# For saving current level and nodes
	var level: PackedScene = PackedScene.new() # Makes empty PackedScene type
	
	var pack_error = level.pack(get_tree().get_current_scene()) # Packs current level into PackedScene
	
	if pack_error != OK:
		error_occured("Pack", pack_error) # Closes game if pack did not work correctly
	
	if level_file.file_exists(level_path):
		# warning-ignore:return_value_discarded
		save_dir.remove(level_path) # Removes old packed level from the saves directory
	
	var save_error = ResourceSaver.save(level_path, level) # Saves level to the level save location
	
	if save_error != OK:
		error_occured("Save", save_error) # Closes game if save did not work correctly

	# What is being saved in the save file
	var save_data: Dictionary = {
		"Current_Level" : { # Contains all values pertaining to the level
			"Level_Path" : get_tree().current_scene.filename, # File path of current level
			"New_Level_Path" : level_path, # For the path of the new packed level
		},
		"Player" : { # Contains all values pertaining to the player
			"Ammo" : bullets, # Amount of ammo the player had
			"Total_Score" : total_score, # Amount of score the player had
			"Level_Score" : level_score, # The progress of the current level
			"Deaths" : deaths, # The amount of deaths the player had
		},
	}

	if !dir.dir_exists(dir_path): # Checking if the save directory exists
		dir.make_dir_recursive(dir_path) # Recursive means that each folder will be made along the path if needed

	# Saving game with encryption so player cannot cheat and change values in save file
	var code: = file.open_encrypted_with_pass(save_path, File.WRITE, encryption_password)

	if code != OK:
		error_occured(save_path, code) # Closes game if file could not be saved
	file.store_var(save_data) # Stores dictionary into encrypted file

	file.close() # Closes file
	return "Game Saved" # Returns text for button to change to

# Loading game saves
func load_game() -> String:
	var file: = File.new() # Creates new file type
	var new_load_data: Dictionary # Creates new dictionary type
	var text: String # Creates new String variable
	
	if file.file_exists(save_path): # Checks save file exists
		var code = file.open_encrypted_with_pass(save_path, File.READ, encryption_password) # Decrypts and opens file 

		if code != OK:
			error_occured(save_path, code) # Closes game if file cannot be opened
		new_load_data = file.get_var() # Gets dictionary from file

		# Setting values to saved values
		next_level = new_load_data["Current_Level"]["New_Level_Path"] # Gets new level path

		bullets     = new_load_data["Player"]["Ammo"] # Sets ammo to saved amount
		total_score = new_load_data["Player"]["Total_Score"] # Sets total score to saved amount
		level_score = new_load_data["Player"]["Level_Score"] # Sets level score to saved amount
		deaths      = new_load_data["Player"]["Deaths"] # Sets amount of deaths to saved amount

		text = "Game Loaded From Latest Save" # Text for button text to be changed to

		var level = load(level_path) # Loads level from packed scene file

		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(level) # Changes level to saved level
	else:
		text = "No Save Data Found" # Sets button text to this if no save data is found

	file.close() # Closes file
	return text # Returns text for button text to be changed

# If an error happens
func error_occured(thing, error) -> void:
	printerr("%s: had error %s" % ([thing, error])) # Outputs error with passed in values
	get_tree().quit(-1) # Quits with error code

# Sets level score when called 
func set_score(value: int) -> void:
	level_score = value
	emit_signal("score_updated")

# Sets deaths to new value and resets current score
func set_death(value: int) -> void:
	deaths      = value
	level_score = 0
	emit_signal("death_occured")

# Updates total score to be the same as the level score, as well as reseting the level score
func update_total_score(_value: int) -> void:
	total_score += level_score
	level_score  = 0
	emit_signal("level_finished")

func set_bullets(value: int) -> void:
	bullets = value
	emit_signal("bullets_updated")

# Resets everything
func reset() -> void:
	total_score = 0
	deaths      = 0
	emit_signal("reseting")
