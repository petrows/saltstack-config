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
    'Climate',
    uid='openhab_climate',
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
      'Humidity',
      span=12,
      datasource='openhab_home',
      format='%',
      legend_current=true,
    )
    .addTargets(
        [
            influxdb.target(
                measurement='%(id)s_climate_humidity' % item,
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
      'Climate',
      span=12,
      datasource='openhab_home',
      format='°C',
      #label='Temperature',
      #formatY2='%',
      #labelY2='Humidity',
      aliasColors={
        'Temperature': 'light-red',
        'Humidity': 'light-blue',
      },
    )
    .addTarget(
        influxdb.target(
            measurement='ext_climate_temperature',
            alias='Temperature',
        )
        .selectField('value').addConverter('mean')
    )
    .addYaxis(
        format='%',
    )
    .addTarget(
        influxdb.target(
            measurement='ext_climate_humidity',
            alias='Humidity',
        )
        .selectField('value').addConverter('mean')
    )
  )
)

# Climate

