#!/usr/bin/env python-app
"""
Parse Amnezia WireGuard (awg-dump) output.

The awg-dump command outputs interface and peer information in tab-separated format:
- Interface line (WG): interface_name private_key public_key listen_port fwmark (5 fields)
- Interface line (AWG): interface_name private_key public_key listen_port Jc Jmin Jmax S1 S2 S3 S4
                        H1 H2 H3 H4 i1 i2 i3 i4 i5 fwmark (21 fields)
- Peer lines: interface_name public_key preshared_key endpoint allowed_ips
              latest_handshake transfer_rx transfer_tx persistent_keepalive (9 fields)
              (AWG peers use standard WireGuard format without obfuscation parameters)

Usage:
    awg-dump | ./awg-dump.py
    ./awg-dump.py < dump.txt
    ./awg-dump.py --file dump.txt
    ./awg-dump.py --json
    ./awg-dump.py --daemon --interval 15 --metrics-file /var/lib/node_exporter/textfile_collector/awg.prom
"""

import argparse
import json
import os
import shlex
import subprocess
import sys
import tempfile
import time
import systemd.daemon
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from typing import List, Dict, Optional

info_data = {}

@dataclass
class AWGPeer:
    """Represents an AmneziaWG peer (uses standard WireGuard format)"""
    public_key: str
    preshared_key: Optional[str]
    endpoint: Optional[str]
    allowed_ips: List[str]
    latest_handshake: Optional[datetime]
    transfer_rx: int
    transfer_tx: int
    persistent_keepalive: Optional[int]

    def to_dict(self):
        """Convert to dictionary with ISO format datetime"""
        d = asdict(self)
        if self.latest_handshake:
            d['latest_handshake'] = self.latest_handshake.isoformat()
        return d


@dataclass
class AWGInterface:
    """Represents an AmneziaWG interface"""
    name: str
    private_key: str
    public_key: str
    listen_port: Optional[int]
    fwmark: Optional[int]
    peers: List[AWGPeer]
    # AWG obfuscation parameters
    jc: Optional[int] = None  # junk_packet_count
    jmin: Optional[int] = None  # junk_packet_min_size
    jmax: Optional[int] = None  # junk_packet_max_size
    s1: Optional[int] = None  # init_packet_junk_size
    s2: Optional[int] = None  # response_packet_junk_size
    s3: Optional[int] = None  # cookie_reply_packet_junk_size
    s4: Optional[int] = None  # transport_packet_junk_size
    h1: Optional[str] = None  # init_packet_magic_header
    h2: Optional[str] = None  # response_packet_magic_header
    h3: Optional[str] = None  # underload_packet_magic_header
    h4: Optional[str] = None  # transport_packet_magic_header
    i1: Optional[str] = None
    i2: Optional[str] = None
    i3: Optional[str] = None
    i4: Optional[str] = None
    i5: Optional[str] = None

    def to_dict(self):
        """Convert to dictionary"""
        d = asdict(self)
        d['peers'] = [peer.to_dict() for peer in self.peers]
        return d


