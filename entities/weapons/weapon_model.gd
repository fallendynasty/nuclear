class_name WeaponModel extends RigidBody3D

@export var weapon_resource: WeaponResource
@export var label: Label3D
@export var collision_shape: CollisionShape3D
@export var player: Player

var is_equipped: bool = false

var weapon_name: StringName
var damage_per_shot: float

signal dropped(force: Vector3)
signal picked_up
signal attacked
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
	damage_per_shot = weapon_resource.damage_per_shot
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

func _on_attack() -> void:
	pass

func _on_reload() -> void:
	pass
