network:
  netplan:
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth-lan:
          match:
            name: ens*
          set-name: eth-lan
          dhcp4: false
          dhcp6: false
          addresses:
          - 10.82.3.5/24
          routes:
          - to: default
            via: 10.82.3.1
          nameservers:
            addresses:
              - 8.8.8.8
              - 8.8.4.4
