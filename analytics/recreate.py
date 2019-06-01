import sys
import os
import subprocess

if len(sys.argv) != 3:
	exit("Usage: python3 recreate.py /path/to/logfile recordingsdir")

data = open(sys.argv[1]).read().splitlines()

with open("fullshow"+sys.argv[2]+".txt", "a") as myfile:
	for i in data:
		if "!created:" in i:
			i = i.split(" ")
			if os.stat("../recordings/"+sys.argv[2]+"/"+i[1]+".flv").st_size > 0:
				myfile.write("file '../recordings/"+sys.argv[2]+"/"+i[1]+".flv'\n")

#subprocess.Popen("ffmpeg -f concat -safe 0 -i fullshow"+sys.argv[2]+".txt -c copy fullshow"+sys.argv[2]+".flv", shell=True)
