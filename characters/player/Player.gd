extends KinematicBody

class_name Player

const hot_keys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9
}
export var mouse_sensitivity = 0.5

const MAX_VERTICAL_LOOK_ROTATION = 90

onready var _camera = $Camera
onready var _character_mover = $CharacterMover
onready var _health_manager = $HealthManager
onready var _weapon_manager = $Camera/WeaponManager
onready var _pickup_manager = $PickupManager

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_character_mover.init(self)
	_pickup_manager.max_player_health = _health_manager.max_health
	_health_manager.connect("health_changed", _pickup_manager, 'update_player_health')
	_pickup_manager.connect('got_pickup', _weapon_manager, 'get_pickup')
	_pickup_manager.connect('got_pickup', _health_manager, 'get_pickup')
	_health_manager.init()
	_health_manager.connect("dead", self, "kill")
	_weapon_manager.init($Camera/FirePoint, [self])

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	if is_dead():
		return

	_process_movement()
	_process_attacks()

func _process_movement():
	var move_vector = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vector += Vector3.FORWARD
	if Input.is_action_pressed("move_backwards"):
		move_vector += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		move_vector += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		move_vector += Vector3.RIGHT
	_character_mover.set_movement(move_vector)
	if Input.is_action_just_pressed("jump"):
		_character_mover.jump()
	if Input.is_action_pressed("crouch"):
		_character_mover.crouch()

func _process_attacks():
	_weapon_manager.attack(Input.is_action_just_pressed("attack"), Input.is_action_pressed("attack"))

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		_camera.rotation_degrees.x -= mouse_sensitivity * event.relative.y
		_camera.rotation_degrees.x = clamp(_camera.rotation_degrees.x, -MAX_VERTICAL_LOOK_ROTATION, MAX_VERTICAL_LOOK_ROTATION)
	if event is InputEventKey and event.is_pressed():
		if event.scancode in hot_keys:
			_weapon_manager.switch_to_weapon_slot(hot_keys[event.scancode])
	if event.is_action_pressed("weapon_next"):
		_weapon_manager.switch_to_next_weapon()
	if event.is_action_pressed("weapon_previous"):
		_weapon_manager.switch_to_previous_weapon()

func hurt(damage: int, direction: Vector3, position = global_transform.origin + (Vector3.UP * 2)):
	_health_manager.hurt(damage, direction, position)

func heal(amount: int):
	_health_manager.heal(amount)

func is_dead() -> bool:
	return _health_manager.is_dead()

func kill():
	_character_mover.freeze()
	hide()
