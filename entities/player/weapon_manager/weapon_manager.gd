class_name WeaponManager extends Node

@export var player: Player
@export var bullet_raycast: RayCast3D
@export var weapon_container: Node3D
@export var current_weapon: WeaponResource

## The root node of the weapon's scene instance
var current_weapon_model: Node3D

## update the current_weapon_model based on the current_weapon
## TODO support multiple weapons
func update_weapon_model() -> void:
	# assert(current_weapon != null, "current_weapon should not be null")
	if current_weapon == null:
		# TODO fist melee weapon or something? or default knife?
		printerr("No weapon equipped")
		return

	assert(current_weapon.model != null, "current_weapon.model should not be null")
	if current_weapon_model != null:
		weapon_container.remove_child(current_weapon_model)
	current_weapon_model = current_weapon.model.instantiate()
	current_weapon_model.position = current_weapon.position
	current_weapon_model.rotation = current_weapon.rotation
	weapon_container.add_child(current_weapon_model)

func _ready() -> void:
	assert(weapon_container != null, "weapon_container should not be null")
	update_weapon_model()

func _process(delta: float) -> void:
	pass
