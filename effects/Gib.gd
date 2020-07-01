extends KinematicBody

export var start_move_speed = 30
export var gravity = 35.0
export var drag = 0.01
export var velocity_retained_on_bounce = 0.8

var _velocity = Vector3.ZERO
var _is_initialized = false

func init():
	_is_initialized = true
	_velocity = -global_transform.basis.y * start_move_speed
	
func _physics_process(delta):
	if !_is_initialized:
		return
	_velocity += -_velocity * drag + Vector3.DOWN * gravity * delta
	var collision = move_and_collide(_velocity * delta)
	if collision:
		var direction = _velocity
		var normal = collision.normal
		# r = d-2(d . n)n equation for reflected vector
		var reflected_vector = direction - 2 * direction.dot(normal) * normal 
		_velocity = reflected_vector * velocity_retained_on_bounce
