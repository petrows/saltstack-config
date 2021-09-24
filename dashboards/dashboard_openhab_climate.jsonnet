local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local influxdb = grafana.influxdb;
local template = grafana.template;

local openhab = import 'openhab.jsonnet';

# Climate

dashboard.new(
    'Climate',
    uid='openhab_climate',
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
      'Humidity',
      span=12,
      datasource='openhab_home',
      legend_current=true,
      format='%',
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
      legend_current=true,
      formatY1='°C',
      labelY1='Temperature',
      formatY2='%',
      labelY2='Humidity',
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
    .addTarget(
        influxdb.target(
            measurement='ext_climate_humidity',
            alias='Humidity',
        )
        .selectField('value').addConverter('mean')
    )
    .addSeriesOverride( # Set right y-axis for second taget for grafonnet
      {
        'alias': "Humidity",
        'yaxis': 2,
      }
    )
  )
)
.addRow(
  row.new()
  .addPanel(
    graphPanel.new(
      'Pressure',
      span=12,
      datasource='openhab_home',
      legend_current=true,
      format='hPa',
    )
    .addTargets(
      [
        influxdb.target(
          measurement='%(id)s_climate_pressure' % item,
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
      'Wind & Rain',
      span=12,
      datasource='openhab_home',
      legend_current=true,
      formatY1='mm/h',
      formatY2='m/s',
    )
    .addTarget(
      influxdb.target(
        measurement='weather_ext_precip',
        alias='Rain',
      )
      .selectField('value').addConverter('mean')
    )
    .addTarget(
      influxdb.target(
        measurement='weather_ext_wind_speed',
        alias='Wind',
      )
      .selectField('value').addConverter('mean')
    )
    .addSeriesOverride( # Set right y-axis for second taget for grafonnet
      {
        'alias': "Wind",
        'yaxis': 2,
      }
    )
  )
)
