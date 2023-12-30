#!/usr/bin/env python3

import logging
import os
import re
import smtplib
import sys
from email.message import EmailMessage
from pprint import pprint

import docker
import objectpath
import yaml
from packaging import version

logging.basicConfig(level=logging.INFO)

mailto = 'root@localhost'

config = []

config.append({
    "id": "openhab",
    "current": {
        "mode": "pillar",
        "pillar": {
            "file": "saltstack/pillar/services/openhab.sls",
            "attr": "$.openhab.version",
        },
    },
    "discovery": {
        "mode": "docker",
        "docker": {
            "image": "openhab/openhab:latest",
            "attr": '$.Config.Labels."org.opencontainers.image.version"',
        },
    },
})

# config.append({
#     "id": "zigbee2mqtt",
#     "current": {
#         "mode": "pillar",
#         "pillar": {
#             "file": "saltstack/pillar/services/openhab.sls",
#             "attr": "$.openhab.zigbee2mqtt.version",
#         },
#     },
#     "discovery": {
#         "mode": "docker",
#         "docker": {
#             "image": "koenkk/zigbee2mqtt:latest",
#             "exec": ['npm', 'version'],
#         },
#         "regexp": 'zigbee2mqtt: \'(.*?)\''
#     },
# })

# config.append({
#     "id": "plex",
#     "current": {
#         "mode": "pillar",
#         "pillar": {
#             "file": "saltstack/pillar/services/plex.sls",
#             "attr": "$.plex.version",
#         },
#         "regexp": '(.*?)-'
#     },
#     "discovery": {
#         "mode": "docker",
#         "docker": {
#             "image": "linuxserver/plex:latest",
#             "attr": '$.Config.Labels."build_version"',
#         },
#         "regexp": 'Linuxserver.io version:- (.*?)-'
#     },
# })

updates = []

for service in config:
    logging.info(f"Starting check of service '{service['id']}'")
    version_current = None

    # Fetch current version
    service_config = service['current']

    if service_config['mode'] == "pillar":
        yaml_f = open(service_config['pillar']['file']).read()
        yaml_f = re.sub('\\{%.*%\\}', '', yaml_f, flags=re.M)
        yaml_f = re.sub('\\{\\{.*\\}\\}', '\'\'', yaml_f, flags=re.M)
        yaml_data = yaml.load(yaml_f, Loader=yaml.FullLoader)
        attrs = objectpath.Tree(yaml_data)
        version_current = attrs.execute(service_config['pillar']['attr'])

    if not version_current:
        logging.error("Failed to obtain existing service version")
        sys.exit(88)

    if 'regexp' in service_config:
        version_current = re.search(
            service_config['regexp'], version_current).group(1)

    logging.info(f"{service['id']}: current version found: {version_current}")

    version_new = None
    service_discovery = service['discovery']

    if service_discovery['mode'] == "docker":
        client = docker.from_env()
        client.images.pull(service_discovery['docker']['image'])
        image = client.images.get(service_discovery['docker']['image'])

        if 'attr' in service_discovery['docker']:
            attrs = objectpath.Tree(image.attrs)
            version_new = attrs.execute(service_discovery['docker']['attr'])

        if 'exec' in service_discovery['docker']:
            version_new = client.containers.run(service_discovery['docker']['image'],
                                                remove=True,
                                                command=service_discovery['docker']['exec'])
            version_new = version_new.decode("utf-8")

    if not version_new:
        logging.error("Failed to obtain new service version")
        sys.exit(89)

    if 'regexp' in service_discovery:
        version_new = re.search(
            service_discovery['regexp'], version_new).group(1)

    logging.info(f"{service['id']}: new version found: {version_new}")

    if version.parse(version_current) < version.parse(version_new):
        logging.warning(
            f"{service['id']}: New version detected: {version_current} -> {version_new}")
        updates.append({
            "id": service['id'],
            "version_old": version_current,
            "version_new": version_new,
        })
    else:
        logging.info(
            f"{service['id']}: No new version detected: {version_current} == {version_new}")

if updates:
    logging.info(f"There are {len(updates)} updates found, send email")
    mail_message = []
    mail_message.append(f"New service updates: {len(updates)}")
    mail_message.append("")
    for update in updates:
        mail_message.append(f"Service: {update['id']}")
        mail_message.append(f"  Current version: {update['version_old']}")
        mail_message.append(f"  Updated version: {update['version_new']}")
        mail_message.append("")

    mail_message = '\n'.join(mail_message)

    print(mail_message)

    msg = EmailMessage()
    msg['Subject'] = f"New service updates: {len(updates)}"
    msg['To'] = mailto
    msg['From'] = mailto
    msg.set_content(mail_message)

    # Send the message via our own SMTP server.
    s = smtplib.SMTP('localhost')
    s.send_message(msg)
    s.quit()
else:
    logging.info(f"All services are up-to-date")

# Cleanup
os.system('docker system prune -af')
