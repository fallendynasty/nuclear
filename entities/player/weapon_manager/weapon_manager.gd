class_name WeaponManager extends Node

@export var player: Player
@export var weapon_container: Node3D
@export var bullet_raycast: RayCast3D
@export var __starting_weapon: PackedScene
var weapon_models: Array[WeaponModel] = [null, null, null]
var current_weapon_idx: int = -1
var empty_slot_idx: int = 0

func get_current_weapon_model() -> WeaponModel:
	# range check
	if current_weapon_idx >= weapon_models.size() or current_weapon_idx < 0:
		return
	return weapon_models[current_weapon_idx]

func _ready() -> void:
	if __starting_weapon != null:
		var starting_weapon = __starting_weapon.instantiate()
		equip(starting_weapon)
		swap_to(0)

func attack() -> void:
	var collider: Node3D = bullet_raycast.get_collider()
	if collider == null:
		return
	if collider.has_method("take_damage"):
		collider.take_damage(get_current_weapon_model().damage_per_shot)

func reload() -> void:
	# ...
	pass

## drop current weapon
func drop() -> void:
	# ...
	pass

func is_weapon_slots_full() -> bool:
	return empty_slot_idx >= weapon_models.size() or empty_slot_idx < 0

## equip new weapon
func equip(new_weapon: WeaponModel) -> int:
	if is_weapon_slots_full():
		return -1
	new_weapon.reset_position_rotation()
	weapon_models[empty_slot_idx] = new_weapon
	var idx = empty_slot_idx
	empty_slot_idx += 1
	return idx

## swap to another equipped weapon
func swap_to(idx: int) -> void:
	# check idx in range
	if idx >= weapon_models.size() or idx < 0:
		return
	var current_weapon := get_current_weapon_model()
	if current_weapon != null:
		print("remove ", get_current_weapon_model())
		weapon_container.remove_child(get_current_weapon_model())
	current_weapon_idx = idx
	weapon_container.add_child(get_current_weapon_model())

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(player.INPUT_ATTACK):
		attack()
	scan_for_new_weapons()

var __prev_weapon_found: WeaponModel = null

func scan_for_new_weapons() -> void:
	if not player.equip_item_range_raycast.is_colliding():
		if __prev_weapon_found != null:
			__prev_weapon_found.free_label()
			__prev_weapon_found = null
		print("not colliding")
		return
	var collider: Node3D = player.equip_item_range_raycast.get_collider()
	print("Collider: ", collider)
	if collider == null:
		return
	var parent: Node3D = collider.get_parent()
	if parent == null or not (parent is WeaponModel):
		return
	
	var new_weapon_model: WeaponModel = parent
	print("Found weapon: ", new_weapon_model)
	__prev_weapon_found = new_weapon_model
	new_weapon_model.add_label(str(InputMap.action_get_events(player.INPUT_INTERACT)[0].as_text()) + " equip")
	if Input.is_action_just_pressed(player.INPUT_INTERACT):
		new_weapon_model.free_label()
		new_weapon_model.get_parent().remove_child(new_weapon_model)
		new_weapon_model.disable_collision()
		var idx = equip(new_weapon_model)
		swap_to(idx)
