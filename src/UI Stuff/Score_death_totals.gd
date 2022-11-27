extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "Score: %s\nDeaths: %s" % ([PlayerStats.total_score, PlayerStats.deaths])
