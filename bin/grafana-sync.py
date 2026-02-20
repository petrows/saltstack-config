#!/bin/env python3

import argparse
import logging
import os
from urllib.parse import urljoin, urlparse
import urllib.request
import yaml
import json
import requests
from jinja2 import Environment, FileSystemLoader

parser = argparse.ArgumentParser(
    description='Export dashboard and add it into Grafana')

parser.add_argument(
    '-l', '--log',
    choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
    default='INFO',
    help='set log level',
)

parser.add_argument(
    '--url',
    type=str,
    action='store',
    default='https://grafana.h.pws/',
    help='Grafana URL, use user:password@hostname to manage auth',
)

parser.add_argument(
    '--token',
    type=str,
    action='store',
    default=os.getenv('GRAFANA_API_TOKEN', ''),
    help='Grafana Token, can be also set using GRAFANA_API_TOKEN environment variable',
)

parser.add_argument(
    'operation',
    choices=['upload', 'download'],
    help='Action to perform: upload to Grafana, or download from Grafana',
)

parser.add_argument(
    'dashboards',
    nargs='+',
    help='List of dashboards to process, in format <folder>/<uid>',
)


args = parser.parse_args()

log_level = args.log
logging.basicConfig(level=log_level)

# Download datasources
api_url = urljoin(args.url, f'api/datasources')
ds_json = json.loads(requests.get(api_url).content)

def update_ds(obj):
    if isinstance(obj, (dict)):

        if 'datasource' in obj:
            obj['datasource'] = {}

        for k,v in obj.items():
            #print(f'{k} == {v}')
            obj[k] = update_ds(v)

    if isinstance(obj, (list)):
        for k,v in enumerate(obj):
            #print(f'{k} == {v}')
            obj[k] = update_ds(v)

    return obj


for dashboard_uri in args.dashboards:
    (dashboard_folder, dashboard_uid) = dashboard_uri.split('/')
    logging.info("Downloading dashboard %s, folder %s", dashboard_uid, dashboard_folder)

    api_url = urljoin(args.url, f'api/dashboards/uid/{dashboard_uid}')

    dashboard_json = json.loads(requests.get(api_url).content)
    dashboard_json = dashboard_json['dashboard']

    # Perform actions:

    # Lock ediable (notify changed)
    dashboard_json['editable'] = False

    # Update version
    dashboard_json['version'] = int(dashboard_json['version']) + 1
    # Drop timezone
    dashboard_json['timezone'] = 'browser'
    # Drop UID
    dashboard_json['uid'] = dashboard_uid

    # Update DataSource links
    dashboard_json = update_ds(dashboard_json)

    dashboard_json = json.dumps(dashboard_json, indent=4)
    folder = dashboard_folder
    # Drop folder, if matches existing namespace
    if folder == 'vm': folder = ''

    out_file = f"dashboards/{dashboard_folder}/{dashboard_uid}.yaml"

    with open(out_file, mode="w", encoding="utf-8") as f:
        f.write(dashboard_json)
        logging.info("Wrote: %s", out_file)


