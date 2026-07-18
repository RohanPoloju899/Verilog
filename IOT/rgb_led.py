from gpiozero import RGBLED
from time import sleep

led = RGBLED(red=17, green=27, blue=22)

while True:
    # RED ON
    led.color = (1, 0, 0)
    print("RED ON")
    sleep(10)

    # GREEN ON
    led.color = (0, 1, 0)
    print("GREEN ON")
    sleep(10)

    # BLUE ON
    led.color = (0, 0, 1)
    print("BLUE ON")
    sleep(10)

    # WHITE (ALL ON)
    led.color = (1, 1, 1)
    print("WHITE (ALL ON)")
    sleep(10)
