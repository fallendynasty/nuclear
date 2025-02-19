class_name Player extends CharacterBody3D

@export_group("Player Stats")
@export_subgroup("Constants")
@export var ACCELERATION: float = 50.0
@export var FRICTION: float = 8.0
@export var GRAVITY = 9.81
@export var RUNNING_SPEED: float = 10.0
@export var SLIDING_SPEED: float = 14.0
@export var JUMP_VELOCITY: float = 7.5
@export var WALL_JUMP_VELOCITY: float = 6.5
@export_subgroup("Variable")
@export var health = 100

var bullet: Resource = load("res://entities/weapons/prototype_gun/bullet.tscn")
var bullet_instance: Node3D

@export_group("Player Misc")
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var MOUSE_SENSITIVITY: float = 0.2

# Set these references in the scene editor so that if the nodes are moved around, the value is automatically changed
@export_group("Object References")
@export var inventory: Inventory
@export var CAMERA_CONTROLLER: Camera3D
@export var healthbar: ProgressBar  # $CameraController/Camera3D/HealthBar

@onready var gun_barrel_raycast: RayCast3D = $CameraController/Camera3D/Gun/RayCast3D

@export_group("Player Inputs")
@export var INPUT_LEFT: String = "left"
@export var INPUT_RIGHT: String = "right"
@export var INPUT_FORWARD: String = "forward"
@export var INPUT_BACKWARD: String = "backwards"
@export var INPUT_JUMP: String = "jump"
@export var INPUT_SPRINT: String = "sprint"
@export var INPUT_SLIDE: String = "slide"
@export var INPUT_DEBUG_RESET_POSITION: String = "debug_reset_position"

# for debugging
@onready var STARTING_POSITION: Vector3 = position

# handle camera rotation
var _mouse_input: bool = false
var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
						
func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	elif Input.is_action_just_pressed(INPUT_DEBUG_RESET_POSITION):
		_debug_reset_position()

func _ready():
	add_to_group("player") # for spikes to detect the player
	# if CAMERA_CONTROLLER == null:
	# 	CAMERA_CONTROLLER = $CameraController/Camera3D
	assert(CAMERA_CONTROLLER != null, "[Player] Please set `CAMERA_CONTROLLER` in the editor")
	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if Input.is_action_pressed("shoot"):
		bullet_instance = bullet.instantiate()
		bullet_instance.position = gun_barrel_raycast.global_position
		bullet_instance.transform.basis = gun_barrel_raycast.global_transform.basis # get new matrix basis based on orientation of barrel
		get_parent().add_child(bullet_instance) # get_parent() should return the map
		
	# Update camera movement based on mouse movement
	_update_camera(delta)
	
func _update_camera(delta):
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

func _debug_reset_position():
	position = STARTING_POSITION

## returns the player's horizontal velocity in the form of `Vector2(x, z)`
func get_horizontal_velocity() -> Vector2:
	return Vector2(velocity.x, velocity.z)

## get new speed, including the effects of friction and acceleration and preserving momentum
## TODO improve. current_speed * acceleration makes NO sense idk why this works
func _calculate_new_speed(delta: float, move_dir: float, friction: float) -> float:
	# if current speed < player running speed, accelerate to running speed
	var current_speed := get_horizontal_velocity().length()
	if current_speed <= RUNNING_SPEED:
		return move_dir * move_toward(current_speed, RUNNING_SPEED, ACCELERATION * delta)

	# however, if current speed > player running speed, e.g. from force from explosion, slide jumping, etc,
	if not is_on_floor():
		# decelerate down to runnning speed if on ground
		return move_dir * move_toward(current_speed, RUNNING_SPEED, friction * current_speed * delta)
	else:
		# keep momentum
		return move_dir * current_speed * ACCELERATION * delta

# handling movement for all STATES
# a bit janky
# TODO improve. Why move_toward a move_toward? Why does this even work
func handle_movement(delta: float, friction: float = FRICTION) -> void:
	print("speed:", get_horizontal_velocity().length())
	var input_dir := Input.get_vector(INPUT_LEFT, INPUT_RIGHT, INPUT_FORWARD, INPUT_BACKWARD)
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# velocity.x += move_dir.x * ACCELERATION 
	# velocity.z += move_dir.z * ACCELERATION 

	if move_dir:
		if move_dir.x != 0:
			velocity.x = move_toward(velocity.x, _calculate_new_speed(delta, move_dir.x, friction), ACCELERATION * delta)
		if move_dir.z != 0:
			velocity.z = move_toward(velocity.z, _calculate_new_speed(delta, move_dir.z, friction), ACCELERATION * delta)
	# If player is *moving* in the air and lets go of movement keys,
	# continue moving until they hit the floor instead of stopping abruptly
	elif is_on_floor():
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

## function to be called by harmful objects when they want to deal damage
func hurt(damage):
	if damage < health:
		health -= damage
		healthbar.value = health
	else:
		healthbar.value = 0
		print('U R dead')
		velocity = Vector3(0, 0, 0)
		_debug_reset_position() # TODO to be replaced by a death() function
