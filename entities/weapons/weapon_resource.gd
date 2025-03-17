class_name WeaponResource extends Resource

# TODO 
# - weapon types, e.g. shotgun, sniper, melee, etc.
# - ammo types (?)
# - misc stuff e.g. mass

@export var name: StringName

@export_category("Weapon Orientation")
@export var position: Vector3
@export var rotation: Vector3

@export_category("Weapon Collision")
@export var collision_size: Vector3
@export var collision_position: Vector3
@export var collision_rotation: Vector3

#@export_category("Visual Settings")
@export var model: PackedScene
 #@export var mesh: Mesh

@export_category("Weapon Stats")
@export var damage_per_shot: float
@export var ammo_per_magazine: int
@export var magazine_count: int
## time in milliseconds before player can shoot again
@export var gunshot_duration_ms: float = 100
@export var is_automatic: bool
@export var reload_duration_ms: float

@export_category("Weapon Behaviour")
@export var bullets_per_shot: int = 1
@export var spread: float = 0.0