class AWGDumpParser:
    """Parser for awg-dump output"""

    def __init__(self):
        self.interfaces: Dict[str, AWGInterface] = {}

    def parse_line(self, line: str):
        """Parse a single line from awg-dump output"""
        if not line.strip():
            return

        fields = line.strip().split('\t')

        if len(fields) < 5:
            return

        # Check if this is an interface or peer line
        # Interface line: 5 fields (WG) or 21 fields (AWG)
        # Peer line: 9 fields (both WG and AWG use same format)
        if len(fields) == 5 or len(fields) == 21:
            self._parse_interface(fields)
        elif len(fields) == 9:
            self._parse_peer(fields)

    def _parse_interface(self, fields: List[str]):
        """Parse interface line"""
        interface_name = fields[0]
        private_key = fields[1] if fields[1] != '(none)' else None
        public_key = fields[2] if fields[2] != '(none)' else None

        # Parse AWG obfuscation parameters if present (21 fields total)
        jc = jmin = jmax = s1 = s2 = s3 = s4 = None
        h1 = h2 = h3 = h4 = None
        i1 = i2 = i3 = i4 = i5 = None
        listen_port = fwmark = None



        if len(fields) == 21:
            # AWG format: name private public port jc jmin jmax s1 s2 s3 s4 h1 h2 h3 h4 i1 i2 i3 i4 i5 fwmark
            listen_port = int(fields[3]) if fields[3] != 'off' and fields[3].isdigit() else None
            jc = int(fields[4]) if fields[4] != 'off' and fields[4].isdigit() else None
            jmin = int(fields[5]) if fields[5] != 'off' and fields[5].isdigit() else None
            jmax = int(fields[6]) if fields[6] != 'off' and fields[6].isdigit() else None
            s1 = int(fields[7]) if fields[7] != 'off' and fields[7].isdigit() else None
            s2 = int(fields[8]) if fields[8] != 'off' and fields[8].isdigit() else None
            s3 = int(fields[9]) if fields[9] != 'off' and fields[9].isdigit() else None
            s4 = int(fields[10]) if fields[10] != 'off' and fields[10].isdigit() else None
            h1 = fields[11] if fields[11] not in ['(null)', 'off', ''] else None
            h2 = fields[12] if fields[12] not in ['(null)', 'off', ''] else None
            h3 = fields[13] if fields[13] not in ['(null)', 'off', ''] else None
            h4 = fields[14] if fields[14] not in ['(null)', 'off', ''] else None
            i1 = fields[15] if fields[15] not in ['(null)', 'off', ''] else None
            i2 = fields[16] if fields[16] not in ['(null)', 'off', ''] else None
            i3 = fields[17] if fields[17] not in ['(null)', 'off', ''] else None
            i4 = fields[18] if fields[18] not in ['(null)', 'off', ''] else None
            i5 = fields[19] if fields[19] not in ['(null)', 'off', ''] else None
            fwmark = int(fields[20], 16) if fields[20] != 'off' else None
        else:
            # Standard WG format: name private public port fwmark
            listen_port = int(fields[3]) if fields[3] != 'off' else None
            fwmark = int(fields[4], 16) if fields[4] != 'off' else None

        self.interfaces[interface_name] = AWGInterface(
            name=interface_name,
            private_key=private_key,
            public_key=public_key,
            listen_port=listen_port,
            fwmark=fwmark,
            peers=[],
            jc=jc, jmin=jmin, jmax=jmax,
            s1=s1, s2=s2, s3=s3, s4=s4,
            h1=h1, h2=h2, h3=h3, h4=h4,
            i1=i1, i2=i2, i3=i3, i4=i4, i5=i5
        )

    def _parse_peer(self, fields: List[str]):
        """Parse peer line (standard WireGuard format for both WG and AWG)"""
        interface_name = fields[0]
        public_key = fields[1]
        preshared_key = fields[2] if fields[2] != '(none)' else None
        endpoint = fields[3] if fields[3] != '(none)' else None
        allowed_ips = fields[4].split(',') if fields[4] != '(none)' else []

        # Parse timestamp (seconds since epoch)
        latest_handshake = None
        if fields[5] != '0':
            latest_handshake = datetime.fromtimestamp(int(fields[5]))

        transfer_rx = int(fields[6])
        transfer_tx = int(fields[7])

        persistent_keepalive = None
        if fields[8] != 'off':
            persistent_keepalive = int(fields[8])

        peer = AWGPeer(
            public_key=public_key,
            preshared_key=preshared_key,
            endpoint=endpoint,
            allowed_ips=allowed_ips,
            latest_handshake=latest_handshake,
            transfer_rx=transfer_rx,
            transfer_tx=transfer_tx,
            persistent_keepalive=persistent_keepalive
        )

        if interface_name in self.interfaces:
            self.interfaces[interface_name].peers.append(peer)

    def parse(self, data: str):
        """Parse entire dump output"""
        for line in data.split('\n'):
            self.parse_line(line)

    def to_dict(self):
        """Convert all interfaces to dictionary"""
        return {
            name: iface.to_dict()
            for name, iface in self.interfaces.items()
        }


def format_bytes(bytes_val: int) -> str:
    """Format bytes to human-readable string"""
    for unit in ['B', 'KiB', 'MiB', 'GiB', 'TiB']:
        if bytes_val < 1024.0:
            return f"{bytes_val:.2f} {unit}"
        bytes_val /= 1024.0
    return f"{bytes_val:.2f} PiB"


def format_timedelta(td: timedelta) -> str:
    """Format timedelta to human-readable string"""
    seconds = int(td.total_seconds())
    if seconds < 60:
        return f"{seconds} seconds ago"
    elif seconds < 3600:
        return f"{seconds // 60} minutes ago"
    elif seconds < 86400:
        return f"{seconds // 3600} hours ago"
    else:
        return f"{seconds // 86400} days ago"


