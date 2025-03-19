@tool
class_name WeaponModel extends RigidBody3D

@export var weapon_resource: WeaponResource :
	set(value):
		# disconnect the previous resource signals
		if weapon_resource != null:
			weapon_resource.changed.disconnect(_load_weapon_resource)
		# connect the new resource signals
		weapon_resource = value
		if weapon_resource != null:  # added a new weapon resource
			weapon_resource.changed.connect(_load_weapon_resource)
			_load_weapon_resource()
		else:  # deleted the weapon resource
			if _weapon_instance != null:
				remove_child(_weapon_instance)
				_weapon_instance.queue_free()
@export var label: Label3D
@export var collision_shape: CollisionShape3D
@export var player: Player

var _weapon_instance: Node = null

var is_equipped: bool = false
var is_ads_in: bool = false

var weapon_name: StringName
var damage_per_bullet: float

## the amount of ammo in the current magazine
var ammo_count: int
## the amount of ammo in each magazine
var ammo_per_magazine: int
## the amount of ammo unused (excluding the ammo in the current magazine)
var ammo_remaining: int

## variables relating to attacking and reloading and their timers
var gun_attack_timer: Timer
var gunshot_duration_ms: float
var is_automatic: bool
var reload_duration_ms: float

func _load_weapon_resource():
	print("_load_weapon_resource() called")
	weapon_name = weapon_resource.name
	collision_shape.position = weapon_resource.collision_position
	collision_shape.rotation = weapon_resource.collision_rotation
	collision_shape.shape.size = weapon_resource.collision_size
	damage_per_bullet = weapon_resource.damage_per_shot

	ammo_per_magazine = weapon_resource.ammo_per_magazine
	ammo_count = ammo_per_magazine
	ammo_remaining = (ammo_per_magazine * weapon_resource.magazine_count) - ammo_count
	
	gunshot_duration_ms = weapon_resource.gunshot_duration_ms
	print(gunshot_duration_ms, weapon_resource.gunshot_duration_ms, weapon_name)
	is_automatic = weapon_resource.is_automatic
	reload_duration_ms = weapon_resource.reload_duration_ms

	label.position = collision_shape.position
	label.position.y += 0.1 + collision_shape.shape.size.y / 2

	# delete existing weapon instance on resource update
	if Engine.is_editor_hint() and _weapon_instance != null:
		# note: `node.name` not to be confused with `weapon_resource.weapon_name`
		remove_child(_weapon_instance)
		_weapon_instance.queue_free()
	# add the new weapon instance from the updated resource
	_weapon_instance = weapon_resource.model.instantiate()

	add_child(_weapon_instance)
	print("added _weapon_instance ", _weapon_instance.name)

	# allow changing of position relative to player if the weapon is
	# attached to the player('s WeaponContainer)
	if Engine.is_editor_hint() and player and player.is_ancestor_of(self):
		if weapon_resource._tool_show_ads_translation:
			_tool_show_ads_translation()
		else:
			reset_translation()

func _ready() -> void:
	assert(weapon_resource != null, "weapon_resource is null. Preload the resource instead")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

	contact_monitor = true
	max_contacts_reported = 1

	_load_weapon_resource()
	add_collision_exception_with(player)
	body_entered.connect(_on_collision)

func _tool_show_ads_translation() -> void:
	position = weapon_resource.ads_position
	rotation = weapon_resource.ads_rotation

func reset_translation() -> void:
	position = weapon_resource.position
	rotation = weapon_resource.rotation

func _on_pickup() -> void:
	is_equipped = true
	reset_translation()
	label.text = ""
	set_freeze_enabled(true)
	
	gun_attack_timer = Timer.new()  # Create a new Timer instance
	print(gunshot_duration_ms)
	gun_attack_timer.wait_time = gunshot_duration_ms/1000  # Set the delay
	gun_attack_timer.one_shot = true # runs once every time it's started and stops
	gun_attack_timer.autostart = true # initial gun delay
	add_child(gun_attack_timer)  # Attach it to the gun node
	
func _on_drop(force: Vector3) -> void:
	is_equipped = false
	set_freeze_enabled(false)
	add_constant_central_force(force)

func _on_collision(body: Node3D) -> void:
	print("Weapon %s collided with body %s" % [self, body])
	constant_force = Vector3.ZERO

func _on_attack(origin: Vector3, look_direction: Vector3, hitscan_distance: float = 1000) -> void:
	# check if enough ammo
	gun_attack_timer.start()
	if ammo_count <= 0:
		print("[WeaponModel %s] I NEED MORE BOOLETS" % self.weapon_name)
		return

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
	# decrement ammo
	ammo_count -= 1
	if ammo_count == 0:
		_on_reload()

func _on_reload() -> void:
	# start:  50 // 100 	(50, 50, 50)
	# shoot:  45 // 100
	# reload: 50 // 95  	diff = 50 - 45 = 5
	# ...
	# shoot:  00 // 95
	# reload: 50 // 45  	diff = 50 - 0  = 50
	# ...
	# shoot:  10 // 45
	# reload: 50 // 05  	diff = 50 - 10 = 40
	# shoot:  49 // 05
	# reload: 50 // 04  	diff = 50 - 49 = 1
	# ...
	# shoot:  00 // 04
	# reload: 04 // 00  	diff = 50 - 0  = 50
	var diff := ammo_per_magazine - ammo_count
	if diff > ammo_remaining:
		diff = ammo_remaining
	ammo_count += diff
	ammo_remaining -= diff
	# TODO ...
