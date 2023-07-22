extends CanvasLayer

@onready var btnStart2d = $Panel/start_2d
@onready var btnStart3d = $Panel/start_3d


func _ready():
	btnStart2d.pressed.connect(func(): start2d())
	btnStart3d.pressed.connect(func(): start3d())
## end _ready()


func start2d():
	get_tree().change_scene_to_file("res://scenes/gui_git.tscn")
## end start2d()



func start3d():
	get_tree().change_scene_to_file("res://scenes/world_git.tscn")
## end start3d()
