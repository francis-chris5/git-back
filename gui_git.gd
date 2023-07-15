extends CanvasLayer

#var path := "C:/Users/franc/Documents/delete/git-back"
var path := "."

var branch_buttons = []
var commit_buttons = []
var commit_logs = []

@onready var btnOpen = $Panel/main_menu/open
@onready var btnClone = $Panel/main_menu/clone


@onready var clone_panel = $Panel/clone_panel
@onready var btnCloneLocation = $Panel/clone_panel/clone_location
@onready var txtCloneURL = $Panel/clone_panel/clone_url


@onready var txtCommit = $Panel/commit_log
@onready var txtStatus = $Panel/status
@onready var txtDiff = $Panel/diff


@onready var commit_container = $Panel/commits/commit_container
@onready var branch_container = $Panel/branches/branch_container




func _ready():
	#scan_history()
	#get_commits()
	#get_logs()
	btnOpen.pressed.connect(func(): open_repository())
	btnClone.pressed.connect(func(): toggle_clone_repository())
	btnCloneLocation.pressed.connect(func(): choose_location())
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


func toggle_clone_repository():
	clone_panel.visible = not clone_panel.visible
## end clone_repository()


func choose_location():
	if txtCloneURL.text == "":
		pass
	else:
		var results := []
		var set_location := OS.execute("powershell.exe", ["python choose_location.py"], results)
		var locale = ""
		if results[0] == "invalid\r\n":
			locale = "C:/"
		else:
			locale = results[0].rstrip("\r\n")
		var clone_repo := OS.execute("powershell.exe", ["cd " + locale + "; git clone " + txtCloneURL.text], results)
		if "fatal" not in results[0]:
			var repo_name = ""
			var repo = txtCloneURL.text.split("/")
			if ".git" in repo[len(repo)-1]:
				repo_name = repo[len(repo)-1].get_slice(".", 0)
			else:
				repo_name = repo[len(repo)-1]
			path = locale + "/" + repo_name
			print(path)
			scan_history()
			txtCloneURL.text = ""
			clone_panel.visible = false
## end choose_location()


func scan_history():
	clear_branches()
	clear_commits()
	txtCommit.text = ""
	txtStatus.text = ""
	txtDiff.text = ""
	get_branches()
	get_commits()
	update_status()
	open_log()
	show_diff()
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
			branch_container.add_child(bb)
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
		btnHash.position = Vector2(5, 5 + i)
		i += 55
		commit_buttons.append(btnHash)
	for cb in commit_buttons:
		if cb != null:
			commit_container.add_child(cb)
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
	txtCommit.text = ""
	var results := []
	var commits := OS.execute("powershell.exe", ["cd " + path + "; git log " + hash], results)
	txtCommit.text = results[0]
	show_diff(hash)
	update_status()
#	var logs = results[0].split("commit")
#	for l in logs:
#		l = l.lstrip(" ")
#		txtCommit.text += l + "\n"
#		commit_logs.append(l)
## end get_logs()


func open_log():
	var results := []
	var current_log = OS.execute("powershell.exe", ["cd " + path + "; git log"], results)
	txtCommit.text = results[0]
## end open_log()

func switch_branch(branch_name, button):
	for bb in branch_buttons:
		if bb != null:
			bb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	var results := []
	var current_branch := OS.execute("powershell.exe", ["cd " + path + "; git checkout " + branch_name], results)
	clear_commits()
	txtCommit.text = ""
	txtStatus.text = ""
	txtDiff.text = ""
	get_commits()
	update_status()
	show_diff()
## end switch_branch()



func update_status():
	var results := []
	var current_status := OS.execute("powershell.exe", ["cd " + path + "; git status"], results)
	txtStatus.text = ""
	txtStatus.text = results[0]
## end get_txtStatus()



func show_diff(hash=""):
	var results := []
	if hash == "":
		var commit_diff := OS.execute("powershell.exe", ["cd " + path + "; git diff"], results)
	else:
		var commit_diff := OS.execute("powershell.exe", ["cd " + path + "; git diff " + hash + "^!"], results)
	txtDiff.text = ""
	txtDiff.text = results[0]
## end show_diff()






















###################################  WHITE SPACE FOR SCROLLING  #########################################
