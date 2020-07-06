extends Spatial

onready var _sounds = get_children()

func play():
	_sounds[randi() % _sounds.size()].play()
	
