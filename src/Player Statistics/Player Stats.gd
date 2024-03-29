extends Node

# Signals
signal score_updated # For detecting when the score is updated
signal death_occured # For detecting when the player has died
signal level_finished # For detecting when the level score needs to be added to the total score
signal bullets_updated # For when a bullet is fired
signal reseting # For when the level score needs to go back to 0

# Global Player Statistics
var total_score: int = 0 setget update_total_score 
var level_score: int = 0 setget set_score 
var deaths:      int = 0 setget set_death 
var bullets:     int = 8 setget set_bullets

# For loading nect level, will change if save is loaded
var next_level: String = "res://src/Scenes/Level_0.tscn"

# Variables for HUD
# For checking where the HUD should be placed onto the screen
var levels_list: Array = ["res://src/Scenes/Level_0.tscn", 
						  "res://src/Scenes/Level_2.tscn", 
						  "res://src/Scenes/Level_3.tscn",
						  "res://src/Scenes/Level_3_Empty.tscn",
						  "res://src/Scenes/Wall_Level.tscn",
						  "res://new_level.tscn",
						  "user://saves/new_level.tscn",]

# Variables for Keybinding
var dir: Directory = Directory.new() # For copying files to other locations

var resource_keybind_filepath: String = "res://keybinds.ini" # For default keybinds
var keybind_filepath:          String = "user://keybinds.ini" # For current keybinds

var configfile # For setting the game configurations

var keybinds: Dictionary = {} # For storing the keybinds in use

# Variables for the pause menu
var pause_menu: Resource = preload("res://src/Settings and Pause Menus/Pause_Menu.tscn") # Allows for easy access to the pause menu
var pause_key            = KEY_ESCAPE # Key for pausing the game

# Variables for Saving Game
var encryption_password: String

const dir_path: String  = "user://saves/"

var file_ext: String  = ".dat"
var save_path: String = dir_path + "tmp" + file_ext

var level_path: String = "new_level.tscn" # For loading a saved packed scene

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
		# Outputs standard error
		print(configfile.load(keybind_filepath))

		# Quits game with error code
		get_tree().quit(-1) 

	 # Calls function to set keybinds to the game
	set_key_binds()

# Is called every frame, delta variable is time imbetween frames
func _physics_process(_delta) -> void:
	if get_tree().current_scene.filename in levels_list: # Checks for if current scene is in list of levels
		# Places HUD onto screen
		get_node("Hud/Label").text = "Ammo: %s" % (bullets)
	else:
		# Removes HUD from screen if not a level
		get_node("Hud/Label").text = ""

# For checking inputs during play in the game
func _input(_event) -> void:
	if Input.is_key_pressed(pause_key): # Checks if the esapce key is pressed
		# Adds pause menu to a node in the current level, that is always above everything else in the scene
		get_tree().current_scene.get_node("CanvasLayer2").add_child(pause_menu.instance()) 
		
		# Pauses processing time for the game
		get_tree().paused = true
	if Input.is_action_just_pressed("reload") and bullets != 8: # Checks for if reload key is pressed
		# Resets bullets to 8
		bullets = 8 
		
		# Plays reload sound effect
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
	
	# For getting the current time
	var current_time: String = str(OS.get_unix_time())

	# For file reading and writing
	var file: File       = File.new() # Creates new File type
	var level_file: File = File.new() # Creates second File type

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
		# warning-ignore:return_value_discarded
		dir.make_dir_recursive(dir_path) # Recursive means that each folder will be made along the path if needed

	# Updating save path and encryption password
	save_path = dir_path + current_time + file_ext
	
	encryption_password = current_time # Updates encryption password

	# Saving game with encryption so player cannot cheat and change values in save file
	var code: = file.open_encrypted_with_pass(save_path, File.WRITE, encryption_password)

	if code != OK: # Checks if opening file was opened correctly
		error_occured(save_path, code) # Closes game if file could not be saved
	file.store_var(save_data) # Stores dictionary into encrypted file

	file.close() # Closes file
	return "Game Saved" # Returns text for button to change to

