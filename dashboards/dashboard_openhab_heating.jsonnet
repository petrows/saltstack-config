local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local gaugePanel = grafana.gaugePanel;
local influxdb = grafana.influxdb;
local template = grafana.template;

local openhab = import 'openhab.jsonnet';

# Heating status

dashboard.new(
    'Heating',
    uid='openhab_heating',
    tags=['openhab'],
    editable=true,
    time_from='now-24h',
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
    gaugePanel.new(
      'Setting',
      datasource='openhab_home',
      allValues=true,
      unit='°C',
      min=5,
      max=35,
      showThresholdMarkers=true,
    )
    .addTargets(
      [
        influxdb.target(
          measurement='%(id)s_heating_thermostat' % item,
          alias='%(title)s' % item.title,
          rawQuery=true,
          query='SELECT last("value") FROM "%(id)s_heating_thermostat" ORDER BY time DESC LIMIT 1 SLIMIT 1' % item,
        )
        .selectField('value').addConverter('last')
        for item in openhab.rooms
      ],
    )
    .addThreshold({ color: 'green', value: 5 })
    .addThreshold({ color: 'yellow', value: 20 })
    .addThreshold({ color: 'red', value: 25 })
  )
  .addPanel(
    gaugePanel.new(
      'Valve',
      datasource='openhab_home',
      allValues=true,
    )
    .addTargets(
      [
        influxdb.target(
          measurement='%(id)s_heating_position' % item,
          alias='%(title)s' % item.title,
          rawQuery=true,
          query='SELECT last("value") FROM "%(id)s_heating_position" ORDER BY time DESC LIMIT 1 SLIMIT 1' % item,
        )
        .selectField('value').addConverter('last')
        for item in openhab.rooms
      ],
    )
    .addThreshold({ color: 'green', value: 0 })
    .addThreshold({ color: 'yellow', value: 33 })
    .addThreshold({ color: 'red', value: 66 })
  )
)
.addRow(
  row.new()
  .addPanel(
    graphPanel.new(
      'Temperature',
      span=12,
      datasource='openhab_home',
      legend_current=true,
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
      legend_current=true,
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
      legend_current=true,
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
