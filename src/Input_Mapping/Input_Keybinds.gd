extends Control

# Created when first called
onready var button_container = get_node("Button Container")
onready var button_script    = load("res://src/Input_Mapping/Keybind_Button.gd") # Loading sctipt into this sctipt

# Variables for button
var keybinds
var buttons = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	keybinds = PlayerStats.keybinds.duplicate() # Makes a copy of the keybinds in use
	for key in keybinds: # Goes through each keybind
		var hbox   = HBoxContainer.new() # Creates new horizontal box container
		var label  = Label.new() # Creates a new label
		var button = Button.new() # Creates a new button

		# Setting sizes of nodes in the game to be fully expanded
		hbox.set_h_size_flags(SIZE_EXPAND_FILL)
		label.set_h_size_flags(SIZE_EXPAND_FILL)
		button.set_h_size_flags(SIZE_EXPAND_FILL)

		# Sets label to have text of keybind option
		label.text = key

		# Creates a variable that stores the integer of the current key that is binded to the action
		var button_value = keybinds[key]
		
		if button_value != null: # Checks button is not unaasigned
			button.text = OS.get_scancode_string(button_value) # Sets button text to be current key
		else:
			button.text = "Unassigned" # Sets button text to be unassigned

		# Apply's settings to the buttons
		button.set_script(button_script) # Attaches script to each button
		button.key   = key
		button.value = button_value
		button.menu  = self
		
		button.toggle_mode = true
		button.focus_mode  = Control.FOCUS_NONE

		# Applying settings the horizontal boxes 
		hbox.add_child(label) # Adds the current label as a child to the current box
		hbox.add_child(button) # Adds the current button as a child to the current box

		# Adds horizontal box as a child to the button container
		button_container.add_child(hbox)

		# Adds button into the dictionary
		buttons[key] = button

# For changing the keybinds
func change_keybinds(key, value):
	keybinds[key] = value # Makes the key passed through be the value that is passed through
	for i in keybinds.keys(): # Loops through each key in the keybinds dictionary
		if i != key and value != null and keybinds[i] == value: # Checks if key is already assigned to an action
			keybinds[i]      = null # Sets values to null
			buttons[i].value = null
			buttons[i].text  = "Unassigned"

# When button is pressed
func _on_Save_Config_pressed():
	PlayerStats.keybinds = keybinds.duplicate() # Duplicates keybind dictionary from PlayerStats
	PlayerStats.set_key_binds() # Calls global script to set new keybinds
	PlayerStats.write_config() # Writes new keybinds to configuration file
	get_node("Button Container/Save Config").text = "Keybinds Saved!" # Changes text to inform player that keybinds are saved
