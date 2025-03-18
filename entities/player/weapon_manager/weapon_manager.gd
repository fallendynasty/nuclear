class_name WeaponManager extends Node

@export var player: Player
@export var weapon_container: Node3D
@export var bullet_raycast: RayCast3D
@export var THROW_FORCE: float = 10.0
#@export var starting_weapon: WeaponResource
var weapon_models: Array[WeaponModel] = [null, null]
var current_weapon_idx: int = 0
var empty_slot_idx: int = 0

signal dropped(weapon: WeaponModel)
signal picked_up(weapon: WeaponModel)
signal attacked(weapon: WeaponModel)
signal reloaded(weapon: WeaponModel)
signal swapped(weapon: WeaponModel)

func get_current_weapon_model() -> WeaponModel:
	# range check
	if current_weapon_idx >= weapon_models.size() or current_weapon_idx < 0:
		return
	return weapon_models[current_weapon_idx]

func _ready() -> void:
	var starting_weapons: Array = weapon_container.get_children().filter(func(node): return node is WeaponModel)
	print("starting weapons: ", starting_weapons)
	if starting_weapons.is_empty():
		return

	var i := 0
	while i < weapon_models.size() and i < starting_weapons.size():
		#weapon_models[i] = starting_weapons[i]
		pickup(starting_weapons[i])
		i += 1
	dropped.connect(player.hud_ui.update_ammo_label)
	picked_up.connect(player.hud_ui.update_ammo_label)
	attacked.connect(player.hud_ui.update_ammo_label)
	reloaded.connect(player.hud_ui.update_ammo_label)
	swapped.connect(player.hud_ui.update_ammo_label)
	swap_to(0)

func attack() -> void:
	var weapon := get_current_weapon_model()
	if weapon == null:
		return

	var screen_center: Vector2 = player.get_viewport().size / 2
	var origin: Vector3 = player.CAMERA_CONTROLLER.project_ray_origin(screen_center)
	var look_direction: Vector3 = player.CAMERA_CONTROLLER.project_ray_normal(screen_center)
	weapon._on_attack(origin, look_direction)
	attacked.emit(weapon)
	# # TODO change based on weapon type, e.g. shotgun, sniper, melee, etc.
	# var collider: Node3D = bullet_raycast.get_collider()
	# if collider == null:
	# 	return
	# if collider.has_method("take_damage"):
	# 	collider.take_damage(get_current_weapon_model().damage_per_shot)

func reload() -> void:
	var weapon := get_current_weapon_model()
	if weapon == null:
		return
	
	weapon._on_reload()
	await get_tree().create_timer(weapon.reload_duration_ms / 1000.0).timeout
	reloaded.emit(get_current_weapon_model())

## drop current weapon
func drop() -> void:
	if current_weapon_idx >= weapon_models.size() or current_weapon_idx < 0:
		return
	if is_weapon_slots_full():
		empty_slot_idx = current_weapon_idx
	var weapon := get_current_weapon_model()
	# not holding a weapon
	if weapon == null:
		return
	# drop current weapon
	weapon.reparent(player.get_parent())
	weapon._on_drop(-player.basis.z * THROW_FORCE + player.velocity)
	weapon_models[current_weapon_idx] = null
	empty_slot_idx = find_new_empty_slot()
	dropped.emit(null)

func is_weapon_slots_full() -> bool:
	return empty_slot_idx >= weapon_models.size() or empty_slot_idx < 0

## pickup new weapon
func pickup(new_weapon: WeaponModel) -> int:
	if is_weapon_slots_full():
		print("weapon slots full")
		return -1
	# remove weapon_model from world
	var new_weapon_parent := new_weapon.get_parent()
	if new_weapon_parent != null:
		new_weapon.get_parent().remove_child(new_weapon)
	new_weapon._on_pickup()
	weapon_models[empty_slot_idx] = new_weapon
	var idx = empty_slot_idx
	empty_slot_idx = find_new_empty_slot()
	prints("pickup done: ", weapon_models, current_weapon_idx, empty_slot_idx)
	picked_up.emit(new_weapon)
	return idx

