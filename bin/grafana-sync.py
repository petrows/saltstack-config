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
    '--ca-bundle',
    type=str,
    action='store',
    default=os.getenv('REQUESTS_CA_BUNDLE', ''),
    help='Path to custom CA bundle (overrides REQUESTS_CA_BUNDLE if set)',
)

parser.add_argument(
    '--insecure',
    action='store_true',
    help='Disable TLS certificate verification (not recommended)',
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

def build_session(base_url, token, ca_bundle=None, insecure=False):
    parsed = urlparse(base_url)
    auth = None
    if parsed.username or parsed.password:
        auth = (parsed.username, parsed.password or '')
        netloc = parsed.hostname or ''
        if parsed.port:
            netloc = f"{netloc}:{parsed.port}"
        base_url = parsed._replace(netloc=netloc).geturl()

    session = requests.Session()
    if token:
        session.headers.update({'Authorization': f'Bearer {token}'})
    if auth:
        session.auth = auth
    verify = None
    if insecure:
        verify = False
    elif ca_bundle:
        verify = ca_bundle
    if verify is not None:
        session.verify = verify

    return session, base_url, verify


def request_with_verify(session, method, url, verify=None, **kwargs):
    if verify is None:
        return session.request(method, url, **kwargs)
    return session.request(method, url, verify=verify, **kwargs)


def ensure_folder_id(session, base_url, folder_title, verify=None):
    if not folder_title:
        return 0

    api_url = urljoin(base_url, 'api/folders')
    response = request_with_verify(session, 'GET', api_url, verify=verify)
    response.raise_for_status()
    for folder in response.json():
        if folder.get('title') == folder_title:
            return folder.get('id', 0)

    create_url = urljoin(base_url, 'api/folders')
    response = request_with_verify(session, 'POST', create_url, verify=verify, json={'title': folder_title})
    response.raise_for_status()
    return response.json().get('id', 0)


def load_dashboard_from_file(dashboard_folder, dashboard_uid):
    candidates = [
        f"dashboards/{dashboard_folder}/{dashboard_uid}.json",
        f"dashboards/{dashboard_folder}/{dashboard_uid}.yaml",
    ]

    for path in candidates:
        if os.path.isfile(path):
            with open(path, mode='r', encoding='utf-8') as handle:
                if path.endswith('.json'):
                    return json.load(handle), path
                return yaml.safe_load(handle), path

    return None, None

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


ca_bundle = args.ca_bundle.strip() if args.ca_bundle else ''
session, base_url, verify = build_session(args.url, args.token, ca_bundle=ca_bundle or None, insecure=args.insecure)


for dashboard_uri in args.dashboards:
    (dashboard_folder, dashboard_uid) = dashboard_uri.split('/')

    if args.operation == 'download':
        logging.info("Downloading dashboard %s, folder %s", dashboard_uid, dashboard_folder)

        api_url = urljoin(base_url, f'api/dashboards/uid/{dashboard_uid}')
        response = request_with_verify(session, 'GET', api_url, verify=verify)
        response.raise_for_status()

        dashboard_json = response.json()['dashboard']

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
        if folder == 'vm':
            folder = ''

        out_file = f"dashboards/{dashboard_folder}/{dashboard_uid}.json"

        with open(out_file, mode="w", encoding="utf-8") as f:
            f.write(dashboard_json)
            logging.info("Wrote: %s", out_file)

    if args.operation == 'upload':
        dashboard_data, source_path = load_dashboard_from_file(dashboard_folder, dashboard_uid)
        if dashboard_data is None:
            logging.error("Missing dashboard file for %s/%s", dashboard_folder, dashboard_uid)
            continue

        dashboard_data['uid'] = dashboard_uid
        folder = dashboard_folder
        if folder == 'vm':
            folder = ''

        folder_id = ensure_folder_id(session, base_url, folder, verify=verify)
        payload = {
            'dashboard': dashboard_data,
            'folderId': folder_id,
            'overwrite': True,
        }

        api_url = urljoin(base_url, 'api/dashboards/db')
        response = request_with_verify(session, 'POST', api_url, verify=verify, json=payload)
        response.raise_for_status()
        logging.info("Uploaded: %s", source_path)


