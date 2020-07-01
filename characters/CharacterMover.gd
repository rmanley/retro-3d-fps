extends Spatial

class_name CharacterMover

var _body_to_move: KinematicBody = null

export var move_acceleration = 4
export var max_speed = 25
var drag = 0.0
export var jump_force = 30
export var gravity = 60

var _is_jumping = false
var _move_vector: Vector3
var _velocity: Vector3
const FALL_SPEED = -0.01
var _snap_vector: Vector3
export var should_ignore_rotation = false

signal movement_info

var _is_frozen = false

func _ready():
	drag = float(move_acceleration) / max_speed

func init(body_to_move):
	_body_to_move = body_to_move

func jump():
	_is_jumping = true
	
func crouch():
	if !_body_to_move.is_on_floor():
		return
	_body_to_move.translate(Vector3(0, -0.5, 0))

func set_movement(move_vector):
	_move_vector = move_vector.normalized()

func _physics_process(delta):
	if _is_frozen:
		return
	var current_movement_vector = _move_vector
	if !should_ignore_rotation:
		current_movement_vector = current_movement_vector.rotated(Vector3.UP, _body_to_move.rotation.y)
	_velocity += move_acceleration * current_movement_vector - _velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	_velocity = _body_to_move.move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP)

	var is_grounded = _body_to_move.is_on_floor()
	if is_grounded:
		_velocity.y = FALL_SPEED
		if _is_jumping:
			_velocity.y = jump_force
			_snap_vector = Vector3.ZERO # to keep from sticking to ground
		else:
			_snap_vector = Vector3.DOWN # stick to ground
	_is_jumping = false
	emit_signal("movement_info", _velocity, is_grounded)

func freeze():
	_is_frozen = true

func unfreeze():
	_is_frozen = false
