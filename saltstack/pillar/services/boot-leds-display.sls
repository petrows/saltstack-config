roles:
  - boot-leds-display

initramfs-modules:
  leds_input: True

initramfs-scripts:
  luks-led-on: local-top/luks-led-on
  luks-led-off: local-bottom/luks-led-off
