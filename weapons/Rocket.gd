extends KinematicBody

const _explosion_factory = preload('res://weapons/Explosion.tscn')

var _speed = 40
var impact_damage = 20
var _has_exploded = false

func _ready():
	hide()

func set_bodies_to_exclude(bodies_to_exclude: Array):
	for body in bodies_to_exclude:
		add_collision_exception_with(body)

func _physics_process(delta):
	var collision: KinematicCollision = move_and_collide(-global_transform.basis.z * _speed * delta)
	if collision:
		var collider = collision.collider
		if collider.has_method('hurt'):
			collider.hurt(impact_damage, -global_transform.basis.z, global_transform.origin) # -basis.z == direction facing
		explode()

func explode():
	if _has_exploded:
		return
	_has_exploded = true
	_speed = 0
	$CollisionShape.disabled = true
	var explosion = _explosion_factory.instance()
	get_tree().get_root().add_child(explosion)
	explosion.global_transform.origin = global_transform.origin
	explosion.explode()
	$SmokeTrail.emitting = false
	$Graphics.hide()
	$DestroyAfterHitTimer.start()
