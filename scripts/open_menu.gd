extends CanvasLayer

var path = ""
var terminal = "powershell.exe"

@onready var open_panel = $open_panel
@onready var btnOpen = $open_panel/open_button
@onready var btnClone = $open_panel/clone_button
@onready var clone_panel = $open_panel/clone_panel
@onready var txtCloneURL = $open_panel/clone_panel/repository_url
@onready var btnCloneLocation = $open_panel/clone_panel/browse_button
@onready var message_panel = $open_panel/message_panel
@onready var txtMessage = $open_panel/message_panel/message
@onready var btnCloseMessage = $open_panel/message_panel/message_button





func _ready():
	btnOpen.pressed.connect(func(): open_repository())
	btnClone.pressed.connect(func(): toggle_clone_repository())
	btnCloneLocation.pressed.connect(func(): choose_location())
	btnCloseMessage.pressed.connect(func(): close_message_panel())
## end ready()



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



func open_repository():
	var results = run_other_command("python ./scripts/open_repository.py")
	if results[0] == "not a repository\r\n":
		path = ""
		message_panel.visible = true
		txtMessage.text = "Error, the chosen directory does not appear to be a Git repository"
		txtMessage.self_modulate = Color(0.78, 0.22, 0.32, 0.9)
	else:
		path = results[0].rstrip("\r\n")
		open_panel.visible = false
		## LOAD IN REPOSITORY ##
## end open_repository()



func toggle_clone_repository():
	clone_panel.visible = not clone_panel.visible
## end clone_repository()



func close_message_panel():
	txtMessage.text = ""
	txtMessage.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	message_panel.visible = false
## end close_message_panel()



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
			scan_history()
			txtCloneURL.text = ""
			toggle_clone_repository()
			open_panel.visible = false
			## LOAD IN REPOSITORY MODELS ##
## end choose_location()



func scan_history():
	pass
#	clear_branches()
#	clear_commits()
#	txtCommit.text = ""
#	txtStatus.text = ""
#	txtDiff.text = ""
#	get_branches()
#	get_commits()
#	update_status()
#	open_log()
#	show_diff()
#	for bb in branch_buttons:
#		if "remotes/" in bb.text:
#			btnRemoteControls.visible = true
#			break
#		else:
#			btnRemoteControls.visible = false
## end scan_history()























##################  WHITE SPACE FOR SCROLLING  ########################
