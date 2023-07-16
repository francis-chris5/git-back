extends CanvasLayer

var path := "."
var terminal = "powershell.exe"

var current_branch = ""
var current_commit = ""

var branch_buttons = []
var commit_buttons = []
var commit_logs = []
var file_list = []


@onready var btnOpen = $application/main_menu/open
@onready var btnClone = $application/main_menu/clone


@onready var clone_panel = $application/clone_panel
@onready var btnCloneLocation = $application/clone_panel/clone_location
@onready var txtCloneURL = $application/clone_panel/clone_url


@onready var btnCheckoutControls = $application/control_options/checkout_controls
@onready var btnRevertControls = $application/control_options/revert_controls
@onready var btnBlameControls = $application/control_options/blame_controls

@onready var checkout_panel = $application/checkout_panel
@onready var revert_panel = $application/revert_panel
@onready var blame_panel = $application/blame_panel


@onready var txtCommit = $application/checkout_panel/commit_log
@onready var txtStatus = $application/checkout_panel/status
@onready var txtDiff = $application/checkout_panel/diff

@onready var commit_container = $application/checkout_panel/commits/commit_container
@onready var branch_container = $application/checkout_panel/branches/branch_container

@onready var new_branch_panel = $application/checkout_panel/new_branch_panel
@onready var btnClearDetatched = $application/checkout_panel/clear_detatched
@onready var btnBranchDetatched = $application/checkout_panel/new_branch_panel/branch_detached
@onready var txtBranchName = $application/checkout_panel/new_branch_panel/branch_name


@onready var blame_file_container = $application/blame_panel/ScrollContainer/blame_file_container
@onready var txtBlameFile = $application/blame_panel/blame_file_current



func _ready():
	btnOpen.pressed.connect(func(): open_repository())
	btnClone.pressed.connect(func(): toggle_clone_repository())
	btnCloneLocation.pressed.connect(func(): choose_location())
	
	btnCheckoutControls.pressed.connect(func(): view_checkout_panel())
	btnRevertControls.pressed.connect(func(): view_revert_panel())
	btnBlameControls.pressed.connect(func(): view_blame_panel())
	
	btnClearDetatched.pressed.connect(func(): clear_detatched())
	btnBranchDetatched.pressed.connect(func(): branch_detatched())
## end _ready()


func _process(delta):
	pass
## end _process()


func run_git_command(command, locale=""):
	if locale == "":
		locale = path
	var results := []
	var git_command := OS.execute("powershell.exe", ["cd " + locale + "; " + command], results)
	return results
## end run_git_command()


func run_other_command(command):
	var results := []
	var path_dialog = OS.execute(terminal, [command], results)
	return results
## end run_other_command()


func open_repository():
	var results = run_other_command("python open_repository.py")
	if results[0] == "not a repository\r\n":
		path = "."
	else:
		path = results[0]
	view_checkout_panel()
	scan_history()
## end open_repository()


func toggle_clone_repository():
	clone_panel.visible = not clone_panel.visible
## end clone_repository()


func view_checkout_panel():
	checkout_panel.visible = true
	revert_panel.visible = false
	blame_panel.visible = false
## end toggle_checkout_panel()


func view_revert_panel():
	checkout_panel.visible = false
	revert_panel.visible = true
	blame_panel.visible = false
## end toggle_checkout_panel()


func view_blame_panel():
	checkout_panel.visible = false
	revert_panel.visible = false
	blame_panel.visible = true
	scan_files()
	txtBlameFile.text = ""
## end toggle_checkout_panel()