def print_human_readable(interfaces: Dict[str, AWGInterface]):
    """Print interfaces in human-readable format"""
    for iface_name, iface in interfaces.items():
        print(f"Interface: {iface.name}")
        if iface.public_key:
            print(f"  Public key: {iface.public_key}")
        if iface.listen_port:
            print(f"  Listening port: {iface.listen_port}")
        if iface.fwmark:
            print(f"  fwmark: 0x{iface.fwmark:x}")

        # Print AWG obfuscation parameters if present
        if iface.jc is not None:
            print(f"  AWG Junk Packets:")
            print(f"    Jc (count): {iface.jc}")
            print(f"    Jmin (min size): {iface.jmin}")
            print(f"    Jmax (max size): {iface.jmax}")
        if iface.s1 is not None:
            print(f"  AWG Packet Junk Sizes:")
            print(f"    S1 (init): {iface.s1}")
            print(f"    S2 (response): {iface.s2}")
            print(f"    S3 (cookie reply): {iface.s3}")
            print(f"    S4 (transport): {iface.s4}")
        if iface.h1 is not None:
            print(f"  AWG Magic Headers:")
            print(f"    H1 (init): {iface.h1}")
            print(f"    H2 (response): {iface.h2}")
            print(f"    H3 (underload): {iface.h3}")
            print(f"    H4 (transport): {iface.h4}")
        if iface.i1 is not None:
            print("  AWG Additional Parameters:")
            print(f"    i1: {iface.i1}")
            if iface.i2:
                print(f"    i2: {iface.i2}")
            if iface.i3:
                print(f"    i3: {iface.i3}")
            if iface.i4:
                print(f"    i4: {iface.i4}")
            if iface.i5:
                print(f"    i5: {iface.i5}")

        if not iface.peers:
            print("  No peers configured")
        else:
            print(f"  Peers: {len(iface.peers)}")

        for i, peer in enumerate(iface.peers, 1):
            print(f"\n  Peer #{i}:")
            print(f"    Public key: {peer.public_key}")

            if peer.preshared_key:
                print("    Preshared key: (hidden)")

            if peer.endpoint:
                print(f"    Endpoint: {peer.endpoint}")

            if peer.allowed_ips:
                print(f"    Allowed IPs: {', '.join(peer.allowed_ips)}")

            if peer.latest_handshake:
                time_ago = datetime.now() - peer.latest_handshake
                print(f"    Latest handshake: {format_timedelta(time_ago)}")
            else:
                print("    Latest handshake: Never")

            print(
                f"    Transfer: {format_bytes(peer.transfer_rx)} received, "
                f"{format_bytes(peer.transfer_tx)} sent"
            )

            if peer.persistent_keepalive:
                print(
                    "    Persistent keepalive: "
                    f"every {peer.persistent_keepalive} seconds"
                )

        print()


def _escape_label_value(value: str) -> str:
    return value.replace('\\', '\\\\').replace('\n', '\\n').replace('"', '\\"')


def _metric_line(name: str, value: int, labels: Dict[str, str]) -> str:
    if labels:
        label_str = ",".join(
            f"{k}=\"{_escape_label_value(v)}\"" for k, v in sorted(labels.items())
        )
        return f"{name}{{{label_str}}} {value}\n"
    return f"{name} {value}\n"


def build_prometheus_metrics(interfaces: Dict[str, AWGInterface]) -> str:
    lines = []
    lines.append("# HELP wg_peer_transfer_rx_bytes Received bytes per peer.\n")
    lines.append("# TYPE wg_peer_transfer_rx_bytes counter\n")
    lines.append("# HELP wg_peer_transfer_tx_bytes Sent bytes per peer.\n")
    lines.append("# TYPE wg_peer_transfer_tx_bytes counter\n")
    lines.append("# HELP wg_peer_latest_handshake_timestamp Unix timestamp of last handshake.\n")
    lines.append("# TYPE wg_peer_latest_handshake_timestamp gauge\n")
    lines.append("# HELP wg_peer_persistent_keepalive_seconds Peer keepalive interval.\n")
    lines.append("# TYPE wg_peer_persistent_keepalive_seconds gauge\n")
    lines.append("# HELP wg_interface_listen_port Interface listen port.\n")
    lines.append("# TYPE wg_interface_listen_port gauge\n")
    lines.append("# HELP wg_interface_fwmark Interface fwmark (hex as int).\n")
    lines.append("# TYPE wg_interface_fwmark gauge\n")
    lines.append("# HELP wg_interface_jc Junk packet count.\n")
    lines.append("# TYPE wg_interface_jc gauge\n")

    for iface_name, iface in sorted(interfaces.items()):
        iface_labels = {"interface": iface_name}
        if iface.listen_port is not None:
            lines.append(_metric_line("wg_interface_listen_port", iface.listen_port, iface_labels))
        if iface.fwmark is not None:
            lines.append(_metric_line("wg_interface_fwmark", iface.fwmark, iface_labels))
        if iface.jc is not None:
            lines.append(_metric_line("wg_interface_jc", iface.jc, iface_labels))

        for peer in iface.peers:
            peer_info = get_peer_name(iface_name, peer.public_key)
            peer_labels = {"interface": iface_name, "name": peer_info['name'], "comment": peer_info['comment']}
            lines.append(_metric_line("wg_peer_transfer_rx_bytes", peer.transfer_rx, peer_labels))
            lines.append(_metric_line("wg_peer_transfer_tx_bytes", peer.transfer_tx, peer_labels))
            handshake = int(peer.latest_handshake.timestamp()) if peer.latest_handshake else 0
            lines.append(_metric_line("wg_peer_latest_handshake_timestamp", handshake, peer_labels))
            keepalive = peer.persistent_keepalive if peer.persistent_keepalive else 0
            lines.append(_metric_line("wg_peer_persistent_keepalive_seconds", keepalive, peer_labels))

    return "".join(lines)


