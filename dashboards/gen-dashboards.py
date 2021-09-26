#!/usr/bin/env python3

from openhab import OpenHAB
from pprint import pprint
from gen_dashboards import common

import grafanalib.core as grafana
from grafanalib.influxdb import InfluxDBTarget

base_url = 'https://home.pws/rest'
openhab = OpenHAB(base_url)

# Define some local defaults
GRAFANA_LINE_WIDTH=1
GRAFANA_TIME = grafana.Time('now-24h', 'now'),
GRAFANA_TIMEZONE = 'browser'
GRAFANA_SOURCE = 'openhab_home'
GRAFANA_YAXES_AUTO = grafana.YAxes(left=grafana.YAxis(min=None), right=grafana.YAxis(min=None))

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

# Return set of Targets to display time-based graph for items group
def group_graph(items, fill='previous'):
    devices = group_items(items)
    targets = []
    for k, v in devices.items():
        targets.append(
            InfluxDBTarget(
                query=f'SELECT mean("value") FROM "{k}" WHERE $timeFilter GROUP BY time($__interval) fill({fill})',
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
    timezone="browser",
    time=grafana.Time('now-24h', 'now'),
    rows=[
        grafana.Row(panels=[
            grafana.Graph(
                title="Temperature",
                dataSource=GRAFANA_SOURCE,
                lineWidth=GRAFANA_LINE_WIDTH,
                yAxes=GRAFANA_YAXES_AUTO,
                targets=rooms_temperature,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Humidity",
                dataSource=GRAFANA_SOURCE,
                lineWidth=GRAFANA_LINE_WIDTH,
                yAxes=GRAFANA_YAXES_AUTO,
                targets=rooms_humidity,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Pressure",
                dataSource=GRAFANA_SOURCE,
                lineWidth=GRAFANA_LINE_WIDTH,
                yAxes=GRAFANA_YAXES_AUTO,
                targets=rooms_pressure,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Climate",
                dataSource=GRAFANA_SOURCE,
                lineWidth=GRAFANA_LINE_WIDTH,
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
                        'color': 'red',
                        'yaxis': 1,
                    },
                    {
                        'alias': "Humidity",
                        'color': 'blue',
                        'yaxis': 2,
                    },
                ],
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Wind & Rain",
                dataSource=GRAFANA_SOURCE,
                lineWidth=GRAFANA_LINE_WIDTH,
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
                        'color': 'blue',
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
    ],
).auto_panel_ids()

common.upload_to_grafana(dashboard)

# Battery status and info

dashboard = grafana.Dashboard(
    title="Battery status",
    uid='openhab_batt',
    tags=['openhab'],
    timezone="browser",
    time=grafana.Time('now-24h', 'now'),
    rows=[
        grafana.Row(panels=[
            grafana.GaugePanel(
                title="Battery levels status",
                dataSource='openhab_home',
                targets=group_status('g_battery_level'),
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
                dataSource='openhab_home',
                targets=group_graph('g_battery_level', fill='none'),
                fill=False,
                lineWidth=1,
                yAxes=GRAFANA_YAXES_AUTO,
            ),
        ]),
        grafana.Row(panels=[
            grafana.Graph(
                title="Battery voltage",
                dataSource='openhab_home',
                targets=group_graph('g_battery_voltage', fill='none'),
                fill=False,
                lineWidth=1,
                yAxes=GRAFANA_YAXES_AUTO,
            ),
        ]),
    ],
).auto_panel_ids()

common.upload_to_grafana(dashboard)
