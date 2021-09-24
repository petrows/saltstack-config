local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local influxdb = grafana.influxdb;
local template = grafana.template;

local openhab = import 'openhab.jsonnet';

# Heating status

dashboard.new(
    'Heating',
    uid='openhab_heating',
    tags=['openhab'],
    editable=true,
)
.addTemplate(
  grafana.template.datasource(
    'OPENHAB',
    'influxdb',
    'openhab_home',
    hide='label',
  )
)
.addRow(
  row.new()
  .addPanel(
    graphPanel.new(
      'Temperature',
      span=12,
      datasource='openhab_home',
      format='°C',
    )
    .addTargets(
        [
            influxdb.target(
                measurement='%(id)s_climate_temperature' % item,
                alias='%(title)s' % item.title,
            )
            .selectField('value').addConverter('mean')
            for item in openhab.rooms
        ],
    )
  )
)
.addRow(
  row.new()
  .addPanel(
    graphPanel.new(
      'Thermostat',
      span=12,
      datasource='openhab_home',
      format='°C',
    )
    .addTargets(
        [
            influxdb.target(
                measurement='%(id)s_heating_thermostat' % item,
                alias='%(title)s' % item.title,
                fill='previous',
            )
            .selectField('value').addConverter('mean')
            for item in openhab.rooms
        ],
    )
  )
)
.addRow(
  row.new()
  .addPanel(
    graphPanel.new(
      'Valve',
      span=12,
      datasource='openhab_home',
      format='%',
    )
    .addTargets(
        [
            influxdb.target(
                measurement='%(id)s_heating_position' % item,
                alias='%(title)s' % item.title,
                fill='previous',
            )
            .selectField('value').addConverter('mean')
            for item in openhab.rooms
        ],
    )
  )
)

# Climate

