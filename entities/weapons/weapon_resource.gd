@tool
class_name WeaponResource extends Resource

# TODO 
# - weapon types, e.g. shotgun, sniper, melee, etc.
# - ammo types (?)
# - misc stuff e.g. mass

@export var name: StringName

@export_category("Weapon Orientation")
@export var position: Vector3:
	set(value):
		position = value
		changed.emit()
@export var rotation: Vector3:
	set(value):
		rotation = value
		changed.emit()

@export_category("Weapon Collision")
@export var collision_size: Vector3 :
	set(value):
		collision_size = value
		changed.emit()
@export var collision_position: Vector3:
	set(value):
		collision_position = value
		changed.emit()
@export var collision_rotation: Vector3:
	set(value):
		collision_rotation = value
		changed.emit()

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
@export var is_ads_enabled: bool = false
@export var ads_zoom_multiplier: float = 1.0
@export var _tool_show_ads_translation: bool = false :
	set(value):
		_tool_show_ads_translation = value
		changed.emit()
@export var ads_position: Vector3 = Vector3.ZERO :
	set(value):
		ads_position = value
		changed.emit()
# TODO add transition speed, lerp in weapon_model, weapon_manager, etc.
# @export var ads_transition_speed: float = 1.0
## `true` - press once to toggle ADS; `false` - hold button to ADS
@export var is_ads_toggle_on: bool = false
