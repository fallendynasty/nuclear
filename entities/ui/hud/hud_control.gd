class_name HeadsUpDisplayControl extends Control

@export var ammo_label: Label
@export var health_bar: ProgressBar

## Update the ammo label
## `current_ammo` is the amount of ammo in the current cartridge
## `remaining_ammo` is the total amount of ammo in the remaining
##  cartidges (excluding the current one)
func update_ammo_label_text(current_ammo: int, remaining_ammo: int):
	ammo_label.text = "%d // %d" % [current_ammo, remaining_ammo]

## Update the ammo label based on the `weapon`
func update_ammo_label(weapon: WeaponModel):
	if weapon == null:
		update_ammo_label_text(-1, -1)
		return
	update_ammo_label_text(weapon.ammo_count, weapon.ammo_remaining)
