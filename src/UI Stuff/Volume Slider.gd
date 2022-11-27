extends HSlider

# Exported Variables
export(String, "Master", "Sfx", "Music") var audio_bus: String = "Master" # Used to choose which audio bus to change

# Onready Variables
onready var current_bus: = AudioServer.get_bus_index(audio_bus) # Gets audiobus that is in use

# Happens when class is first put onto a scene
func _ready() -> void:
	value = db2linear(AudioServer.get_bus_volume_db(current_bus)) # Gets current volume of bus

# Happens on a slider value change
func _on_Volume_Slider_value_changed(value):
	# Changes bus volume to be what the slider has been changes to
	AudioServer.set_bus_volume_db(current_bus, linear2db(value)) 
