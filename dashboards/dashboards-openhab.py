#!/usr/bin/env python3

from openhab import OpenHAB
from pprint import pprint
from gen_dashboards import common

import grafanalib.core as grafana
from grafanalib.influxdb import InfluxDBTarget

base_url = 'https://home.pws/rest'
openhab = OpenHAB(base_url)

# What rooms we have (for common loops)
rooms = [
    {'id': 'kg', 'title': 'KG'},
    {'id': 'sz', 'title': 'SZ'},
    {'id': 'ku', 'title': 'KU'},
    {'id': 'ns', 'title': 'NS'},
    {'id': 'fs', 'title': 'FS'},
]

# Function to get single item_id, label
def get_item(name: str):
    try:
        d = openhab.get_item_raw(name)
    except:
        return None, None
    return d['name'], d['label']

# Function to get item_id: label dict
def group_items(name: str):
    out = {}
    items = openhab.get_item(name)
    item_ids = []
    for v in items.members.values():
        item_ids.append(v.name)
    item_ids.sort()
    for item in item_ids:
        item_id, item_name = get_item(item)
        out[item_id] = item_name
    return out


# Return item's graph
def item_graph(item: str, name=None, fill='previous'):
    item_id, item_name = get_item(item)
    if not name:
        name = item_name
    targets = []
    if item_id:
        targets.append(
            InfluxDBTarget(
                query=f'SELECT mean("value") FROM "{item_id}" WHERE $timeFilter GROUP BY time($__interval) fill({fill})',
                alias=name,
            )
        )
    return targets

# Return item's last value
def item_last(item: str, name=None):
    item_id, item_name = get_item(item)
    if not name:
        name = item_name
    targets = []
    if item_id:
        targets.append(
            InfluxDBTarget(
                query=f'SELECT last("value") FROM "{item_id}" ORDER BY time DESC LIMIT 1 SLIMIT 1',
                alias=name,
            )
        )
    return targets

# Return set of Targets to display time-based graph for items group
def group_graph(items, fill='previous', function='mean'):
    devices = group_items(items)
    targets = []
    for k, v in devices.items():
        targets.append(
            InfluxDBTarget(
                query=f'SELECT {function}("value") FROM "{k}" WHERE $timeFilter GROUP BY time($__interval) fill({fill})',
                alias=v,
            )
        )
    return targets

# Return last values for all group items
def group_status(items):
    devices = group_items(items)
    targets = []
    for k, v in devices.items():
        targets.append(
            InfluxDBTarget(
                query=f'SELECT last("value") FROM "{k}" ORDER BY time DESC LIMIT 1 SLIMIT 1',
                alias=v,
            )
        )
    return targets

# Climate

rooms_temperature = []
rooms_humidity = []
rooms_pressure = []
for room in rooms:
    room_id = room['id']
    room_title = room['title']
    rooms_temperature += item_graph(f"{room_id}_climate_temperature", name=room_title)
    rooms_humidity += item_graph(f"{room_id}_climate_humidity", name=room_title)
    rooms_pressure += item_graph(f"{room_id}_climate_pressure", name=room_title)

dashboard = grafana.Dashboard(
    title="Climate",
    uid='openhab_climate',
    tags=['openhab'],
    timezone=common.GRAFANA_TIMEZONE,
    time=common.GRAFANA_TIME,
    rows=[
        grafana.Row(panels=[
            grafana.Graph(
                title="Temperature",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='°C'),
                targets=rooms_temperature,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Humidity",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='%'),
                targets=rooms_humidity,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Climate",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.YAxes(
                    left=grafana.YAxis(min=None, format='°C'),
                    right=grafana.YAxis(min=None, format='%'),
                ),
                targets=
                    item_graph('ext_climate_temperature', name='Temperature') +
                    item_graph('ext_climate_humidity', name='Humidity'),
                # Force graph's colors and Y-Axis
                seriesOverrides = [
                    {
                        'alias': "Temperature",
                        'color': '#bf1b00',
                        'yaxis': 1,
                    },
                    {
                        'alias': "Humidity",
                        'color': '#65c5db',
                        'yaxis': 2,
                    },
                ],
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="CO2",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.YAxes(
                    left=grafana.YAxis(min=None, format='ppm'),
                ),
                targets=item_graph('sz_co2', name='SZ'),
                # Force graph's colors and Y-Axis
                seriesOverrides = [
                    {
                        'alias': "PPM",
                        'color': '#bf1b00',
                        'yaxis': 1,
                    }
                ],
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Pressure",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='hPa'),
                targets=rooms_pressure,
            ),
            grafana.Graph(
                title="Wind & Rain",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.YAxes(
                    left=grafana.YAxis(min=None, format='mm/h'),
                    right=grafana.YAxis(min=None, format='m/s'),
                ),
                targets=
                    item_graph('weather_ext_precip_intensity', name='Rain') +
                    item_graph('weather_ext_wind_speed', name='Wind'),
                # Force graph's colors and Y-Axis
                seriesOverrides = [
                    {
                        'alias': "Rain",
                        'color': '#65c5db',
                        'yaxis': 1,
                    },
                    {
                        'alias': "Wind",
                        'color': 'white',
                        'yaxis': 2,
                    },
                ],
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Air Quality",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None),
                targets=item_graph('Aqi_Level', name='Quality'),
            ),
            grafana.Graph(
                title="Radiation level",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='µSv/h', decimals=3),
                targets=item_graph('weather_radiation', name='Radiation'),
            ),
        ]),
    ],
).auto_panel_ids()

