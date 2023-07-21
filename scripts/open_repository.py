
from tkinter.filedialog import askdirectory
from os.path import isdir

path = askdirectory()

if isdir(path + "/.git"):
	print(path)
else:
	print("not a repository")
