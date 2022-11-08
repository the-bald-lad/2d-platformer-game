tool
extends Area2D

# Starting variables
onready var anim_player: AnimationPlayer = $AnimationPlayer # Gets animation node

# For easily adding teleport destination
# This will be placed into the inspector, scene can be dragged into that
export var next_scene: PackedScene # For setting the next scene

# Other Variables
var tmp


# Giving warning to add a destination to the portal. 
func _get_configuration_warning() -> String:
	return "The \'next scene\' script variable cannot be empty" if not next_scene else ""

# For when a valid mask object enters the portal
func _on_body_entered(_body) -> void:
	teleport()

# The teleport mechanics
func teleport() -> void:
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
	PlayerStats.update_total_score(1)
	
	anim_player.play("Fade_In") # Plays fade animation
	yield(anim_player, "animation_finished") # Returns values but does not cease operation
	tmp = get_tree().change_scene_to(next_scene) # Changes scene to the specified scene
