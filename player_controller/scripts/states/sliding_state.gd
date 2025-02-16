class_name SlidingState extends State

@export var slide_duration_frames: int = 20
var _frame_count: int = 0
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
	player.velocity.x = move_toward(player.velocity.x, initial_velocity.x, abs(player.FRICTION * player.velocity.x / 2))
	player.velocity.z = move_toward(player.velocity.z, initial_velocity.z, abs(player.FRICTION * player.velocity.z / 2))

	# super.handle_movement(_delta)
	player.move_and_slide()

	print("sliding speed:", player.velocity.length())
	if Input.is_action_just_pressed(player.INPUT_JUMP):
		finished.emit("JumpingState")

	if _frame_count >= slide_duration_frames:
		# TODO if player is sliding under a platform, continue sliding to prevent softlocking under platform
		# if Input.is_action_just_released(player.INPUT_SLIDE):
		if not Input.is_action_pressed(player.INPUT_SLIDE):
			finished.emit("RunningState")
		# elif Input.is_action_just_pressed(player.INPUT_JUMP):
		# 	finished.emit("JumpingState")
	_frame_count += 1

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	prints("[SlidingState] Sliding State Entered")
	animation_player.play("slide")
	_frame_count = 0

	initial_velocity = player.velocity

	var input_dir := Input.get_vector(player.INPUT_LEFT, player.INPUT_RIGHT, player.INPUT_FORWARD, player.INPUT_BACKWARD)
	var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# if player.velocity.length() < (move_dir * player.SLIDE_SPEED).length():
	# 	player.velocity += move_dir * player.SLIDE_SPEED
	var current_speed := player.velocity.length()
	if current_speed > 0:
		player.velocity += move_dir * move_toward(player.SLIDE_SPEED, 0, 1/(current_speed**2))
	else:
		player.velocity += -player.transform.basis.z * player.SLIDE_SPEED
	prints("[SlidingState] Started slide with speed %s" % Vector2(player.velocity.x, player.velocity.z).length())

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	prints("[SlidingState] Sliding State Exited")
	_frame_count = 0
	animation_player.play_backwards("slide")
