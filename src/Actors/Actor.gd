extends KinematicBody2D
class_name Actor # So that it is easier to be a base class

# Constant Variables
const FLOOR_NORMAL: = Vector2.UP

# Setting default and maximum values for movement variables
# Variables to be exported into the Inspector for easy editing. 
export var speed:   = Vector2(300.0, 1000.0)
export var gravity: = 3000.0

# Setting an empty variable for velocity
# Other inherrited variables
var velocity: = Vector2.ZERO
