
from tkinter.filedialog import askdirectory
from os.path import isdir

path = askdirectory()

if isdir(path):
	print(path)
else:
	print("invalid")