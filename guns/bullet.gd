extends Node3D

const speed = 40.0
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var is_hit = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray.is_colliding():
		is_hit = true
		
	if not is_hit:
		position += transform.basis * Vector3(0, 0, -speed) * delta #property of node3d/bullet, child nodes inherit this property
		
	else:
		# Reduce scale over time
		mesh.scale -= Vector3(0, 0, 5) * delta  # Adjust speed as needed, rn it disappears after 0.1s
		#remove when tiny
		if mesh.scale.length() < 1.5: # just the length formula
			get_parent().remove_child(self)
			self.queue_free() # remove the bullet node when it's nearly gone
			

			

		


	

	
