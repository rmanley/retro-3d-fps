extends Spatial

const _fireball_factory = preload('res://weapons/Fireball.tscn')

var _bodies_to_exclude = []
var _damage = 20

func set_damage(damage: int):
	_damage = damage

func set_bodies_to_exclude(bodies_to_exclude: Array):
	_bodies_to_exclude = bodies_to_exclude

func fire():
	var fireball = _fireball_factory.instance()
	fireball.set_bodies_to_exclude(_bodies_to_exclude)
	get_tree().get_root().add_child(fireball)
	fireball.global_transform = global_transform
	fireball.impact_damage = _damage
