extends CanvasLayer

#var path := "C:/Users/franc/Documents/delete/git-back"
var path := "."

var branch_buttons = []
var commit_buttons = []
var commit_logs = []

@onready var btnOpen = $Panel/open
@onready var btnScan = $Panel/scan
@onready var txtOutput = $Panel/output


func _ready():
	#scan_history()
	#get_commits()
	#get_logs()
	btnOpen.pressed.connect(func(): open_repository())
## end _ready()


func _process(delta):
	pass
## end _process()


func open_repository():
	## find a way to search for folder
			## tk.askfiledialog --> write to file in "user://repo_path.txt" then read from there
	var results := []
	var path_dialog = OS.execute("powershell.exe", ["python open_repository.py"], results)
	if results[0] == "not a repository\r\n":
		path = "."
	else:
		path = results[0]
	scan_history()
## end open_repository()


func scan_history():
	clear_branches()
	clear_commits()
	txtOutput.text = ""
	get_branches()
	get_commits()
## end scan_history()


func get_branches():
	var results := []
	var get_branches := OS.execute("powershell.exe", ["cd " + path + "; git branch -a"], results)
	var branches = results[0].split("\n")
	branches.remove_at(len(branches)-1)
	var i : int = 0
	for b in branches:
		b = b.lstrip(" ")
		var btnBranch = Button.new()
		btnBranch.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		if b[0] == "*":
			btnBranch.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
			b = b.lstrip(" *")
		btnBranch.text = str(b)
		btnBranch.pressed.connect(func(): switch_branch(b, btnBranch))
		btnBranch.size = Vector2(200, 45)
		btnBranch.position = Vector2(16, 90 + i)
		i += 55
		branch_buttons.append(btnBranch)
	for bb in branch_buttons:
		if bb != null:
			add_child(bb)
## end get_branches()


func clear_branches():
	for bb in branch_buttons:
		if bb != null:
			bb.queue_free()
## end clear_branches()


func get_commits():
	var results := []
	##var get_hashes := OS.execute("powershell.exe", ["git log --pretty=format:%h"], results)
	var get_hashes := OS.execute("powershell.exe", ["cd " + path + "; git log --oneline"], results)
	var hashes = results[0].split("\n")
	hashes.remove_at(len(hashes)-1)
	var i : int = 0
	for h in hashes:
		var btnHash := Button.new()
		btnHash.text_overrun_behavior =TextServer.OVERRUN_TRIM_ELLIPSIS
		btnHash.text = str(h)
		var id = h.split(" ")[0]
		btnHash.pressed.connect(func(): get_logs(id, btnHash))
		btnHash.size = Vector2(200, 45)
		btnHash.position = Vector2(232, 90 + i)
		i += 55
		commit_buttons.append(btnHash)
	for cb in commit_buttons:
		if cb != null:
			add_child(cb)
## end get_commits()


func clear_commits():
	for cb in commit_buttons:
		if cb != null:
			cb.queue_free()
## end clear_commits()


func get_logs(hash, button):
	for cb in commit_buttons:
		if cb != null:
			cb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	txtOutput.text = ""
	var results := []
	var commits := OS.execute("powershell.exe", ["cd " + path + "; git log " + hash], results)
	var logs = results[0].split("commit")
	for l in logs:
		l = l.lstrip(" ")
		txtOutput.text += l + "\n"
		commit_logs.append(l)
## end get_logs()

func switch_branch(branch_name, button):
	for bb in branch_buttons:
		if bb != null:
			bb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	var results := []
	var current_branch := OS.execute("powershell.exe", ["cd " + path + "; git checkout " + branch_name], results)
	clear_commits()
	txtOutput.text = ""
	get_commits()
## end switch_branch()





















###################################  WHITE SPACE FOR SCROLLING  #########################################