def write_metrics_file(path: str, content: str):
    directory = os.path.dirname(path) or "."
    os.makedirs(directory, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(prefix=".awg.", dir=directory)
    # Chmod tm file to 644 so that it's readable by node_exporter (which may run as non-root)
    os.chmod(tmp_path, 0o644)
    try:
        with os.fdopen(fd, "w") as tmp_file:
            tmp_file.write(content)
        os.replace(tmp_path, path)
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)

def get_peer_name(server_name, public_key: str) -> str:
    """Get peer name from info_data based on public key"""
    if server_name in info_data:
        for peer_id, peer_info in info_data[server_name].items():
            if peer_info.get('key') == public_key:
                return {'name': peer_info.get('name', peer_id), 'comment': peer_info.get('comment', '')}
    return {'name': public_key[:8], 'comment': ''}  # Fallback to short key if no name found


def run_awg_dump(command: str) -> str:
    result = subprocess.run(
        shlex.split(command),
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "awg-dump command failed")
    return result.stdout


def main():
    """Main entry point"""

    global info_data

    parser = argparse.ArgumentParser(
        description='Parse Amnezia WireGuard (awg-dump) output',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )

    parser.add_argument(
        '--file', '-f',
        type=str,
        help='Read from file instead of stdin'
    )

    parser.add_argument(
        '--json', '-j',
        action='store_true',
        help='Output as JSON'
    )

    parser.add_argument(
        '--pretty', '-p',
        action='store_true',
        help='Pretty print JSON output (only with --json)'
    )

    parser.add_argument(
        '--daemon', '-d',
        action='store_true',
        help='Run in daemon mode and periodically update Prometheus metrics file'
    )

    parser.add_argument(
        '--interval', '-i',
        type=int,
        default=15,
        help='Polling interval in seconds for daemon mode (default: 15)'
    )

    parser.add_argument(
        '--command', '-c',
        default='awg show all dump',
        help='Command to run for dump output (default: awg show all dump)'
    )

    parser.add_argument(
        '--metrics-file',
        type=str,
        default=''
    )

    parser.add_argument(
        '--info-file',
        type=str,
        default='',
        help='File to read for peers info',
    )

    args = parser.parse_args()

    if args.info_file:
        try:
            with open(args.info_file, 'r') as f:
                info_data = json.load(f)
                # print(json.dumps(info_data, indent=2))
        except Exception as exc:
            print(f"Error reading info file: {exc}", file=sys.stderr)
            sys.exit(1)

    if args.daemon:
        if not args.metrics_file:
            print("Error: --metrics-file is required in daemon mode", file=sys.stderr)
            sys.exit(2)

        systemd.daemon.notify('READY=1')

        while True:
            try:
                data = run_awg_dump(args.command)
                awg_parser = AWGDumpParser()
                awg_parser.parse(data)
                metrics = build_prometheus_metrics(awg_parser.interfaces)
                write_metrics_file(args.metrics_file, metrics)
            except Exception as exc:
                print(f"Error: {exc}", file=sys.stderr)
            time.sleep(max(1, args.interval))
    else:
        # Read input
        if args.file:
            with open(args.file, 'r') as f:
                data = f.read()
        else:
            data = sys.stdin.read()

        # Parse
        awg_parser = AWGDumpParser()
        awg_parser.parse(data)

        # Output
        if args.metrics_file:
            metrics = build_prometheus_metrics(awg_parser.interfaces)
            write_metrics_file(args.metrics_file, metrics)
        elif args.json:
            output = awg_parser.to_dict()
            if args.pretty:
                print(json.dumps(output, indent=2, default=str))
            else:
                print(json.dumps(output, default=str))
        else:
            print_human_readable(awg_parser.interfaces)


if __name__ == '__main__':
    main()
