class_name Player extends CharacterBody3D

@export_group("Character Stats")
@export var MOVE_ACCELERATION : float = 50.0
@export var RUNNING_SPEED : float = 10.0
@export var SLIDE_SPEED : float = 14.0
@export var FRICTION : float = 8.0 # 0.5s to go from max speed to 0
@export var JUMP_VELOCITY : float = 7.5
@export var WALL_JUMP_VELOCITY : float = 6.5
@export var MOUSE_SENSITIVITY : float = 0.2
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER: Camera3D

@export_group("Input Actions")
@export var INPUT_LEFT : String = "left"
@export var INPUT_RIGHT : String = "right"
@export var INPUT_FORWARD : String = "forward"
@export var INPUT_BACKWARD : String = "backwards"
@export var INPUT_JUMP: String = "jump"
@export var INPUT_SPRINT : String = "sprint"
@export var INPUT_SLIDE : String = "slide"
@export var INPUT_DEBUG_RESET_POSITION: String = "debug_reset_position"

@export_group("GUI_controls")
@export var inventory: Inventory

#instantiate environment variables
var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Environmental Stats")
@export var GRAVITY = 9.81

# Healthbar and gun stuff
@onready var healthbar = $CameraController/Camera3D/HealthBar
@onready var gun_barrel_raycast: RayCast3D = $CameraController/Camera3D/Gun/RayCast3D
var health = 100
var bullet = load("res://guns/bullet.tscn")
var bullet_instance

var starting_coordinates: Vector3

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
						
func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	elif Input.is_action_just_pressed(INPUT_DEBUG_RESET_POSITION):
		# reset player position
		position = starting_coordinates

func _ready():
	starting_coordinates = position
	add_to_group("player") # for spikes to detect the player
	if CAMERA_CONTROLLER == null:
		CAMERA_CONTROLLER = $CameraController/Camera3D
	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if Input.is_action_pressed("shoot"):
		bullet_instance = bullet.instantiate()
		bullet_instance.position = gun_barrel_raycast.global_position
		bullet_instance.transform.basis = gun_barrel_raycast.global_transform.basis #get new matrix basis based on orientation of barrel
		get_parent().add_child(bullet_instance)  # get_parent() should return the map
		
	# Update camera movement based on mouse movement
	_update_camera(delta)
	
func _update_camera(delta):
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0
	
# function to be called by harmful objects when they want to deal damage
func hurt(damage):
	if damage < health:
		health -= damage
		healthbar.value = health
	else:
		healthbar.value = 0
		print('U R dead')
		velocity = Vector3(0,0,0)
		MOVE_ACCELERATION = 0 # to be replaced by a death() function
