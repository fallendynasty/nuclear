class_name WeaponResource extends Resource

# TODO weapon types, e.g. shotgun, sniper, melee, etc.

@export var name: StringName

@export_category("Weapon Orientation")
@export var position: Vector3
@export var rotation: Vector3

#@export_category("Visual Settings")
#@export var model: PackedScene
 #@export var mesh: Mesh

@export_category("Weapon Stats")
@export var damage_per_shot: float
@export var ammo_per_magazine: int
@export var magazine_count: int
## time in milliseconds before player can shoot again
@export var gunshot_duration: float
@export var is_automatic: bool
