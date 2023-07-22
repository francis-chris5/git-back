extends Node3D

var path = ""
var terminal = "powershell.exe"


var branch_boxes = []
var current_branch = ""
var branch_box_class = preload("res://objects/branch_box.tscn")



@onready var open_panel = $open_menu/open_panel
@onready var btnOpen = $open_menu/open_panel/open_button
@onready var btnClone = $open_menu/open_panel/clone_button
@onready var clone_panel = $open_menu/open_panel/clone_panel
@onready var txtCloneURL = $open_menu/open_panel/clone_panel/repository_url
@onready var btnCloneLocation = $open_menu/open_panel/clone_panel/browse_button
@onready var message_panel = $open_menu/open_panel/message_panel
@onready var txtMessage = $open_menu/open_panel/message_panel/message
@onready var btnCloseMessage = $open_menu/open_panel/message_panel/message_button




func _unhandled_input(event):
	if Input.is_action_pressed("open_menu"):
		toggle_visible()
## end _unhandled_input()



func _ready():
	btnOpen.pressed.connect(func(): open_repository())
	btnClone.pressed.connect(func(): toggle_clone_repository())
	btnCloneLocation.pressed.connect(func(): choose_location())
	btnCloseMessage.pressed.connect(func(): close_message_panel())
## end _ready()



func run_git_command(command, locale=""):
	if locale == "":
		locale = path
	var results := []
	var git_command := OS.execute(terminal, ["cd '" + locale + "'; " + command], results)
	return results
## end run_git_command()



func run_other_command(command):
	var results := []
	var path_dialog = OS.execute(terminal, [command], results)
	return results
## end run_other_command()



func toggle_clone_repository():
	clone_panel.visible = not clone_panel.visible
## end clone_repository()



func close_message_panel():
	txtMessage.text = ""
	txtMessage.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	message_panel.visible = false
## end close_message_panel()



func toggle_visible():
	open_panel.visible = not open_panel.visible
## end toggle_visible()



func open_repository():
	var results = run_other_command("python ./scripts/open_repository.py")
	if results[0] == "not a repository\r\n":
		path = ""
		message_panel.visible = true
		txtMessage.text = "Error, the chosen directory does not appear to be a Git repository"
		txtMessage.self_modulate = Color(0.78, 0.22, 0.32, 0.9)
	else:
		path = results[0].rstrip("\r\n")
		toggle_visible()
		scan_history()
## end open_repository()



func choose_location():
	if txtCloneURL.text == "":
		pass
	else:
		var results = run_other_command("python ./scripts/choose_location.py")
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
			txtCloneURL.text = ""
			toggle_clone_repository()
			toggle_visible()
			scan_history()
## end choose_location()



func scan_history():
	clear_branches()
#	clear_commits()
#	txtCommit.text = ""
#	txtStatus.text = ""
#	txtDiff.text = ""
	get_branches()
#	get_commits()
#	update_status()
#	open_log()
#	show_diff()
#	for bb in branch_boxes:
#		if "remotes/" in bb.text:
#			btnRemoteControls.visible = true
#			break
#		else:
#			btnRemoteControls.visible = false
## end scan_history()



func get_branches():
	clear_branches()
	var color = Color(0.29, 0.16, 0.07, 1.0)
	var results = run_git_command("git branch -a")
	var branches = results[0].split("\n")
	branches.remove_at(len(branches)-1)
	for b in branches:
		b = b.lstrip(" ")
		var boxBranch = branch_box_class.instantiate()
		if b[0] == "*":
			color = Color(0.65, 0.65, 0.02, 1.0)
			b = b.lstrip(" *")
			current_branch = str(b)
		if "remotes/" in b:
			color = Color(0.35, 0.39, 0.80, 0.9)
		boxBranch.branch_name = str(b)
		boxBranch.label_color = color
		branch_boxes.append(boxBranch)
	var i = 0
	var j = 0
	for bb in branch_boxes:
		if bb != null:
			add_child(bb)
			bb.show_name()
			bb.position = Vector3(-4-3*j, 0, 7-2*i)
			bb.rotation.y += deg_to_rad(90)
			i += 1
			if i > 6:
				i = 0
				j += 1
## end get_branches()



func clear_branches():
	for bb in branch_boxes:
		if bb != null:
			bb.queue_free()
	branch_boxes = []
## end clear_branches()





















#######################  WHITE SPACE FOR SCROLLING  #########################
