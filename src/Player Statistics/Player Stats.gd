extends Node

signal score_updated
signal death_occured
signal level_finished

var total_score:  = 0 setget update_total_score
var level_score:  = 0 setget set_score
var deaths:       = 0 setget set_death

func set_score(value: int) -> void:
	level_score = value
	emit_signal("score_updated")

func set_death(value: int) -> void:
	deaths = value
	level_score = 0
	emit_signal("death_occured")

func update_total_score(_value: int) -> void:
	total_score += level_score
	level_score  = 0
	emit_signal("level_finished")

func reset() -> void:
	total_score  = 0
	deaths = 0

func _physics_process(_delta):
	pass # print("Level Score: ", level_score, ". Deaths: ", deaths, ". Total Score: ", total_score)
