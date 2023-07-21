extends CanvasLayer

var path := ""
var terminal = "powershell.exe"

var current_branch = ""
var current_commit = ""

var branch_buttons = []
var commit_buttons = []
var commit_logs = []
var file_list = []
var revert_list = []
var push_buttons = []
var pull_buttons = []

var hash_to_revert = ""

enum merge {BRANCH, CHERRY_PICK}
var merge_branch = ""
var pick_from = ""
var pick_into = ""

enum remote {PUSH, PULL}


@onready var btnOpen = $application/main_menu/open
@onready var btnClone = $application/main_menu/clone
@onready var btnHelp = $application/main_menu/help


@onready var clone_panel = $application/clone_panel
@onready var btnCloneLocation = $application/clone_panel/clone_location
@onready var txtCloneURL = $application/clone_panel/clone_url


@onready var btnCheckoutControls = $application/control_options/checkout_controls
@onready var btnRevertControls = $application/control_options/revert_controls
@onready var btnBlameControls = $application/control_options/blame_controls
@onready var btnMergeControls = $application/control_options/merge_controls
@onready var btnRemoteControls = $application/control_options/remote_controls


@onready var checkout_panel = $application/checkout_panel
@onready var revert_panel = $application/revert_panel
@onready var blame_panel = $application/blame_panel
@onready var merge_panel = $application/merge_panel
@onready var remote_panel = $application/remote_panel
@onready var help_panel = $application/help_panel

@onready var txtManual = $application/help_panel/user_manual


@onready var dialog_panel = $application/dialog_panel
@onready var txtMessage = $application/dialog_panel/message_text
@onready var btnCloseMessage = $application/dialog_panel/close_message


@onready var txtCommit = $application/checkout_panel/commit_log
@onready var txtStatus = $application/checkout_panel/status
@onready var txtDiff = $application/checkout_panel/diff

@onready var commit_container = $application/checkout_panel/commits/commit_container
@onready var branch_container = $application/checkout_panel/branches/branch_container

@onready var new_branch_panel = $application/checkout_panel/new_branch_panel
@onready var btnClearDetatched = $application/checkout_panel/clear_detatched
@onready var btnBranchDetatched = $application/checkout_panel/new_branch_panel/branch_detached
@onready var txtBranchName = $application/checkout_panel/new_branch_panel/branch_name


@onready var revert_commit_container = $application/revert_panel/revert_commits/revert_commit_container
@onready var txtRevert = $application/revert_panel/revert_text
@onready var btnRevert = $application/revert_panel/revert_tools/revert_button
@onready var txtRevertMessage = $application/revert_panel/revert_message


@onready var blame_file_container = $application/blame_panel/blame_files/blame_file_container
@onready var txtBlameFile = $application/blame_panel/blame_file_current

@onready var into_container = $application/merge_panel/merge_into/into_container
@onready var from_container = $application/merge_panel/merge_from/from_container
@onready var pick_into_container = $application/merge_panel/pick_into/pick_into_container
@onready var pick_from_container = $application/merge_panel/pick_from/pick_from_container
@onready var txtMerge = $application/merge_panel/merge_message
@onready var btnMerge = $application/merge_panel/merge_branch_button
@onready var btnCherryPick = $application/merge_panel/cherry_pick_button
@onready var btnPullRequest = $application/merge_panel/merge_control_container/pull_request_button
@onready var btnConfirmMerge = $application/merge_panel/merge_control_container/confirm_merge_button
@onready var btnAbortMerge = $application/merge_panel/merge_control_container/abort_merge



@onready var existing_pull_container = $application/remote_panel/existing_pull/existing_pull_container
@onready var existing_push_container = $application/remote_panel/existing_push/existing_push_container
@onready var btnPullLatest = $application/remote_panel/pull_latest_button
@onready var chkAllowHistory = $application/remote_panel/allow_history_check
@onready var txtPushBranchName = $application/remote_panel/new_branch_name
@onready var btnPush = $application/remote_panel/push_branch_button
@onready var chkForce = $application/remote_panel/force_check
@onready var txtRemoteMessage = $application/remote_panel/remote_message




