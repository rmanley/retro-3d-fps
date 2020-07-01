extends Spatial

const ENVIRONMENT_LAYER_MASK = 1
const HIT_BOXES_LAYER_MASK = 4
const TARGET_LAYERS = ENVIRONMENT_LAYER_MASK + HIT_BOXES_LAYER_MASK

const _hit_effect_factory = preload('res://effects/BulletHitEffect.tscn')

export var distance = 10000

var _bodies_to_exclude = []
var _damage = 1

func set_damage(damage: int):
	_damage = damage

func set_bodies_to_exclude(bodies_to_exclude: Array):
	_bodies_to_exclude = bodies_to_exclude

func fire():
	var space_state = get_world().get_direct_space_state()
	var our_position = global_transform.origin
	var result = space_state.intersect_ray(
		our_position, 
		our_position - global_transform.basis.z * distance, 
		_bodies_to_exclude,
		TARGET_LAYERS,
		true,
		true
	)
	if result and result.collider.has_method("hurt"):
		result.collider.hurt(_damage, result.normal, result.position)
	elif result:
		var hit_effect = _hit_effect_factory.instance()
		get_tree().get_root().add_child(hit_effect)
		hit_effect.global_transform.origin = result.position
		
		if result.normal.angle_to(Vector3.UP) < 0.00005:
			return
		if result.normal.angle_to(Vector3.DOWN) < 0.00005:
			hit_effect.rotate(Vector3.RIGHT, PI) # if ceiling, point down
			return
		
		# get 3 vectors facing to the right/front relative to the normal
		var y = result.normal # pointing up relative to whatever was hit
		var x = y.cross(Vector3.UP)
		var z = x.cross(y)

		hit_effect.global_transform.basis = Basis(x, y, z)
		
