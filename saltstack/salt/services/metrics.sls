{% for dir,uid in {'victoriametrics':1100,'grafana':999,'telegraf':1000}.items() %}
metrics-dir-{{ dir }}:
  file.directory:
    - name: {{ pillar.metrics.data_dir }}/{{ dir }}
    - makedirs: True
    - user: {{ uid }}
    - group: {{ uid }}
    - mode:  755
{% endfor %}

{{ pillar.metrics.data_dir }}/telegraf/telegraf.conf:
  file.managed:
    - watch_in:
      - service: metrics-compose
    - contents: |
        [global_tags]
          user = "telegraf"
        [agent]
          interval = "1m"
           ## Log at debug level.
          debug = true
          ## Log only error level messages.
          quiet = false
        [[inputs.mem]]
        [[outputs.influxdb]]
          urls = ["http://metrics-victoriametrics:8428"]

        [[inputs.snmp]]
        agents = [ "tcp://root.office.pws:161" ] # Replace this with your router(s) IP/port

          # System
          [[inputs.snmp.field]]
            name = "hostname"
            oid = ".1.3.6.1.2.1.1.5.0"
            is_tag = true
          [[inputs.snmp.field]]
            name = "uptime"
            oid = ".1.3.6.1.2.1.1.3.0"
          [[inputs.snmp.field]]
            name = "cpu-frequency"
            oid = ".1.3.6.1.4.1.14988.1.1.3.14.0"
          [[inputs.snmp.field]]
            name = "cpu-load"
            oid = ".1.3.6.1.2.1.25.3.3.1.2.1"
          [[inputs.snmp.field]]
            name = "active-fan"
            oid = ".1.3.6.1.4.1.14988.1.1.3.9.0"
          [[inputs.snmp.field]]
            name = "voltage"
            oid = ".1.3.6.1.4.1.14988.1.1.3.8.0"
          [[inputs.snmp.field]]
            name = "temperature"
            oid = ".1.3.6.1.4.1.14988.1.1.3.10.0"
          [[inputs.snmp.field]]
            name = "processor-temperature"
            oid = ".1.3.6.1.4.1.14988.1.1.3.11.0"
          [[inputs.snmp.field]]
            name = "current"
            oid = ".1.3.6.1.4.1.14988.1.1.3.13.0"
          [[inputs.snmp.field]]
            name = "fan-speed"
            oid = ".1.3.6.1.4.1.14988.1.1.3.17.0"
          [[inputs.snmp.field]]
            name = "fan-speed2"
            oid = ".1.3.6.1.4.1.14988.1.1.3.18.0"
          [[inputs.snmp.field]]
            name = "power-consumption"
            oid = ".1.3.6.1.4.1.14988.1.1.3.12.0"
          [[inputs.snmp.field]]
            name = "psu1-state"
            oid = ".1.3.6.1.4.1.14988.1.1.3.15.0"
          [[inputs.snmp.field]]
            name = "psu2-state"
            oid = ".1.3.6.1.4.1.14988.1.1.3.16.0"

          # Interfaces
          [[inputs.snmp.table]]
            name = "snmp-interfaces"
            inherit_tags = ["hostname"]
            [[inputs.snmp.table.field]]
              name = "if-name"
              oid = ".1.3.6.1.2.1.2.2.1.2"
              is_tag = true
            [[inputs.snmp.table.field]]
              name = "mac-address"
              oid = ".1.3.6.1.2.1.2.2.1.6"
              is_tag = true

            [[inputs.snmp.table.field]]
              name = "actual-mtu"
              oid = ".1.3.6.1.2.1.2.2.1.4"
            [[inputs.snmp.table.field]]
              name = "admin-status"
              oid = ".1.3.6.1.2.1.2.2.1.7"
            [[inputs.snmp.table.field]]
              name = "oper-status"
              oid = ".1.3.6.1.2.1.2.2.1.8"
            [[inputs.snmp.table.field]]
              name = "bytes-in"
              oid = ".1.3.6.1.2.1.31.1.1.1.6"
            [[inputs.snmp.table.field]]
              name = "packets-in"
              oid = ".1.3.6.1.2.1.31.1.1.1.7"
            [[inputs.snmp.table.field]]
              name = "discards-in"
              oid = ".1.3.6.1.2.1.2.2.1.13"
            [[inputs.snmp.table.field]]
              name = "errors-in"
              oid = ".1.3.6.1.2.1.2.2.1.14"
            [[inputs.snmp.table.field]]
              name = "bytes-out"
              oid = ".1.3.6.1.2.1.31.1.1.1.10"
            [[inputs.snmp.table.field]]
              name = "packets-out"
              oid = ".1.3.6.1.2.1.31.1.1.1.11"
            [[inputs.snmp.table.field]]
              name = "discards-out"
              oid = ".1.3.6.1.2.1.2.2.1.19"
            [[inputs.snmp.table.field]]
              name= "errors-out"
              oid= ".1.3.6.1.2.1.2.2.1.20"

          # Memory usage (storage/RAM)
          [[inputs.snmp.table]]
            name = "snmp-memory-usage"
            inherit_tags = ["hostname"]
            [[inputs.snmp.table.field]]
              name = "memory-name"
              oid = ".1.3.6.1.2.1.25.2.3.1.3"
              is_tag = true
            [[inputs.snmp.table.field]]
              name = "total-memory"
              oid = ".1.3.6.1.2.1.25.2.3.1.5"
            [[inputs.snmp.table.field]]
              name = "used-memory"
              oid = ".1.3.6.1.2.1.25.2.3.1.6"

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('metrics') }}
