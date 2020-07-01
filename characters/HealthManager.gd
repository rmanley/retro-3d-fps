extends Spatial

const _blood_spray_factory = preload('res://effects/BloodSpray.tscn')
const _gibs_factory = preload("res://effects/Gibs.tscn")

signal dead
signal gibbed
signal hurt
signal healed
signal health_changed

export var max_health = 100
var _current_health: int

export var gib_threshold = -10

func _ready():
	init()

func init():
	_current_health = max_health
	_on_health_changed()

func is_dead() -> bool:
	return _current_health <= 0

func hurt(damage: int, direction: Vector3, position = global_transform.origin):
	_spawn_blood(direction, position)
	if is_dead():
		return
	_current_health -= damage
	if _current_health <= gib_threshold:
		_spawn_gibs()
		emit_signal("gibbed")
	if is_dead():
		emit_signal("dead")
	else:
		emit_signal("hurt")
	_on_health_changed()

func heal(amount: int):
	if is_dead():
		return
	_current_health += amount
	if _current_health > max_health:
		_current_health = max_health
	emit_signal("healed")
	_on_health_changed()

func _on_health_changed():
	emit_signal("health_changed", _current_health)
	
func get_pickup(pickup_type, ammount: int):
	if pickup_type == Pickup.PickupType.HEALTH:
		heal(ammount)
	
func _spawn_blood(direction: Vector3, position: Vector3):
	var blood_spray = _blood_spray_factory.instance()
	get_tree().get_root().add_child(blood_spray)
	blood_spray.global_transform.origin = position
	
	if direction.angle_to(Vector3.UP) < 0.00005:
		return
	if direction.angle_to(Vector3.DOWN) < 0.00005:
		blood_spray.rotate(Vector3.RIGHT, PI) # if ceiling, point down
		return
	
	# get 3 vectors facing to the right/front relative to the normal
	var y = direction # pointing up relative to whatever was hit
	var x = y.cross(Vector3.UP)
	var z = x.cross(y)

	blood_spray.global_transform.basis = Basis(x, y, z)
	
func _spawn_gibs():
	var gibs = _gibs_factory.instance()
	get_tree().get_root().add_child(gibs)
	gibs.global_transform.origin = global_transform.origin
	gibs.enable_gibs()
