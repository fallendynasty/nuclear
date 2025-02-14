extends Resource
class_name Item  # Now you can create Item resources

@export var name: String
@export var icon: Texture3D
@export var item_type: String  # "Weapon", "Armor", etc.
@export var damage: int = 0
@export var defense: int = 0
