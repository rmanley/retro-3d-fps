extends Area

var _bodies_to_exclude = []
var _damage = 15

func set_damage(damage: int):
	_damage = damage

func set_bodies_to_exclude(bodies_to_exclude: Array):
	_bodies_to_exclude = bodies_to_exclude

func fire():
	for body in get_overlapping_bodies():
		if body.has_method("hurt") and !body in _bodies_to_exclude:
			body.hurt(_damage, global_transform.origin.direction_to(body.global_transform.origin))
