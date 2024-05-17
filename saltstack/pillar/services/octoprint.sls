{% import_yaml 'static.yaml' as static %}

roles:
  - octoprint

include:
  - services.nginx

packages:
  - ffmpeg
  - v4l-utils
  - ustreamer

octoprint:
  home: /srv/octoprint-data
  port: {{ static.proxy_ports.octoprint_http }}
  cfg:
    appearance:
      name: PWS Octoprint
      color: red
    webcam:
      stream: http://127.0.0.1:{{ static.proxy_ports.octoprint_video }}/?action=stream
      snapshot: http://127.0.0.1:{{ static.proxy_ports.octoprint_video }}/?action=snapshot

    plugins:
      psucontrol:
        GPIODevice: /dev/gpiochip0
        autoOn: true
        idleTimeout: '15'
        invertonoffGPIOPin: true
        onoffGPIOPin: '15'
        powerOffWhenIdle: true
        senseGPIOPin: '15'
        senseGPIOPinPUD: PULL_UP
        switchingMethod: GPIO
        turnOffWhenError: true
      enclosure:
        debug_temperature_log: true
        use_sudo: false
        rpi_inputs:
        - action_type: output_control
          controlled_io: null
          controlled_io_set_value: low
          ds18b20_serial: ''
          edge: fall
          filament_sensor_enabled: true
          filament_sensor_timeout: 120
          gpio_pin: '4'
          index_id: 1
          input_pull_resistor: input_pull_up
          input_type: temperature_sensor
          temp_sensor_address: ''
          temp_sensor_humidity: 68.4
          temp_sensor_i2cbus: 1
          temp_sensor_navbar: true
          temp_sensor_temp: 26.7
          temp_sensor_type: '2302'
          use_fahrenheit: false

  stream:
    device: /dev/video0
    port: {{ static.proxy_ports.octoprint_video }}
    resolution: 1280x720

proxy_vhosts:
  octoprint:
    domain: octoprint-dev.local.pws
    port: {{ static.proxy_ports.octoprint_http }}
    ssl: internal
    ssl_name: local
    ssl_force: False
    custom_config: |
        location ~ ^/video/(.*)$ {
            postpone_output 0;
            proxy_buffering off;
            proxy_ignore_headers X-Accel-Buffering;
            proxy_pass http://127.0.0.1:{{ static.proxy_ports.octoprint_video }}/$1$is_args$args;
        }
