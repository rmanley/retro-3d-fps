extends Area

class_name Pickup

enum PickupType { 
	MACHINE_GUN, MACHINE_GUN_AMMO, 
	SHOTGUN, SHOTGUN_AMMO, 
	ROCKET_LAUNCHER, ROCKET_LAUNCHER_AMMO,
	HEALTH
}

export(PickupType) var pickup_type
export var ammount = 10