common.upload_to_grafana(dashboard)

# Battery status and info

dashboard = grafana.Dashboard(
    title="Battery status",
    uid='openhab_batt',
    tags=['openhab'],
    timezone=common.GRAFANA_TIMEZONE,
    time=common.GRAFANA_TIME,
    rows=[
        grafana.Row(panels=[
            grafana.GaugePanel(
                title="Battery levels status",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                targets=group_status('g_battery_level'),
                format='%',
                thresholds=[
                    {'color': 'red', 'value': 0},
                    {'color': 'yellow', 'value': 20},
                    {'color': 'green', 'value': 40},
                ],
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Battery levels",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                targets=group_graph('g_battery_level', fill='none'),
                fill=False,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='%'),
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Battery voltage",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                targets=group_graph('g_battery_voltage', fill='none'),
                fill=False,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='V'),
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Battery low signal",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                targets=group_graph('g_battery_low', fill='none', function='last'),
                fill=False,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=0, max=1),
            ),
        ]),
    ],
).auto_panel_ids()

common.upload_to_grafana(dashboard)

# Heating

rooms_temperature_current = []
rooms_thermostat_current = []
rooms_valve_current = []
rooms_thermostat = []
rooms_valve = []
for room in rooms:
    room_id = room['id']
    room_title = room['title']
    rooms_temperature_current += item_last(f"{room_id}_climate_temperature", name=room_title)
    rooms_thermostat_current  += item_last(f"{room_id}_heating_thermostat", name=room_title)
    rooms_valve_current       += item_last(f"{room_id}_heating_position", name=room_title)
    rooms_thermostat          += item_graph(f"{room_id}_heating_thermostat", name=room_title)
    rooms_valve               += item_graph(f"{room_id}_heating_position", name=room_title)

dashboard = grafana.Dashboard(
    title="Heating",
    uid='openhab_heating',
    tags=['openhab'],
    timezone=common.GRAFANA_TIMEZONE,
    time=common.GRAFANA_TIME,
    rows=[
        grafana.Row(panels=[
            grafana.GaugePanel(
                title="Setting",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                targets=rooms_thermostat_current,
                format='°C',
                min=5,
                max=35,
                thresholds=[
                    {'color': 'blue', 'value': 5},
                    {'color': 'green', 'value': 20},
                    {'color': 'red', 'value': 25},
                ],
            ),
            grafana.GaugePanel(
                title="Valve",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                targets=rooms_valve_current,
                format='%',
                min=0,
                max=100,
                thresholds=[
                    {'color': 'green', 'value': 0},
                    {'color': 'yellow', 'value': 33},
                    {'color': 'red', 'value': 66},
                ],
            ),
            grafana.GaugePanel(
                title="Current temperature",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                targets=rooms_temperature_current,
                format='°C',
                min=5,
                max=35,
                thresholds=[
                    {'color': 'blue', 'value': 5},
                    {'color': 'green', 'value': 20},
                    {'color': 'red', 'value': 25},
                ],
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Temperature",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='°C'),
                targets=rooms_temperature,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Thermostat",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='°C'),
                targets=rooms_thermostat,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Valve",
                dataSource=common.GRAFANA_SOURCE_OPENHAB,
                lineWidth=common.GRAFANA_LINE_WIDTH,
                yAxes=grafana.single_y_axis(min=None, format='%'),
                targets=rooms_valve,
            ),
        ]),
    ],
).auto_panel_ids()

common.upload_to_grafana(dashboard)