func choose_location():
	if txtCloneURL.text == "":
		pass
	else:
		var results = run_other_command("python choose_location.py")
		var locale = ""
		if results[0] == "invalid\r\n":
			locale = "C:/"
		else:
			locale = results[0].rstrip("\r\n")
		results = run_git_command("git clone " + txtCloneURL.text, locale)
		if "fatal" not in results[0]:
			var repo_name = ""
			var repo = txtCloneURL.text.split("/")
			if ".git" in repo[len(repo)-1]:
				repo_name = repo[len(repo)-1].get_slice(".", 0)
			else:
				repo_name = repo[len(repo)-1]
			path = locale + "/" + repo_name
			scan_history()
			txtCloneURL.text = ""
			toggle_clone_repository()
			view_checkout_panel()
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
	var results = run_git_command("git branch -a")
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
			current_branch = str(b)
		btnBranch.text = str(b)
		btnBranch.pressed.connect(func(): switch_branch(b, btnBranch))
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
	## KEEP THIS TO COPY LATER ##var get_hashes := OS.execute("powershell.exe", ["git log --pretty=format:%h"], results)
	var results = run_git_command("git log --oneline")
	var hashes = results[0].split("\n")
	hashes.remove_at(len(hashes)-1)
	for h in hashes:
		var btnHash := Button.new()
		btnHash.text_overrun_behavior =TextServer.OVERRUN_TRIM_ELLIPSIS
		btnHash.text = str(h)
		var hash = h.split(" ")[0]
		current_commit = hash
		btnHash.pressed.connect(func(): checkout_commit(hash, btnHash))
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



func checkout_commit(hash, button):
	for cb in commit_buttons:
		if cb != null:
			cb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	if "HEAD detached" in txtStatus.text:
		run_git_command("git checkout " + current_commit)
		run_git_command("git stash pop")
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	txtCommit.text = ""
	run_git_command("git add .")
	run_git_command("git stash")
	var results = run_git_command("git checkout " + hash)
	txtCommit.text = results[0]
	clear_commits()
	get_commits()
	open_log()
	show_diff(hash)
	update_status()
## end checkout_commit()



func clear_detatched():
	run_git_command("git checkout " + current_branch)
	scan_history()
## end clear_detatched()



func branch_detatched():
	var branch_name = ""
	if txtBranchName.text == "":
		branch_name = current_commit
	else:
		branch_name = txtBranchName.text
	run_git_command("git switch -c " + branch_name)
	scan_history()
## end branch_detatched()



func open_log():
	var results = run_git_command("git log")
	txtCommit.text = results[0]
## end open_log()



func switch_branch(branch_name, button):
	for bb in branch_buttons:
		if bb != null:
			bb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	var results = run_git_command("git checkout " + branch_name)
	if "fatal" not in results[0]:
		current_branch = branch_name
	scan_history()
## end switch_branch()



func update_status():
	var results = run_git_command("git status")
	txtStatus.text = ""
	txtStatus.text = results[0]
	if "HEAD detached" in results[0]:
		btnClearDetatched.visible = true
		new_branch_panel.visible = true
	else:
		btnClearDetatched.visible = false
		new_branch_panel.visible = false
## end get_txtStatus()



func show_diff(hash="", branches=[]):
	var results = []
	if hash != "":
		results = run_git_command("git diff " + hash + "^!")
	if len(branches):
		results = run_git_command("git diff " + branches[0] + " " + branches[1])
	txtDiff.text = ""
	if len(results) > 0:
		txtDiff.text = results[0]
## end show_diff()



func scan_files():
	var results = run_git_command("git ls-files")
	var files = results[0].split("\n")
	files.remove_at(len(files)-1)
	for f in files:
		var btnFile := Button.new()
		btnFile.text_overrun_behavior =TextServer.OVERRUN_TRIM_ELLIPSIS
		btnFile.text = str(f)
		btnFile.pressed.connect(func(): show_blame(str(f)))
		file_list.append(btnFile)
	for fl in file_list:
		if fl != null:
			blame_file_container.add_child(fl)
## end scan_files()



func show_blame(filepath):
	var results = run_git_command("git blame " + filepath)
	txtBlameFile.text = results[0]
## end show_blame()





















###################################  WHITE SPACE FOR SCROLLING  #########################################