func _ready():
	btnOpen.pressed.connect(func(): open_repository())
	btnClone.pressed.connect(func(): toggle_clone_repository())
	btnCloneLocation.pressed.connect(func(): choose_location())
	btnHelp.pressed.connect(func(): toggle_help_panel())
	btnCloseMessage.pressed.connect(func(): close_message_panel())
	
	btnCheckoutControls.pressed.connect(func(): view_checkout_panel())
	btnRevertControls.pressed.connect(func(): view_revert_panel())
	btnBlameControls.pressed.connect(func(): view_blame_panel())
	btnMergeControls.pressed.connect(func(): view_merge_panel())
	btnRemoteControls.pressed.connect(func(): view_remote_panel())
	
	btnClearDetatched.pressed.connect(func(): clear_detatched())
	btnBranchDetatched.pressed.connect(func(): branch_detatched())
	
	btnRevert.pressed.connect(func(): revert_commit())
	
	btnMerge.pressed.connect(func(): branch_merging())
	btnCherryPick.pressed.connect(func(): cherry_pick_merging())
	btnPullRequest.pressed.connect(func(): make_pull_request())
	btnConfirmMerge.pressed.connect(func(): confirm_commit())
	btnAbortMerge.pressed.connect(func(): abort_merge())
	
	btnPush.pressed.connect(func(): push_changes())
	btnPullLatest.pressed.connect(func(): pull_latest())
## end _ready()


func _process(delta):
	pass
## end _process()


func run_git_command(command, locale=""):
	if locale == "":
		locale = path
	var results := []
	var git_command := OS.execute(terminal, ["cd " + locale + "; " + command], results)
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
		path = ""
		dialog_panel.visible = true
		txtMessage.text = "Error, the chosen directory does not appear to be a Git repository"
		txtMessage.self_modulate = Color(0.78, 0.22, 0.32, 0.9)
	else:
		path = results[0]
		view_checkout_panel()
		scan_history()
## end open_repository()


func toggle_clone_repository():
	clone_panel.visible = not clone_panel.visible
## end clone_repository()



func toggle_help_panel():
	help_panel.visible = not help_panel.visible
	checkout_panel.visible = false
	revert_panel.visible = false
	blame_panel.visible = false
	merge_panel.visible = false
	remote_panel.visible = false
	if help_panel.visible:
		var manual = FileAccess.get_file_as_string("./user-manual.txt")
		txtManual.text = manual
	else:
		txtManual.text = ""
## end view_help_panel()



func close_message_panel():
	txtMessage.text = ""
	txtMessage.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	dialog_panel.visible = false
## end close_message_panel()



func wipe_panels():
	help_panel.visible = false
	checkout_panel.visible = false
	revert_panel.visible = false
	blame_panel.visible = false
	merge_panel.visible = false
	remote_panel.visible = false
## end wipe_panels()



func view_checkout_panel():
	wipe_panels()
	checkout_panel.visible = true
	scan_history()
## end view_checkout_panel()


func view_revert_panel():
	wipe_panels()
	revert_panel.visible = true
	get_revert_commits()
## end view_revert_panel()


func view_blame_panel():
	wipe_panels()
	blame_panel.visible = true
	scan_files()
	txtBlameFile.text = ""
## end view_blame_panel()



func view_merge_panel():
	wipe_panels()
	merge_panel.visible = true
	reset_merge()
## end view_merge_panel()



func view_remote_panel():
	wipe_panels()
	remote_panel.visible = true
	txtRemoteMessage.text = ""
	clear_remote_containers()
	get_remote_branches(remote.PUSH)
	get_remote_branches(remote.PULL)
