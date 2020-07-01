extends Spatial

export var flash_time = 0.05
var _timer: Timer

func _ready():
	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = flash_time
	_timer.connect("timeout", self, "end_flash")
	hide()

func flash():
	_timer.start()
	rotation.z = rand_range(0.0, 2 * PI)
	show()

func end_flash():
	hide()
