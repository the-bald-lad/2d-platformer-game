extends HSlider

export var audio_bus: = "Master"

onready var current_bus: = AudioServer.get_bus_index(audio_bus)

func _ready() -> void:
	value = db2linear(AudioServer.get_bus_volume_db(current_bus))


func _on_Volume_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(current_bus, linear2db(value))
