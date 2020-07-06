extends KinematicBody

onready var _character_mover: CharacterMover = $CharacterMover
onready var _animation_player = $Graphics/AnimationPlayer
onready var _health_manager = $HealthManager
onready var _nav: Navigation = get_parent()

const ENVIRONMENT_LAYER_MASK = 1

enum State { IDLE, CHASE, ATTACK, DEAD }
var _current_state = State.IDLE

var _player: Player
var _path = []

export var sight_angle = 45.0
export var turn_speed = 360.0
export var attack_angle = 5.0
export var attack_range = 2.0
export var attack_rate = 1.0
export var attack_animation_speed = 0.5

var _attack_timer: Timer
var _can_attack = true
signal attack

func _ready():
	for weapon in $AimAtObject.get_children():
		if weapon.has_method('set_bodies_to_exclude'):
			weapon.set_bodies_to_exclude([self])
	_attack_timer = Timer.new()
	_attack_timer.wait_time = attack_rate
	_attack_timer.connect('timeout', self, 'finish_attack')
	_attack_timer.one_shot = true
	add_child(_attack_timer)
	
	_player = get_tree().get_nodes_in_group('player')[0]
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect('hurt', self, 'hurt')
				
	_health_manager.connect('dead', self, 'set_state_dead')
	_health_manager.connect('gibbed', self, 'hide')
	_character_mover.init(self)
	set_state_idle()

func _process(delta):
	match _current_state:
		State.IDLE:
			_process_state_idle(delta)
		State.CHASE:
			_process_state_chase(delta)
		State.ATTACK:
			_process_state_attack(delta)
		State.DEAD:
			_process_state_dead(delta)
			
func set_state_idle():
	_current_state = State.IDLE
	_animation_player.play("idle_loop")

func set_state_chase():
	_current_state = State.CHASE
	_animation_player.play("walk_loop", 0.2)

func set_state_attack():
	_current_state = State.ATTACK
	_animation_player.play("attack", -1, attack_animation_speed)
	
func set_state_dead():
	_current_state = State.DEAD
	_animation_player.play("die")
	_character_mover.freeze()
	$CollisionShape.disabled = true
	
func _process_state_idle(delta):
	if can_see_player():
		set_state_chase()
	
func _process_state_chase(delta):
	if is_within_distance_of_player(attack_range) and is_player_in_line_of_sight():
		set_state_attack()
	var player_position = _player.global_transform.origin
	var our_position = global_transform.origin
	_path = _nav.get_simple_path(our_position, player_position)
	var goal_position = player_position
	if _path.size() > 1: # first is always self
		goal_position = _path[1]
		
	var direction = goal_position - our_position
	direction.y = 0
	_character_mover.set_movement(direction)
		
	face_direction(direction, delta)
	
func _process_state_attack(delta):
	_character_mover.set_movement(Vector3.ZERO)	
	if _can_attack:
		if !is_within_distance_of_player(attack_range) or !can_see_player():
			set_state_chase() 
		elif !is_player_within_angle(attack_angle):
			face_direction(global_transform.origin.direction_to(_player.global_transform.origin), delta)
		else:
			start_attack()			
	
func _process_state_dead(delta):
	pass

func hurt(damage: int, direction: Vector3, position = global_transform.origin + (Vector3.UP * 2)):
	if _current_state == State.IDLE:
		set_state_chase()
	_health_manager.hurt(damage, direction, position)
	
func start_attack():
	_can_attack = false
	emit_attack_signal()
	_animation_player.play("attack")
	_attack_timer.start()
	
func finish_attack():
	_can_attack = true
	
func emit_attack_signal():
	emit_signal("attack")

func can_see_player() -> bool:
	return is_player_within_angle(sight_angle) and is_player_in_line_of_sight()

func is_player_within_angle(angle: float) -> bool:
	var direction_to_player = global_transform.origin.direction_to(_player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(direction_to_player)) < angle

func is_player_in_line_of_sight() -> bool:
	var our_position = global_transform.origin + Vector3.UP # add 1 unit up from floor for raycast to be higher
	var player_position = _player.global_transform.origin + Vector3.UP
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_position, player_position, [], ENVIRONMENT_LAYER_MASK)
	if result:
		return false
	return true
	
func is_within_distance_of_player(distance: float) -> bool:
	return _player.global_transform.origin.distance_to(global_transform.origin) < distance

func face_direction(direction: Vector3, delta):
	var angle_difference = global_transform.basis.z.angle_to(direction)
	var turn_direction = sign(global_transform.basis.x.dot(direction)) # positive, right, negative, left
	if abs(angle_difference) < deg2rad(turn_speed) * delta:
		rotation.y = atan2(direction.x, direction.z) # if will overshoot angle, set to goal angle
	else:
		rotation.y += deg2rad(turn_speed) * delta * turn_direction

func alert(should_check_line_of_sight = true):
	if _current_state != State.IDLE:
		return
	if should_check_line_of_sight and !is_player_in_line_of_sight():
		return
	set_state_chase()
