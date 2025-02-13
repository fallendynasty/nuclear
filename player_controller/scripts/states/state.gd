## Virtual base class State for all player states
class_name State extends Node

var player: Player

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

# handling movement for all states
# a bit janky
func handle_movement() -> void:
	var input_dir := Input.get_vector(player.INPUT_LEFT, player.INPUT_RIGHT, player.INPUT_FORWARD, player.INPUT_BACKWARD)
	var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.velocity.x += move_dir.x * player.MOVE_ACCELERATION 
	player.velocity.z += move_dir.z * player.MOVE_ACCELERATION 
	
	#cap the max speed and slow down if the directional movement is not being pressed
	if abs(player.velocity.x) > player.MAX_SPEED or move_dir.x == 0:
		player.velocity.x = move_toward(player.velocity.x, 0, player.FRICTION)
	if abs(player.velocity.z) > player.MAX_SPEED or move_dir.z == 0:
		player.velocity.z = move_toward(player.velocity.z, 0, player.FRICTION)
		
	player.move_and_slide()
	#print(player.velocity.x, '       ', player.velocity.z, '      ', player.velocity.length())
	#print(move_dir, 'move_dir')
	
# handling signal 'finished' emission for running and idle 
func handle_GroundedStates_signal_emission() -> void: 
	if not player.is_on_floor():
		finished.emit("FallingState")
	elif Input.is_action_just_pressed(player.INPUT_JUMP):
		finished.emit("JumpingState")