## end view_remote_panel()



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
	for bb in branch_buttons:
		if "remotes/" in bb.text:
			btnRemoteControls.visible = true
			break
		else:
			btnRemoteControls.visible = false
## end scan_history()


func get_branches():
	clear_branches()
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
		btnBranch.tooltip_text = str(b)
		if "remotes/" not in b:
			btnBranch.pressed.connect(func(): switch_branch(b, btnBranch))
		else:
			var branch = b.get_slice("/", b.get_slice_count("/")-1)
			btnBranch.pressed.connect(func(): switch_branch(branch, btnBranch))
			btnBranch.self_modulate = Color(0.35, 0.39, 0.80, 0.9)
		branch_buttons.append(btnBranch)
	for bb in branch_buttons:
		if bb != null:
			branch_container.add_child(bb)
## end get_branches()



func clear_branches():
	for bb in branch_buttons:
		if bb != null:
			bb.queue_free()
	branch_buttons = []
## end clear_branches()



func get_commits():
	clear_commits()
	var results = run_git_command("git log --oneline")
	var hashes = results[0].split("\n")
	hashes.remove_at(len(hashes)-1)
	for h in hashes:
		var btnHash := Button.new()
		btnHash.text_overrun_behavior =TextServer.OVERRUN_TRIM_ELLIPSIS
		btnHash.text = str(h)
		btnHash.tooltip_text = str(h)
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
	commit_buttons = []
## end clear_commits()



func checkout_commit(hash, button):
	for cb in commit_buttons:
		if cb != null:
			cb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	if "HEAD detached" in txtStatus.text:
		run_git_command("git checkout " + current_branch)
		run_git_command("git stash pop")
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	txtCommit.text = ""
	run_git_command("git add .")
	run_git_command("git stash")
	var results = run_git_command("git checkout " + hash)
	txtCommit.text = results[0]
	get_commits()
	open_log()
	show_diff(hash)
	update_status()
	current_commit = hash
## end checkout_commit()



func clear_detatched():
	run_git_command("git checkout " + current_branch)
	scan_history()
## end clear_detatched()



func branch_detatched():
	var branch_name = ""
	if txtBranchName.text == "":
		branch_name = "from_" + current_commit
	else:
		branch_name = txtBranchName.text
	run_git_command("git switch -c " + branch_name)
	scan_history()
	txtBranchName.text = ""
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
	clear_files()
	var results = run_git_command("git ls-files")
	var files = results[0].split("\n")
	files.remove_at(len(files)-1)
	for f in files:
		var btnFile := Button.new()
		btnFile.text_overrun_behavior =TextServer.OVERRUN_TRIM_ELLIPSIS
		btnFile.text = str(f)
		btnFile.tooltip_text = str(f)
		btnFile.pressed.connect(func(): show_blame(str(f), btnFile))
		file_list.append(btnFile)
	for fl in file_list:
		if fl != null:
			blame_file_container.add_child(fl)
## end scan_files()



func clear_files():
	for fl in file_list:
		if fl != null:
			fl.queue_free()
	file_list = []
## end clear_files()



func show_blame(filepath, button):
	for fl in file_list:
		if fl != null:
			fl.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	var results = run_git_command("git blame " + filepath)
	txtBlameFile.text = results[0]
## end show_blame()




func get_revert_commits():
	txtRevertMessage.text = ""
	txtRevert.text = ""
	btnRevert.disabled = true
	clear_revert()
	var results = run_git_command("git log --oneline")
	var hashes = results[0].split("\n")
	hashes.remove_at(len(hashes)-1)
	for h in hashes:
		var btnHash := Button.new()
		btnHash.text_overrun_behavior =TextServer.OVERRUN_TRIM_ELLIPSIS
		btnHash.text = str(h)
		btnHash.tooltip_text = str(h)
		var hash = h.split(" ")[0]
		current_commit = hash
		btnHash.pressed.connect(func(): preview_revert(hash, btnHash))
		revert_list.append(btnHash)
	for rl in revert_list:
		if rl != null:
			revert_commit_container.add_child(rl)
