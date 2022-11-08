extends position # For player related variables

# Onready Variables
onready var mouse_pos: = get_global_mouse_position() # For mouse position

# Exported Variables
export var ammo: int = 8 # Number of bullets before having to reload

# Variables
var bullet_speed: = 2000 # Speed of bullet when fired
var bullet:       = preload("res://src/Other Stuff/Bullet.tscn")
var frame:        = 0 # Needed for counting time imbetween reloads
var seconds:      = 4 # Amount of time before weapon is reloaded
var ammo_checked: bool # So player cannot shoot when ammo is empty


# Happens when first called
func _ready() -> void:
	gravity = 1100

# Happens every frame
func _physics_process(_delta) -> void:
	mouse_pos = get_global_mouse_position() # Gets mouse x and y
	$".".look_at(mouse_pos) # Looks at mouse
	
	
	position.x = pos.x
	
	# pos.y - 40 so that it is in the center of the player sprite, will probably change when sprites are changed
	position.y = pos.y - 40 
	
	ammo_checked = check_ammo() # Checks the weapon has ammo
	
	if Input.is_action_just_pressed("Shoot") and ammo_checked:
		shoot() # Shoots the weapon
		ammo -= 1

# For creating and firing the bullets
func shoot() -> void:
	var bullet_instance              = bullet.instance() # Creating new instance of the bullet scene
	bullet_instance.position         = get_global_position() # Gets position of the weapon class
	bullet_instance.rotation_degrees = rotation_degrees # Sets rotation to the weapon rotation
	
	# Applies movement to the bullet
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation)) 
	
	get_tree().get_root().call_deferred("add_child", bullet_instance) # Adds the bullet as a child of the weapon

# Checks if the player has sufficient ammo
func check_ammo() -> bool:
	if ammo > 0:
		return true # The player has ammo
	else:
		if frame > (seconds*Engine.get_frames_per_second()): # Have to wait 4 seconds for ammo refil
			ammo  = 8
			frame = 0
		else:
			frame += 1
		return false # The player does not have ammo
