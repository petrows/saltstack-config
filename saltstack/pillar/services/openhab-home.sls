openhab:
  id: Openhab
  zigbee2mqtt:
    id: Openhab-zigbee2mqtt
    instances:
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
    port: 3001
    enable_http2: True
    custom_config: |
        location /api {
            proxy_pass http://127.0.0.1:3001/api;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

  openhab-zigbee2mqtt-ikea:
    domain: z2m-ikea.home.pws
    ssl: internal
    ssl_name: home
    port: 3002
    enable_http2: True
    custom_config: |
        location /api {
            proxy_pass http://127.0.0.1:3002/api;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
  openhab-zigbee2mqtt-common:
    domain: z2m-common.home.pws
    ssl: internal
    ssl_name: home
    port: 3003
    enable_http2: True
    custom_config: |
        location /api {
            proxy_pass http://127.0.0.1:3003/api;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

# Devices:
# Old: usb-1a86_USB_Serial-if00-port0
# A (Ikea): usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_90685fe8398aef11abb4c0a3ef8776e9-if00-port0
# B (common): usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_fec54b2bcb8aef11a7e327ccef8776e9-if00-port0

