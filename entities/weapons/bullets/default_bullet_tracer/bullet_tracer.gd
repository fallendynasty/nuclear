extends Node3D

@export var target_position: Vector3
## speed in m/s
@export var speed: float = 200.0
@export var tracer_length: float = 1.0
const MAX_LIFETIME_MS: float = 1000
@onready var spawn_time: float = Time.get_ticks_msec()

func _process(delta: float) -> void:
	var diff: Vector3 = target_position - global_position
	var add = diff.normalized() * speed * delta
	add = add.limit_length(diff.length())
	global_position += add
	if (target_position - global_position).length() <= tracer_length or Time.get_ticks_msec() - spawn_time >= MAX_LIFETIME_MS:
		queue_free()
