extends CharacterBody3D


@onready var front_label = $front_label
@onready var rear_label = $rear_label

var branch_name = "Branch Name"
var label_color =  Color(0.29, 0.16, 0.07, 1.0)



func show_name():
	front_label.text = branch_name
	rear_label.text = branch_name
	front_label.modulate = label_color
	rear_label.modulate = label_color
## end set_name()




















###########################  WHITE SPACE FOR SCROLLING  ######################
