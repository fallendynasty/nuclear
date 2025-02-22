class_name WeaponModel extends Node3D

@export var weapon_resource: WeaponResource
var damage_per_shot: float

var _label: Label3D

func _ready() -> void:
	assert(weapon_resource != null, "weapon_resource is null. Preload the resource instead")
	#reset_position_rotation()
	damage_per_shot = weapon_resource.damage_per_shot

func reset_position_rotation() -> void:
	position = weapon_resource.position
	rotation = weapon_resource.rotation

func add_label(text: String) -> void:
	if _label != null:
		return
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.text = text
	label.position.y = 0.5
	add_child(label)
	_label = label

func free_label() -> void:
	if _label != null:
		_label.queue_free()
