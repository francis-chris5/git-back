extends CanvasLayer

var path := "C:/Users/franc/Documents/delete/git-back"
@onready var output = $Panel/output


func _ready():
	get_commits()
	#get_logs()
## end _ready()


func _process(delta):
	pass


func get_commits():
	var results := []
	##var get_hashes := OS.execute("powershell.exe", ["git log --pretty=format:%h"], results)
	var get_hashes := OS.execute("powershell.exe", ["git log --oneline"], results)
	var hashes = results[0].split("\n")
	hashes.remove_at(len(hashes)-1)
	var i : int = 0
	for h in hashes:
		var b := Button.new()
		b.text = str(h)
		var id = h.split(" ")[0]
		b.pressed.connect(func(): get_logs(id))
		add_child(b)
		b.custom_minimum_size = Vector2(123, 45)
		b.position = Vector2(32, 90 + i)
		i += 55
## end get_commits()



func get_logs(hash=""):
	output.text = ""
	if hash == "":
		var results := []
		var commits := OS.execute("powershell.exe", ["git log"], results)
		var logs = results[0].split("\n")
		for l in logs:
			output.text += l + "\n"
	else:
		print("git log " + hash)
		var results := []
		var commits := OS.execute("powershell.exe", ["git log " + hash], results)
		var logs = results[0].split("\n")
		for l in logs:
			output.text += l + "\n"
## end get_logs()
























###################################  WHITE SPACE FOR SCROLLING  #########################################