## end get_commits()



func clear_revert():
	for rl in revert_list:
		if rl != null:
			rl.queue_free()
	revert_list = []
## end clear_revert()




func preview_revert(hash, button):
	for rl in revert_list:
		if rl != null:
			rl.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	var results = run_git_command("git diff " + hash + "^!")
	txtRevert.text = results[0]
	btnRevert.disabled = false
	hash_to_revert = hash
## end preview_revert()



func revert_commit():
	var results = run_git_command("git revert " + hash_to_revert + " --no-edit")
	txtRevert.text = ""
	get_revert_commits()
	get_commits()
	txtRevertMessage.text = results[0]
	btnRevert.disabled = true
## end revert_commit()



func branch_merging():
	btnPullRequest.disabled = true
	reset_merge()
	get_merge_branches(merge.BRANCH)
## end branch_merging()



func cherry_pick_merging():
	reset_merge()
	get_merge_branches(merge.CHERRY_PICK)
	get_pick_from_commits()
	btnPullRequest.disabled = true
	btnConfirmMerge.disabled = true
	btnAbortMerge.disabled = true
## end cherry_pick_merging()



func reset_merge():
	clear_branches()
	clear_commits()
	txtMerge.text = ""
	btnPullRequest.disabled = true
	btnConfirmMerge.disabled = true
	btnAbortMerge.disabled = true
## end reset_merge()



func get_merge_branches(merge_type):
	clear_branches()
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
			btnBranch.tooltip_text = str(b)
			if merge_type == merge.BRANCH:
				btnBranch.pressed.connect(func(): merge_this_branch(b, btnBranch))
				branch_buttons.append(btnBranch)
		else:
			btnBranch.text = str(b)
			btnBranch.tooltip_text = str(b)
			if merge_type == merge.BRANCH and "remotes/" not in b:
				btnBranch.pressed.connect(func(): merge_this_branch(b, btnBranch))
				branch_buttons.append(btnBranch)
			elif merge_type == merge.CHERRY_PICK and "remotes/" not in b:
				btnBranch.pressed.connect(func(): pick_this_branch(b, btnBranch))
				branch_buttons.append(btnBranch)
	if merge_type == merge.BRANCH:
		for bb in branch_buttons:
			if bb != null:
				if bb.text == current_branch:
					into_container.add_child(bb)
				else:
					from_container.add_child(bb)
	elif merge_type == merge.CHERRY_PICK:
		for bb in branch_buttons:
			if bb != null:
				pick_into_container.add_child(bb)
## end get_merge_branches()



func merge_this_branch(branch_name, button):
	for bb in branch_buttons:
		if bb != null:
			bb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	merge_branch = branch_name
	btnPullRequest.disabled = false
## end merge_this_branch()



func get_pick_from_commits():
	clear_commits()
	var results = run_git_command("git log --oneline")
	var hashes = results[0].split("\n")
	hashes.remove_at(len(hashes)-1)
	for h in hashes:
		var btnHash := Button.new()
		btnHash.text_overrun_behavior =TextServer.OVERRUN_TRIM_ELLIPSIS
		btnHash.text = str(h)
		btnHash.tooltip_text = str(h)
		var hash = h.split(" ")[0]
		current_commit = hash
		btnHash.pressed.connect(func(): cherry_picking(hash, btnHash))
		commit_buttons.append(btnHash)
	for cb in commit_buttons:
		if cb != null:
			pick_from_container.add_child(cb)
## end get_pick_from_commits()



func make_pull_request():
	if current_branch != "" and merge_branch != "":
		var results = run_git_command("git merge " + current_branch + " " + merge_branch + " --no-commit --no-ff")
		if "CONFLICT" not in results[0]:
			btnConfirmMerge.disabled = false
			btnAbortMerge.disabled = false
			txtMerge.text += "the preview checks out, please confirm to complete the merge"
		else:
			txtMerge.text += "There appears to be conflicts, please resolve conflicts and try again\n"
			txtMerge.text += results[0]
	elif pick_from != "" and pick_into != "":
		run_git_command("git checkout " + pick_into)
		var results = run_git_command("git cherry-pick " + pick_from)
		txtMerge.text = results[0]
