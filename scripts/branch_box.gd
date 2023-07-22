extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var front_label = $front_label
@onready var rear_label = $rear_label

var branch_name = "Branch Name"



func _ready():
	show_name()
## end _ready()



func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
## end _physics_process()



func show_name():
	front_label.text = branch_name
	rear_label.text = branch_name
## end set_name()



















###########################  WHITE SPACE FOR SCROLLING  ######################
