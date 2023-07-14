extends CanvasLayer

var path := "C:/Users/franc/Documents/delete/git-back"
@onready var output = $Panel/output


func _ready():
	var results := []
	var commits := OS.execute("powershell.exe", ["dir"], results)
	for r in results:
		output.text += r + "\n"


func _process(delta):
	pass
