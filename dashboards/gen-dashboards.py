#!/usr/bin/env python3

from openhab import OpenHAB
from pprint import pprint
from gen_dashboards import common

import grafanalib.core as grafana
from grafanalib.influxdb import InfluxDBTarget

base_url = 'https://home.pws/rest'
openhab = OpenHAB(base_url)

# Function to get item_id: label dict
def group_items(name: str):
    out = {}
    items = openhab.get_item(name)
    for v in items.members.values():
        d = openhab.get_item_raw(v.name)
        out[d['name']] = d['label']
    return out


# Return set of Targets to display time-based graph for items group
def group_graph(items, fill='previous'):
    devices = group_items(items)
    targets = []
    for k, v in devices.items():
        print(f"{k} -> {v}")
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
        print(f"{k} -> {v}")
        targets.append(
            InfluxDBTarget(
                query=f'SELECT last("value") FROM "{k}" ORDER BY time DESC LIMIT 1 SLIMIT 1',
                alias=v,
            )
        )
    return targets

# Battery status and info

dashboard = grafana.Dashboard(
    title="Battery status",
    uid='openhab_batt',
    timezone="browser",
    time=grafana.Time('now-24h', 'now'),
    rows=[
        grafana.Row(panels=[
            grafana.GaugePanel(
                title="Battery levels status",
                dataSource='openhab_home',
                targets=group_status('g_battery_level'),
                thresholds=[
                    {'color': 'red', 'value': 20},
                    {'color': 'yellow', 'value': 40},
                    {'color': 'green', 'value': 60},
                ],
            ),
            grafana.Graph(
                title="Battery levels",
                dataSource='openhab_home',
                targets=group_graph('g_battery_level', fill='none'),
                fill=False,
                lineWidth=1,
                yAxes=grafana.single_y_axis(format=grafana.SHORT_FORMAT),
            ),
            grafana.Graph(
                title="Battery voltage",
                dataSource='openhab_home',
                targets=group_graph('g_battery_voltage', fill='none'),
                fill=False,
                lineWidth=1,
                yAxes=grafana.single_y_axis(format=grafana.SHORT_FORMAT),
            ),
        ]),
    ],
).auto_panel_ids()

common.upload_to_grafana(dashboard)
