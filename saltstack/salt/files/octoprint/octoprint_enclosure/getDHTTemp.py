import time
import board
import adafruit_dht

# Initial the dht device, with data pin connected to:
dhtDevice = adafruit_dht.DHT22(board.D4)

# you can pass DHT22 use_pulseio=False if you wouldn't like to use pulseio.
# This may be necessary on a Linux single board computer like the Raspberry Pi,
# but it will not work in CircuitPython.
# dhtDevice = adafruit_dht.DHT22(board.D18, use_pulseio=False)

try:
    # Print the values to the serial port
    temperature_c = dhtDevice.temperature
    humidity = dhtDevice.humidity
    print("{:.1f} | {} ".format(temperature_c, humidity))

except RuntimeError as error:
    # Errors happen fairly often, DHT's are hard to read, just keep going
    # print(error.args[0])
    print('-1 | -1')
except Exception as error:
    dhtDevice.exit()
    raise error
