#!/usr/bin/env python3
"""
    Script generates QR codes for all WG clients to given server
"""

import argparse
from pathlib import Path
import ipaddress
import re
import sys
import yaml
import qrcode


def main():
    """
        Entry point
    """

    parser = argparse.ArgumentParser(
        description='Generates QR codes for all WG clients'
    )

    parser.add_argument(
        'server_id',
        help='server ID in secrets pillar: pillar.pws_secrets.wireguard.<NAME>'
    )

    args = parser.parse_args()

    root = Path(__file__).parent.parent.resolve()

    secrets_f = open(root / "secrets/pillar/secrets.sls", "r").read()

    # Remove Jinja comments
    secrets_f = re.sub('\\{#.*#\\}', '', secrets_f, flags=re.DOTALL)

    secrets = yaml.safe_load(secrets_f)
    secrets = secrets['pws_secrets']['wireguard']

    # Check that server is here
    if args.server_id not in secrets:
        print(f"Error: WG server with name {args.server_id} not found")
        sys.exit(1)

    secrets = secrets[args.server_id]

    client_ips = []

    # Print clients
    for client_id, client in secrets['client'].items():
        print(f"{client_id}\t{client['address']}\t{client['public']}")
        if client['address'] in client_ips:
            print(f"ERROR! Duplicating IP address {client['address']}")
            sys.exit(1)
        client_ips.append(client['address'])

    # Iterate clients
    for client_id, client in secrets['client'].items():
        print(f'Client: {client_id}')

        private_key = client.get("private", "< place-your-private-key-here >")
        user_comment = client.get("comment", None)

        client_config = []

        if user_comment:
            comment = user_comment.split('\n')
            for c in comment:
                client_config += [f'# {c}']

        client_config += [f'[Interface]']
        client_config += [f'PrivateKey = {private_key}']
        client_config += [f'Address = {client["address"]}']
        # client_config += [f'ListenPort = 21841']

        # DNS record is set?
        if 'dns' in secrets["server"]:
            # Domain record is set?
            if secrets["server"]["domain"]:
                # We are using resolvectl as DNS backend, resolvconf may break old domains on use
                client_config += [f'PostUp = resolvectl dns %i {secrets["server"]["address"]}; resolvectl domain %i ~' + ' ~'.join(secrets["server"]["domain"])]
            # Just simple DNS server (no domain)
            else:
                client_config += [f'DNS = {secrets["server"]["dns"]}']

        client_config += [f'[Peer]']
        client_config += [f'PublicKey = {secrets["server"]["public"]}']
        client_config += [f'Endpoint = {secrets["server"]["endpoint"]}']
        client_config += [f'AllowedIPs = 0.0.0.0/0']
        client_config = '\n'.join(client_config)

        # Save client config
        f = open(f'{args.server_id}.{client_id}.conf', 'w')
        f.write(client_config)
        f.close()

        # Save QR code - only for clients with knwon private keys!
        if client.get("private", None):
            qr = qrcode.QRCode(
                version=1,
                box_size=10,
                border=5)
            qr.add_data(client_config)
            qr.make(fit=True)
            img = qr.make_image(fill='black', back_color='white')
            img.save(f'{args.server_id}.{client_id}.png')


if __name__ == "__main__":
    main()
