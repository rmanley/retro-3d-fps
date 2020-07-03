extends Area

class_name Pickup

enum PickupType { 
	MACHINE_GUN, MACHINE_GUN_AMMO, 
	SHOTGUN, SHOTGUN_AMMO, 
	ROCKET_LAUNCHER, ROCKET_LAUNCHER_AMMO,
	HEALTH
}

static func pickup_name(pickup_type) -> String:
	match pickup_type:
		PickupType.MACHINE_GUN:
			return 'Machine Gun'
		PickupType.MACHINE_GUN_AMMO:
			return 'Machine Gun Ammo'
		PickupType.SHOTGUN:
			return 'Shotgun'
		PickupType.SHOTGUN_AMMO:
			return 'Shotgun Shells'
		PickupType.ROCKET_LAUNCHER:
			return 'Rocket Launcher'
		PickupType.ROCKET_LAUNCHER_AMMO:
			return 'Rockets'
		PickupType.HEALTH:
			return 'Health Pack'
		_:
			return 'Unknown'
			
static func is_weapon(pickup_type) -> bool:
	match pickup_type:
		PickupType.MACHINE_GUN:
			return true
		PickupType.SHOTGUN:
			return true
		PickupType.ROCKET_LAUNCHER:
			return true
		_:
			return false

export(PickupType) var pickup_type
export var amount = 10
