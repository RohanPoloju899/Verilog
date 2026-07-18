import Adafruit_IO
import time

username="rohan_poloju"
key=""

aio=Adafruit_IO.Client(username,key)

max=10

value=1

while True:
	aio.send("python_sample",value)
	print("Sent:",value)
	
	value+=1
	if(value>max):
		value=1
	time.sleep(1)
