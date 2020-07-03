extends Label

const _MAX_LINES = 5
const _PICKED_UP_MESSAGE = 'Picked up %s'
var _pickups_info = []

func _ready():
	text = ''
	
func add_pickups_info(pickup_type, amount: int):
	$RemoveInfoTimer.start()
	var pickup = Pickup.pickup_name(pickup_type)
	if !Pickup.is_weapon(pickup_type) and amount > 0:
		pickup += ' %s' % amount
	_pickups_info.push_back(_PICKED_UP_MESSAGE % pickup)
	while _pickups_info.size() > _MAX_LINES:
		_pickups_info.pop_front()
	update_display()
	
func remove_pickups_info():
	if _pickups_info.size() > 0:
		_pickups_info.pop_front()
	update_display()
	
func update_display():
	text = ''
	for pickup_info in _pickups_info:
		text += pickup_info + '\n'
