extends position # For player related variables

# Onready Variables
onready var mouse_pos:   = get_global_mouse_position() # For mouse position

# Variables
var bullet_speed:     = 2000 # Speed of bullet when fired
var bullet:           = preload("res://src/Other Stuff/Bullet.tscn")
var frame:            = 0 # Needed for counting time imbetween reloads
var seconds:          = 4 # Amount of time before weapon is reloaded
var ammo_checked: bool # So player cannot shoot when ammo is 

# Happens when first called
func _ready() -> void:
	gravity = 1100

# Happens every frame
func _physics_process(_delta) -> void:
	mouse_pos = get_global_mouse_position() # Gets mouse x and y
	$".".look_at(mouse_pos) # Looks at mouse
	
	# Places gun on x axis
	position.x = pos.x
	
	# pos.y - 40 so that it is in the center of the player sprite, will probably change when sprites are changed
	position.y = pos.y - 40 
	
	if Input.is_action_just_pressed("Shoot") and check_ammo():
		shoot() # Shoots the weapon
		PlayerStats.bullets -= 1

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
	if PlayerStats.bullets > 0:
		get_node("Gun Shot").play()
		return true # The player has ammo
	else:
		get_node("Empty").play()
		return false # The player does not have ammo
