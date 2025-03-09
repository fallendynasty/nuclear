class_name DummyTarget extends StaticBody3D

@export var label: Label3D
@export var health: float = 100.0

func _ready() -> void:
	label.text = str(health) + "HP"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

func take_damage(damage: float) -> void:
	health -= damage
	if health < 0:
		health = 0
	label.text = str(health) + " HP"
