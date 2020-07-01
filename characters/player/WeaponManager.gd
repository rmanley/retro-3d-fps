extends Spatial

enum WeaponSlot { MACHETE, MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER }
const slots_unlocked = {
	WeaponSlot.MACHETE: true,
	WeaponSlot.MACHINE_GUN: false,
	WeaponSlot.SHOTGUN: false,
	WeaponSlot.ROCKET_LAUNCHER: false
}

onready var _animation_player = $AnimationPlayer
onready var weapons = $Weapons.get_children()
onready var alert_area_hearing = $AlertAreaHearing
onready var alert_area_line_of_sight = $AlertAreaLineOfSight

var current_WeaponSlot = 0
var current_weapon = null

var _fire_point: Spatial
var _bodies_to_exclude = []

signal ammo_changed

func init(fire_point: Spatial, bodies_to_exclude: Array):
	_fire_point = fire_point
	_bodies_to_exclude = bodies_to_exclude
	for weapon in weapons:
		if weapon is Weapon:
			weapon.init(fire_point, bodies_to_exclude)
			if weapon.weapon_type == Weapon.WeaponType.RANGED:
				weapon.connect('fired', self, 'emit_ammo_changed_signal')
				weapon.connect('fired', self, 'alert_nearby_enemies')
	
	switch_to_weapon_slot(WeaponSlot.MACHETE)

func attack(attack_input_just_pressed: bool, attack_input_held: bool):
	if current_weapon.has_method("attack"):
		current_weapon.attack(attack_input_just_pressed, attack_input_held)

func switch_to_next_weapon():
	current_WeaponSlot = (current_WeaponSlot + 1) % slots_unlocked.size()
	if !slots_unlocked[current_WeaponSlot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(current_WeaponSlot)

func switch_to_previous_weapon():
	current_WeaponSlot = posmod((current_WeaponSlot - 1), slots_unlocked.size())
	if !slots_unlocked[current_WeaponSlot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(current_WeaponSlot)

func switch_to_weapon_slot(slot_index: int):
	if slot_index < 0 or slot_index >= slots_unlocked.size():
		return
	if !slots_unlocked[slot_index]:
		return
	disable_all_weapons()
	current_weapon = weapons[slot_index]
	if current_weapon.has_method("enable"):
		current_weapon.enable()
	else:
		current_weapon.show()
	emit_ammo_changed_signal()

func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("disable"):
			weapon.disable()
		else:
			weapon.hide()

func update_animation(velocity: Vector3, is_grounded: bool):
	if current_weapon.has_method('is_idle') and !current_weapon.is_idle():
		_animation_player.play('idle')
	if !is_grounded or velocity.length() < 15.0:
		_animation_player.play('idle', 0.05)
	_animation_player.play('moving')
	
func alert_nearby_enemies():
	var nearby_enemies = alert_area_line_of_sight.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method('alert'):
			nearby_enemy.alert()
	nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method('alert'):
			nearby_enemy.alert(false)

func get_pickup(pickup_type, ammo: int):
	match pickup_type:
		Pickup.PickupType.MACHINE_GUN:
			_unlock(WeaponSlot.MACHINE_GUN, ammo)
		Pickup.PickupType.MACHINE_GUN_AMMO:
			_pickup_ammo(WeaponSlot.MACHINE_GUN, ammo)
		Pickup.PickupType.SHOTGUN:
			_unlock(WeaponSlot.SHOTGUN, ammo)
		Pickup.PickupType.SHOTGUN_AMMO:
			_pickup_ammo(WeaponSlot.SHOTGUN, ammo)
		Pickup.PickupType.ROCKET_LAUNCHER:
			_unlock(WeaponSlot.ROCKET_LAUNCHER, ammo)
		Pickup.PickupType.ROCKET_LAUNCHER_AMMO:
			_pickup_ammo(WeaponSlot.ROCKET_LAUNCHER, ammo)
				
func _unlock(weapon_slot, ammo):
	if !slots_unlocked[weapon_slot]:
		slots_unlocked[weapon_slot] = true
		switch_to_weapon_slot(weapon_slot)
	_pickup_ammo(weapon_slot, ammo)
	
func _pickup_ammo(weapon_slot, ammo: int):
	weapons[weapon_slot].ammo += ammo	
	emit_ammo_changed_signal()

func emit_ammo_changed_signal():
	emit_signal("ammo_changed", current_weapon.ammo)
