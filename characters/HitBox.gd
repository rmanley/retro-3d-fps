extends Area

class_name HitBox

export var is_weak_spot = false
export var critical_damage_multiplier = 2
signal hurt

func hurt(damage: int, direction: Vector3, position = Vector3.ZERO):
	if is_weak_spot:
		emit_signal('hurt', damage * critical_damage_multiplier, direction, position)
	else:
		emit_signal('hurt', damage, direction, position)