## end make_pull_request()



func confirm_commit():
	var results = run_git_command("git commit --no-edit")
	txtMerge.text = results[0]
## end confirm_commit()



func abort_merge():
	var results = run_git_command("git merge --abort")
	txtMerge.text = "Aborted merge"
## end abort_merge()



func cherry_picking(hash, button):
	for cb in commit_buttons:
		if cb != null:
			cb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	pick_from = hash
	btnPullRequest.disabled = false
## end cherry_picking()



func pick_this_branch(branch_name, button):
	for bb in branch_buttons:
		if bb != null:
			bb.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
	pick_into = branch_name
## end pick_this_branch()



func get_remote_branches(remote_type):
	clear_branches()
	var results = run_git_command("git branch -a")
	var branches = results[0].split("\n")
	branches.remove_at(len(branches)-1)
	var i : int = 0
	for b in branches:
		if remote_type == remote.PUSH:
			b = b.lstrip(" ")
			var btnBranch = Button.new()
			btnBranch.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			if b[0] == "*":
				btnBranch.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
				b = b.lstrip(" *")
				current_branch = str(b)
				btnBranch.tooltip_text = "Please checkout the branch to push to"
				btnBranch.text = str(b)
				push_buttons.append(btnBranch)
		elif remote_type == remote.PULL:
			b = b.lstrip(" ")
			var btnBranch = Button.new()
			btnBranch.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			if b[0] == "*":
				btnBranch.self_modulate = Color(0.65, 0.65, 0.02, 1.0)
				b = b.lstrip(" *")
				current_branch = str(b)
				btnBranch.pressed.connect(func(): choose_pull_branch(b, btnBranch))
			if "remotes/" not in b:
				btnBranch.pressed.connect(func(): choose_pull_branch(b, btnBranch))
			else:
				var branch = b.get_slice("/", b.get_slice_count("/")-1)
				btnBranch.pressed.connect(func(): choose_pull_branch(branch, btnBranch))
				btnBranch.self_modulate = Color(0.35, 0.39, 0.80, 0.9)
			btnBranch.text = str(b)
			pull_buttons.append(btnBranch)
	for pb in push_buttons:
		if pb != null:
			existing_push_container.add_child(pb)
	for pl in pull_buttons:
		if pl != null:
			existing_pull_container.add_child(pl)
## end get_remote_branches()



func choose_pull_branch(branch_name, button):
	run_git_command("git checkout " + branch_name)
	current_branch = branch_name
	clear_remote_containers()
	get_remote_branches(remote.PUSH)
	get_remote_branches(remote.PULL)
## end choose_pull_branch()



func clear_remote_containers():
	for pb in push_buttons:
		if pb != null:
			pb.queue_free()
	for pl in pull_buttons:
		if pl != null:
			pl.queue_free()
## end clear_remote_containers()



func push_changes():
	var results = []
	if chkForce.button_pressed:
		results = run_git_command("git push origin " + current_branch + " -f")
	else:
		results = run_git_command("git push origin " + current_branch)
	print(results)
	txtRemoteMessage.text = "changes probably pushed back\nto " + current_branch + "\nthe gui doesn't want to\nwait for the upload message to finish\n\n" + results[0]
## end push_changes()



func pull_latest():
	var results = []
	if chkAllowHistory.button_pressed:
		results = run_git_command("git pull origin " + current_branch + " --allow-unrelated-histories")
	else:
		results = run_git_command("git pull origin " + current_branch)
	print(results)
	txtRemoteMessage.text = results[0]
## end pull_latest()






























###################################  WHITE SPACE FOR SCROLLING  #########################################