func find_new_empty_slot() -> int:
	return weapon_models.find(null)

## swap to another equipped weapon
func swap_to(idx: int) -> void:
	# check idx in range
	if idx >= weapon_models.size() or idx < 0:
		return
	var current_weapon := get_current_weapon_model()
	if current_weapon != null and weapon_container.is_ancestor_of(current_weapon):
		print("swap_to(): remove child ", current_weapon)
		weapon_container.remove_child(current_weapon)
	current_weapon_idx = idx
	current_weapon = get_current_weapon_model()
	if current_weapon != null:
		weapon_container.add_child(get_current_weapon_model())
	else:
		empty_slot_idx = idx
	swapped.emit(current_weapon)

## transition from hip fire to aim down sights
func ads_in() -> void:
	var current_weapon := get_current_weapon_model()
	if current_weapon == null:
		return
	current_weapon._on_ads_in()

## transition from aim down sights to hip fire
func ads_out() -> void:
	var current_weapon := get_current_weapon_model()
	if current_weapon == null:
		return
	current_weapon._on_ads_out()

var __prev_weapon_found: WeaponModel = null

func scan_for_new_weapons() -> void:
	if not player.equip_item_range_raycast.is_colliding():
		# update label when out of pickup range
		if __prev_weapon_found != null:
			__prev_weapon_found.label.text = ""
			__prev_weapon_found = null
		print("not colliding")
		return

	var collider: Node3D = player.equip_item_range_raycast.get_collider()
	print("Collider: ", collider)
	if collider == null or not collider is WeaponModel:
		# update label when out of pickup range
		if __prev_weapon_found != null:
			__prev_weapon_found.label.text = ""
			__prev_weapon_found = null
		return

	var new_weapon_model: WeaponModel = collider
	__prev_weapon_found = collider

	new_weapon_model.label.text = "[%s] Equip %s" % [str(InputMap.action_get_events(player.INPUT_INTERACT)[0].as_text()), new_weapon_model.weapon_name]
	if Input.is_action_just_pressed(player.INPUT_INTERACT):
		var idx = pickup(new_weapon_model)
		if idx != -1:
			swap_to(idx)
		else:
			print("unable to equip ", new_weapon_model, " (weapon slots full)")

func _process_attack_input() -> void:
	var current_weapon: WeaponModel = get_current_weapon_model()
	if current_weapon == null:
		return

	# add delay between each shot/attack	
	if not get_current_weapon_model().gun_attack_timer.is_stopped():
		return

	# handle attacking
	if get_current_weapon_model().is_automatic:
		if Input.is_action_pressed(player.INPUT_ATTACK):
			attack()
	else:
		if Input.is_action_just_pressed(player.INPUT_ATTACK):
			attack()

func _process_ads_input() -> void:
	var current_weapon = get_current_weapon_model()
	if current_weapon == null:
		return

	if current_weapon.weapon_resource.is_ads_toggle_on:
		if Input.is_action_just_pressed(player.INPUT_ADS):
			current_weapon.toggle_ads()
	else:
		if Input.is_action_just_pressed(player.INPUT_ADS) or Input.is_action_just_released(player.INPUT_ADS):
			current_weapon.toggle_ads()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(player.INPUT_RELOAD):
		reload()
	scan_for_new_weapons()
	if Input.is_action_just_pressed("drop_item"):
		drop()
	elif Input.is_action_just_pressed("weapon_1"):
		swap_to(0)
	elif Input.is_action_just_pressed("weapon_2"):
		swap_to(1)
	prints(weapon_models, current_weapon_idx, empty_slot_idx)

func _process(delta: float) -> void:
	_process_attack_input()
	_process_ads_input()