# Loading game saves
func load_game(passed_file) -> String:
	var file: = File.new() # Creates new file type
	var new_load_data: Dictionary # Creates new dictionary type
	var text: String # Creates new String variable

	# Updating opening values
	save_path           = dir_path + passed_file + file_ext
	encryption_password = passed_file


	if file.file_exists(save_path): # Checks save file exists
		var code = file.open_encrypted_with_pass(save_path, File.READ, encryption_password) # Decrypts and opens file 

		if code != OK:
			error_occured(save_path, code) # Closes game if file cannot be opened
		new_load_data = file.get_var() # Gets dictionary from file

		# Setting values to saved values
		next_level  = new_load_data["Current_Level"]["Level_Path"] # Gets new level path
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
func error_occured(thing_that_has_gone_wrong, error) -> void:
	printerr("%s: had error %s" % ([thing_that_has_gone_wrong, error])) # Outputs error with passed in values
	get_tree().quit(-1) # Quits with error code

func quicksort(list) -> Array:
	var list_length = len(list) # Length of list
	
	# Break from recursion loop
	if list_length <= 1:
		return list # Returns one length list
	
	# Pivot Variables
	var pivot_number = rand_range(0, list_length-1) # Gets random list location
	var pivot        = list[pivot_number] # gets pivot value
	
	# For higher and lower numbers
	var lower = []
	var upper = []
	
	# Filtering from pivot
	for num in list:
		if num < pivot:
			lower.append(num)
		if num >= pivot:
			upper.append(num)

	# Returns sorted list by calling same function on new upper and lower lists
	return quicksort(upper) + quicksort(lower)

# Gets lastest Save
func get_latest_enc_pass(path) -> String:
	var files = [] # For files in directory
	var nums  = [] # For file names

	var enc_dir = Directory.new() # For accessing directory files in a listed method

	var out: int = 0 # Output variable, will be returned from function

	#warning-ignore:return_value_discarded
	dir.open(path) # Opens path that is passed through

	# warning-ignore:return_value_discarded
	dir.list_dir_begin() # Starts listing directory

	# For getting all files from directory
	while true:
		var file = dir.get_next() # Gets next file in file list
		if file == "": # Checks if end of directory
			break # Stops loop
		elif not file.begins_with("."): # Does not add hidden files to list
			files.append(file) # Appends file to file list

	enc_dir.list_dir_end() # For stopping the list of directory files

	# For getting numbers from file names
	for file in files:
		nums.append(int(file.split(".")[0])) # Only gets name of file, removes file ext

	# Sets output to be the lastest save
	for i in nums:
		if i > out:
			out = i

	return str(out) # Returns latest save

# Gets the three most recent saves
func get_three_save(path) -> Array:
	var files = [] # For files in directory
	var nums  = [] # For file names

	var enc_dir = Directory.new() # For accessing directory files in a listed method

	var out: Array = [] # Output variable, will be returned from function

	#warning-ignore:return_value_discarded
	dir.open(path) # Opens path that is passed through

	# warning-ignore:return_value_discarded
	dir.list_dir_begin() # Starts listing directory

	# For getting all files from directory
	while true:
		var file = dir.get_next() # Gets next file in file list
		if file == "": # Checks if end of directory
			break # Stops loop
		elif not file.begins_with("."): # Does not add hidden files to list
			files.append(file) # Appends file to file list

	enc_dir.list_dir_end() # For stopping the list of directory files

	# For getting numbers from file names
	for file in files:
		nums.append(int(file.split(".")[0])) # Only gets name of file, removes file ext

	# Sorts list of saves
	var sorted_list = quicksort(nums)
	
	# Print output for debugging
	print("Sorted List: ", sorted_list)
	
	# Output variable
	out = []
	
	# Going through list to get first three
	for file in sorted_list:
		if len(out) > 3:
			break
		out.append(file)
		
	return out # Returns latest save

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
