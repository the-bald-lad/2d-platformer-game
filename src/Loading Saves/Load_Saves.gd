extends Control

# Onready variables
onready var button_container = get_node("VBoxContainer") # Gets button container from current scene

# Variables for button node
var button_script = load("res://src/Loading Saves/load_button.gd")
var save_location = "user://saves/"

# Variables for formatting dates
var days = {
	0 : "Sunday",
	1 : "Monday",
	2 : "Tuesday",
	3 : "Wednesday",
	4 : "Thursday",
	5 : "Friday",
	6 : "Saturday"
} # For changing days to strings

var months = {
	1  : "January",
	2  : "February",
	3  : "March",
	4  : "April",
	5  : "May",
	6  : "June",
	7  : "July",
	8  : "August",
	9  : "September",
	10 : "October",
	11 : "November",
	12 : "December",
} # For changing months to strings

# Called when first loaded
func _ready() -> void:
	# Setting title to centre of screen
	# warning-ignore:standalone_expression
	get_node("Game Title").ALIGN_CENTER
	
	# Gets three most recent saves
	var saves = PlayerStats.get_three_save(save_location)
	
	# Checking for save files
	if len(saves) <= 0:
		get_node("Game Title").text = "No Saves Found!"
	
	# Vars for numbering saves
	var num = 1
	
	# Printing saves loaded for testing
	print("Saves: " + str(saves))
	
	# Loops through each save in saves list
	for save in saves:
		var hbox   = HBoxContainer.new() # Creates new horizontal box container
		var label  = Label.new() # Creates a new label
		var button = Button.new() # Creates a new button
		
		# Getting time of save
		var date_dict = OS.get_datetime_from_unix_time(save)
		
		# Output of dictionary for debugging formatting
		#print("Date dict: ", date_dict)
		
		# Formatting full date variables
		var hour   = date_dict["hour"]
		var minute = date_dict["minute"]
		var day    = days[date_dict["weekday"]]
		var date   = str(date_dict["day"])
		var month  = months[date_dict["month"]]
		var year   = date_dict["year"]
		
		var default_ending = "th"
		
		# Formatting date
		if date == "11" or date == "12" or date == "13":
			date += default_ending
		elif date.ends_with("1"):
			date += "st"
		elif date.ends_with("2"):
			date += "nd"
		elif date.ends_with("3"):
			date += "rd"
		else:
			date += default_ending
		
		# Creating text for the label
		var label_text = "%s:%s %s %s %s %s" % [hour, minute, day, date, month, year]
		
		# Printing for debugging
		print("Label: ", label_text)
		
		# Setting text for nodes created
		label.text  = label_text
		button.text = "Load Save " + str(num)
		
		# Setting size flags
		hbox.set_h_size_flags(SIZE_EXPAND_FILL)
		label.set_h_size_flags(SIZE_EXPAND_FILL)
		button.set_h_size_flags(SIZE_EXPAND_FILL)
		
		# Sets value of button to the save file
		var button_value = str(save)
		
		# Setting button values
		button.set_script(button_script) # Attaches script to button
		button.file_name = button_value # Sets button value into button
		
		# Applying settings the horizontal boxes 
		hbox.add_child(label) # Adds the current label as a child to the current box
		hbox.add_child(button) # Adds the current button as a child to the current box

		# Adds horizontal box as a child to the button container
		button_container.add_child(hbox)
		
		print("Button Value: ", button_value)
		
		# Increments num of save file
		num += 1
