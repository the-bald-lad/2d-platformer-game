extends RigidBody2D

# Onready Variables
onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

# Constant Variables
const FPS: int = 60 

# Other Variables
var frame:   int = 0
var seconds: int = 10


# Happens every frame
func _physics_process(_delta):
	if frame > (FPS*seconds): # After 10 seconds, bullet will be removed from processing queue
		anim_player.play("Fade")
	else:
		frame += 1

# For making the bullets fade after they have hit something
func _on_Wall_Detection_body_entered(_body):
	get_node("Wall Detection/CollisionShape2D").set_deferred("disabled", true)
	anim_player.play("Fade")
