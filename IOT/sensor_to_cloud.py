from Adafruit_IO import Client
from adafruit_dht import DHT11
from board import D4
from time import sleep

username = "rohan_poloju"
key = ""

aio = Client(username, key)

dht = DHT11(D4)

while True:
      temperature = dht.temperature
      humidity = dht.humidity

      print("Temperature:", temperature)
      print("Humidity:", humidity)

      # Send temperature to the feed
      aio.send("python-sample", temperature)

      sleep(10)

"""
DHT11            Raspberry Pi
-----------------------------
VCC   ---------> 3.3V (Pin 1)
DATA  ---------> GPIO4 (Pin 7)
GND   ---------> GND (Pin 6)
"""
