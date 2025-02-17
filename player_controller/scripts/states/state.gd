## Virtual base class State for all player states
class_name State extends Node

var animation_player: AnimationPlayer
var player: Player
var horizontal_velocity: Vector2

## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: String, data: Dictionary)

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	pass

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	pass

## get current speed, including the effects of friction
func _calculate_current_speed(move_dir: Vector3, friction: float) -> float:
	return move_toward(abs(horizontal_velocity.length()), abs(move_dir.x * player.RUNNING_SPEED), friction * horizontal_velocity.length())

# handling movement for all states
# a bit janky
func handle_movement(delta: float, friction: float = player.FRICTION) -> void:
	horizontal_velocity = Vector2(player.velocity.x, player.velocity.z)
	print("speed:", horizontal_velocity.length())
	var input_dir := Input.get_vector(player.INPUT_LEFT, player.INPUT_RIGHT, player.INPUT_FORWARD, player.INPUT_BACKWARD)
	var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# player.velocity.x += move_dir.x * player.MOVE_ACCELERATION 
	# player.velocity.z += move_dir.z * player.MOVE_ACCELERATION 

	if move_dir:
		if move_dir.x != 0:
			player.velocity.x = move_dir.x * max(player.RUNNING_SPEED, _calculate_current_speed(move_dir, friction))
		if move_dir.z != 0:
			player.velocity.z = move_dir.z * max(player.RUNNING_SPEED, _calculate_current_speed(move_dir, friction))
	# If player is *moving* in the air and lets go of movement keys,
	# continue moving until they hit the floor instead of stopping abruptly
	elif player.is_on_floor():
		player.velocity.x = 0
		player.velocity.z = 0

	player.move_and_slide()
	
## handling signal 'finished' emission for running and idle 
func handle_grounded_states_signal_emission() -> void: 
	if not player.is_on_floor():
		finished.emit("FallingState")
	elif Input.is_action_just_pressed(player.INPUT_JUMP):
		finished.emit("JumpingState")
