from Adafruit_IO import Client
import adafruit_dht
import board
import time

ADAFRUIT_AIO_USERNAME = "rohan_poloju"
ADAFRUIT_AIO_KEY = "YOUR_NEW_AIO_KEY"

aio = Client(ADAFRUIT_AIO_USERNAME, ADAFRUIT_AIO_KEY)

dht = adafruit_dht.DHT11(board.D4)

while True:
      temperature = dht.temperature
      humidity = dht.humidity

      print("Temperature:", temperature)
      print("Humidity:", humidity)

      # Send temperature to the feed
      aio.send("python-sample", temperature)

      time.sleep(10)
