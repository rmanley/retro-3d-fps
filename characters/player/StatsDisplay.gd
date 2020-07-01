extends Label

const DISPLAY = "Health: %d\nAmmo: %s"
var _ammo = 0
var _health = 0

func update_ammo(amount: int):
	_ammo = amount
	update_display()

func update_health(amount: int):
	_health = amount
	update_display()
	
func update_display():
	var ammo = _ammo
	if _ammo < 0:
		ammo = '~'
	text = DISPLAY % [_health, ammo]
