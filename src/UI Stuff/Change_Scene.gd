tool # Means code runs in editor as well as during the game running
extends Button

# Exported variables
# Has a string to be in the inspector, as well as having a file button to easily get file paths
export(String, FILE) var next_scene_path: = ""

# Other Variables
var _tmp

# Gives a warning when file path is empty
func _get_configuration_warning() -> String:
	return "The \'next_scene_path\' needs a valid path" if next_scene_path == "" else ""

# Happens when button is raised
func _on_Start_button_up() -> void:
	_tmp = get_tree().change_scene(next_scene_path) # Changes to selected scene
