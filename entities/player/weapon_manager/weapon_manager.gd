class_name WeaponManager extends Node

@export var player: Player
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

func attack() -> void:
	var camera := player.CAMERA_CONTROLLER
	var space_state := camera.get_world_3d().direct_space_state
	var screen_center: Vector2 = get_viewport().size / 2
	var ray_origin_pos: Vector3 = camera.project_ray_origin(screen_center)
	var ray_end_pos: Vector3 = ray_origin_pos + camera.project_ray_normal(screen_center) * 1000
	var query := PhysicsRayQueryParameters3D.create(ray_origin_pos, ray_end_pos)
	query.collide_with_bodies = true
	var collision: Dictionary = space_state.intersect_ray(query)
	
	if collision.is_empty():
		print("Nothing hit")
		return
	
	var collider: Node3D = collision.get("collider")
	if collider == null or not collider is Node3D:
		prints("Collider", collider, " is null or is not a Node3D")
		return
	var position: Vector3 = collision.get("position")
	if position == null or not position is Vector3:
		prints("Position", position, " is null or is not a Vector3")
		return
	
	# TODO this is just a placeholder
	if collider.has_method("take_damage"):
		print("collider.take_damage() exists")
		collider.take_damage(current_weapon.damage_per_shot)
	else:
		print("collider.take_damage() does not exist")
	print("Hit object", collider, " at position", position)

func _ready() -> void:
	assert(weapon_container != null, "weapon_container should not be null")
	update_weapon_model()

func _unhandled_input(event: InputEvent) -> void:
	if not current_weapon:
		printerr("no weapon equipped")
		return
	
	if Input.is_action_pressed("shoot"):
		attack()

func _process(delta: float) -> void:
	pass
