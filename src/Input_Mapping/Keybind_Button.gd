extends Button

# Variables for changing button aspects
var key
var value
var menu

# If button is pressed down
var waiting_input = false

# Detects if a button is pressed
func _input(event):
	if waiting_input: # Checks for if the button is pressed down
		if event is InputEventKey: # Checks if input type is a keypress
			value = event.scancode # Sets value to new value from the keypress
			text  = OS.get_scancode_string(value) # Sets text to be new key
			
			menu.change_keybinds(key, value) # Changes keybinds in other script
		if event is InputEventMouseButton: # Checks if input type is a mouse click
			if value != null: # Checks to see if value is null
				text = OS.get_scancode_string(value) # Sets text to old value
			else:
				text = "Unassigned" # Sets text to be unassigned
		pressed       = false # Makes button not pressed
		waiting_input = false # Makes it so that button presses no longer change keybinds

# When the button is toggled
func _toggled(button_pressed):
	if button_pressed: # Checks to see if the button has been pressed down
		waiting_input = true # Sets variable to true
		set_text("Press Any Key") # Changes button text
	get_tree().current_scene.get_node("Button Container/Save_Config").text = "Save Keybinds" # Sets save keybinds button back to save keybinds
