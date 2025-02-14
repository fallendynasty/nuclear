class_name SlidingState extends State

@export var slide_speed: float = 7.0
@export var slide_duration_seconds: float = 1.0
# var slide_vector: Vector3 = Vector3(0, 1)
var initial_velocity: Vector3

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	# await get_tree().create_timer(slide_duration_seconds).timeout
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, initial_velocity.x, player.FRICTION)
	player.velocity.z = move_toward(player.velocity.z, initial_velocity.z, player.FRICTION)

	# super.handle_movement()
	player.move_and_slide()

	# await get_tree().create_timer(slide_duration_seconds).timeout
	if Input.is_action_just_released(player.INPUT_SLIDE):
		finished.emit("RunningState")
	elif Input.is_action_just_pressed(player.INPUT_JUMP):
		finished.emit("JumpingState")

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	prints("[SlidingState] Idle State Entered")
	animation_player.play("slide")
	initial_velocity = player.velocity
	player.velocity += player.velocity.normalized() * slide_speed

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	prints("[SlidingState] Idle State Exited")
	animation_player.play_backwards("slide")
