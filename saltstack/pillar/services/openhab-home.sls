openhab:
  id: Openhab
  zigbee2mqtt:
    id: Openhab-zigbee2mqtt
    instances:
      # Old setup
      old:
        topic: zigbee2mqtt
        device: usb-1a86_USB_Serial-if00-port0
        channel: 25
        pan_id: 1872
        port: 3001
      ikea:
        topic: z2m-ikea
        device: usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_90685fe8398aef11abb4c0a3ef8776e9-if00-port0
        channel: 11
        pan_id: 0x1f01
        port: 3002
      common:
        topic: z2m-common
        device: usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_fec54b2bcb8aef11a7e327ccef8776e9-if00-port0
        channel: 20
        pan_id: 0x1f02
        port: 3003
  mosquitto:
    id: Openhab-mosquitto
  tuyamqtt:
    id: Openhab-tuyamqtt
  influxdb:
    id: Openhab-influxdb
  yandex2mqtt:
    id: Openhab-yandex2mqtt

proxy_vhosts:
  openhab:
    domain: home.pws
    ssl: internal
    ssl_name: home
  openhab-stats:
    domain: stats.home.pws
    ssl: internal
    ssl_name: home
  openhab-zigbee2mqtt:
    domain: z2m.home.pws
    ssl: internal
    ssl_name: home

# Devices:
# Old: usb-1a86_USB_Serial-if00-port0
# A (Ikea): usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_90685fe8398aef11abb4c0a3ef8776e9-if00-port0
# B (common): usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_fec54b2bcb8aef11a7e327ccef8776e9-if00-port0

