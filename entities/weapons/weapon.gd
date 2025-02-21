## Weapon base class for melee weapons / guns
class_name Weapon extends Node

## amount of ammo currently in the gun. Defaults to `-1` for infinity
var _ammo_count: int
## amount of ammo in each cartridge (number of bullets fired before reload). Defaults to `-1` for infinity
var _ammo_per_cartridge: int
## amount of damage the weapon deals
var _damage: float

func _init(ammo_count: int = -1, ammo_per_cartridge: int = -1, damage: float = 0) -> void:
	_ammo_count = ammo_count
	_ammo_per_cartridge = ammo_per_cartridge
	_damage = damage

## amount of ammo currently in the gun. Defaults to `-1` for infinity
func get_ammo_count() -> int:
	return _ammo_count

## amount of ammo in each cartridge (number of bullets fired before reload). Defaults to `-1` for infinity
func get_ammo_per_cartridge() -> int:
	return _ammo_per_cartridge

func get_damage() -> float:
	return _damage

## shoots the gun / hits with melee weapon
func attack() -> void:
	pass

## reload the gun
func reload() -> void:
	pass
