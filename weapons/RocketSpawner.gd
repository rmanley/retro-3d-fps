extends Spatial

const _rocket_factory = preload('res://weapons/Rocket.tscn')

var _bodies_to_exclude = []
var _damage = 1

func set_damage(damage: int):
	_damage = damage

func set_bodies_to_exclude(bodies_to_exclude: Array):
	_bodies_to_exclude = bodies_to_exclude

func fire():
	var rocket = _rocket_factory.instance()
	rocket.set_bodies_to_exclude(_bodies_to_exclude)
	get_tree().get_root().add_child(rocket)
	rocket.global_transform = global_transform
	rocket.impact_damage = _damage
