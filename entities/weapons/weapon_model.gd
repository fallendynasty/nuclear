class_name WeaponModel extends RigidBody3D

@export var weapon_resource: WeaponResource
@export var label: Label3D
@export var collision_shape: CollisionShape3D
@export var player: Player

var is_equipped: bool = false

var weapon_name: StringName
var damage_per_bullet: float

signal dropped(force: Vector3)
signal picked_up
signal attacked(bullet_raycast: Vector3)
signal reloaded

func _init(p_weapon_resource: WeaponResource = null, p_player: Player = null):
	weapon_resource = p_weapon_resource
	player = p_player

func _ready() -> void:
	assert(weapon_resource != null, "weapon_resource is null. Preload the resource instead")

	weapon_name = weapon_resource.name
	collision_shape.position = weapon_resource.collision_position
	collision_shape.rotation = weapon_resource.collision_rotation
	collision_shape.shape.size = weapon_resource.collision_size
	damage_per_bullet = weapon_resource.damage_per_shot
	# ... TODO more values from resource ...
	# mass = ...
	# ...
	
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = collision_shape.position
	label.position.y += 0.1 + collision_shape.shape.size.y / 2
	add_collision_exception_with(player)
	contact_monitor = true
	max_contacts_reported = 1
	
	var weapon_instance = weapon_resource.model.instantiate()
	add_child(weapon_instance)
	
	dropped.connect(_on_drop)
	picked_up.connect(_on_pickup)
	attacked.connect(_on_attack)
	reloaded.connect(_on_reload)
	body_entered.connect(_on_collision)

func reset_translation() -> void:
	position = weapon_resource.position
	rotation = weapon_resource.rotation

func _on_pickup() -> void:
	is_equipped = true
	reset_translation()
	label.text = ""
	set_freeze_enabled(true)

func _on_drop(force: Vector3) -> void:
	is_equipped = false
	set_freeze_enabled(false)
	add_constant_central_force(force)

func _on_collision(body: Node3D) -> void:
	print("Weapon %s collided with body %s" % [self, body])
	constant_force = Vector3.ZERO

func _on_attack(origin: Vector3, look_direction: Vector3, hitscan_distance: float = 1000) -> void:
	var space_state = get_world_3d().direct_space_state

	for i in range(weapon_resource.bullets_per_shot):
		var rng := RandomNumberGenerator.new()
		var spread_x := rng.randf_range(-weapon_resource.spread, weapon_resource.spread)
		var spread_y := rng.randf_range(-weapon_resource.spread, weapon_resource.spread)
		var x_added := hitscan_distance * tan(deg_to_rad(spread_x))
		var y_added := hitscan_distance * tan(deg_to_rad(spread_y))

		var vec_added := Vector3(x_added, y_added, 0)
		var bullet_displacement: Vector3 = look_direction.normalized() * hitscan_distance + vec_added
		var end := origin + bullet_displacement

		# check collision
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var result: Dictionary = space_state.intersect_ray(query)

		# spawn tracer bullet
		var bullet_tracer = preload("res://entities/weapons/bullets/default_bullet_tracer/bullet_tracer.tscn").instantiate()
		get_tree().root.add_child(bullet_tracer)
		bullet_tracer.global_position = global_position

		if result.is_empty():
			bullet_tracer.target_position = end
			bullet_tracer.look_at(bullet_tracer.target_position)
			continue

		var collider: Node3D = result.get("collider")
		var position: Vector3 = result.get("position")
		assert(collider != null and position != null)

		bullet_tracer.target_position = position
		bullet_tracer.look_at(bullet_tracer.target_position)

		if collider.has_method("take_damage"):
			collider.take_damage(damage_per_bullet)
	
	# var initial_rotation := bullet_raycast.rotation

	# # create raycast from origin for each bullet
	# print(weapon_resource.bullets_per_shot)
	# for i in range(weapon_resource.bullets_per_shot):
	# 	bullet_raycast.rotation = get_spread()
	# 	print("bullet_raycast rotation: ", bullet_raycast.rotation)

	# 	var collider := bullet_raycast.get_collider()
	# 	var position := bullet_raycast.get_collision_point()

	# 	print(collider, position)

	# 	# spawn bullet tracers
	# 	var bullet_tracer = preload("res://entities/weapons/bullets/default_bullet_tracer/bullet_tracer.tscn").instantiate()
	# 	get_parent().add_child(bullet_tracer)
	# 	bullet_tracer.global_position = global_position
	# 	if collider == null:
	# 		print("null", bullet_raycast.target_position)
	# 		bullet_tracer.target_position = player.CAMERA_CONTROLLER.project_local_ray_normal(Vector2.ZERO) * 1000
	# 	else:
	# 		print("not null", position)
	# 		bullet_tracer.target_position = position
	# 	bullet_tracer.look_at(bullet_tracer.target_position)

	# 	# TODO if collider is Enemy
	# 	if collider != null and collider.has_method("take_damage"):
	# 		# TODO damage falloff based on distance
	# 		collider.take_damage(damage_per_bullet)
	# bullet_raycast.rotation = initial_rotation	
	
func _on_reload() -> void:
	pass
