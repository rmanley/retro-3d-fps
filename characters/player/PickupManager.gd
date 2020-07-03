extends Area

signal got_pickup

var max_player_health: int
var _current_player_health: int

func update_player_health(amount: int):
	_current_player_health = amount

func _ready():
	connect('area_entered', self, 'on_area_entered')
	
func on_area_entered(pickup: Pickup):
	if pickup.pickup_type == Pickup.PickupType.HEALTH and _current_player_health == max_player_health:
		return
	emit_signal('got_pickup', pickup.pickup_type, pickup.amount)
	pickup.queue_free()
