extends Spatial

class_name Weapon

onready var _animation_player = $AnimationPlayer
onready var _bullet_emitters_base: Spatial = $BulletEmitters
onready var _bullet_emitters = $BulletEmitters.get_children()

export var is_automatic = false

var _fire_point: Spatial
var _bodies_to_exclude = []

enum WeaponType { RANGED, MELEE }
export(WeaponType) var weapon_type

export var damage = 5
export var ammo = 30

export var attack_rate = 0.2
var _attack_timer: Timer
var _can_attack = true

signal fired
signal out_of_ammo

func _ready():
	_attack_timer = Timer.new()
	_attack_timer.wait_time = attack_rate
	_attack_timer.connect("timeout", self, "finish_attack")
	_attack_timer.one_shot = true
	add_child(_attack_timer)

func init(fire_point: Spatial, bodies_to_exclude: Array):
	_fire_point = fire_point
	_bodies_to_exclude = bodies_to_exclude
	for bullet_emitter in _bullet_emitters:
		bullet_emitter.set_damage(damage)
		bullet_emitter.set_bodies_to_exclude(bodies_to_exclude)

func attack(attack_input_just_pressed: bool, attack_input_held: bool):
	if !_can_attack:
		return
	if is_automatic and !attack_input_held:
		return
	if !is_automatic and !attack_input_just_pressed:
		return
	
	if ammo == 0:
		if attack_input_just_pressed:
			emit_signal("out_of_ammo")
		return

	if ammo > 0:
		ammo -= 1

	# fire bullets
	var start_transform = _bullet_emitters_base.global_transform
	_bullet_emitters_base.global_transform = _fire_point.global_transform
	for bullet_emitter in _bullet_emitters:
		bullet_emitter.fire()
	_bullet_emitters_base.global_transform = start_transform
	_animation_player.stop()
	_animation_player.play("attack")
	emit_signal("fired")
	_can_attack = false
	_attack_timer.start()

func finish_attack():
	_can_attack = true

func enable():
	show()
	$Crosshair.show()

func disable():
	_animation_player.play("idle")
	hide()
	$Crosshair.hide()

func is_idle():
	return !_animation_player.is_playing() or _animation_player.current_animation == 'idle'
