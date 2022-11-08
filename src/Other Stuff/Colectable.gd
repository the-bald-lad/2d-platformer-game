extends Node

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer") # getting the animation node

# When a relevant mask enters the collectables hitbox
func _on_body_entered(_body):
	PlayerStats.level_score += 1
	anim_player.play("Fade")
	get_node("CollisionShape2D").set_deferred("disabled", true)
