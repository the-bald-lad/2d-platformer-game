tool
extends Button

export(String, FILE) var next_scene_path: = ""

var current_scene

func _get_configuration_warning() -> String:
	return "The \'next_scene_path\' needs a valid path" if next_scene_path == "" else ""

func _on_Start_button_up() -> void:
	current_scene = get_tree().change_scene(next_scene_path)
