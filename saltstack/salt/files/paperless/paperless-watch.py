#!/usr/bin/env python-app

import time
import shlex
import datetime
import re
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from pathlib import Path
from pprint import pprint
import requests
import urllib3
import logging
import argparse
import queue
import random
import sys
import systemd.daemon

urllib3.disable_warnings()

running = True
exit_code = 0
q = queue.SimpleQueue()
path_date_sub = r'(\d{4}-\d{2}-\d{2})'
path_year_sub = r'^(\d{4})$'
path_year_plus_sub = r'^(\d{4})[^\d]+'

def scan_dir(pn: Path):
    ret = []
    if pn.name.startswith('.'):
        print(f"Warning: {pn} skipped")
        return ret
    if pn.is_file():
        return [pn]
    if pn.is_dir():
        for path in Path(pn).rglob('*'):
            ret = ret + scan_dir(path)
    return ret

def search_date_in_path(pn: Path):
    for pp in [pn] + list(pn.parents):
        pp = pp.name
        ss = re.search(path_date_sub, pp)
        if ss:
            return datetime.date.fromisoformat(ss[1])
    return None

def search_year_in_path(pn: Path):
    for pp in list(pn.parents):
        pp = pp.name
        ss = re.search(path_year_sub, pp)
        if ss:
            file_date = datetime.datetime.fromtimestamp(pn.stat().st_mtime)
            # Set only year
            file_date = file_date.replace(year=int(ss[1]))
            return file_date
    return None

class Handler(FileSystemEventHandler):

    @staticmethod
    def on_any_event(event):

        logging.debug("Event: %s", event.event_type)

        if event.is_directory:
            return None

        elif event.event_type in ['closed', 'moved']:
            file_path = event.src_path
            # 'moved' object has also destination
            if event.event_type == 'moved':
                file_path = event.dest_path
            # Take any action here when a file is first created.
            logging.debug("Event file: %s", file_path)
            q.put(file_path)


def process_function():
    """
    Get queued files and send them to docs service
    """
    while running:
        try:
            task = q.get(timeout=3600)
        except queue.Empty:
            logging.debug("No tasks")
            continue

        headers =  {"Authorization":f"Token {args.token}"}

        f = Path(task)

        if not f.exists():
            logging.info("File not exists: %s", str(f))
            continue

        # Check file extension
        file_ext = f.suffix.lower()
        if file_ext not in ['.pdf', '.jpg', '.jpeg', '.png']:
            logging.info("Ignore wrong extension file: %s", f.name)
            continue

        mime_type = 'application/pdf'
        if file_ext not in ['.jpg', '.jpeg']:
            mime_type = 'image/jpeg'
        if file_ext not in ['.png']:
            mime_type = 'image/png'

        # Generate file title
        file_name = f.stem
        # Replace file-name-here to 'file name here'
        file_name = file_name.replace("-", " ")
        # Revert dates in file "2024-05-05"
        file_name = re.sub('(\d{4}) (\d{2}) (\d{2})', '\\1-\\2-\\3', file_name)

        # Detect document date
        file_date = datetime.datetime.fromtimestamp(f.stat().st_mtime)
        # From path?
        file_date_from_path = search_date_in_path(f)
        if (file_date_from_path):
            file_date = file_date_from_path
        else:
            file_date_from_path = search_year_in_path(f)
            if (file_date_from_path):
                file_date = file_date_from_path

        logging.info("Processing file: %s (%s) (%s)", task, file_name, file_date.strftime("%Y-%m-%d"))

        request_data = {
            'title': (None, file_name),
            'created': (None, file_date.strftime("%Y-%m-%d")),
            'document': (str(f), open(task, 'rb'), mime_type),
        }

        response = requests.post(
            f"{args.url}/api/documents/post_document/",
            files=request_data,
            headers=headers,
            verify=False,
        )

        if response.status_code == 400:
            # Corrupted file
            logging.error("Bad request: %s", response.text)
            continue

        if response.status_code != 200:
            raise RuntimeError(f"Invalid answer from Paperless: {response.status_code}, {response.text}")


def rescan_function():
    """
    Force rescan of some folder and add all files to queue
    """
    files = []

    for pattern in args.folder:
        p = Path(pattern)
        files = files + scan_dir(p)

    files = list(set(files))
    for f in files:
        q.put(str(f))

    logging.info("File rescan complete")


parser = argparse.ArgumentParser(
    description='Watch documents folder for new files')

parser.add_argument(
    '-l', '--log',
    choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
    default='INFO',
    help='set log level',
)

parser.add_argument(
    '--url',
    type=str,
    required=True,
    action='store',
    help='url to access Paperless-ngx',
)

parser.add_argument(
    '--token',
    type=str,
    required=True,
    action='store',
    help='token to access Paperless-ngx',
)

parser.add_argument(
    '--rescan',
    action='store_true',
    help='force rescan watch folder',
)

parser.add_argument(
    'folder',
    type=str,
    nargs=argparse.ONE_OR_MORE,
    action='store',
    help='path to directory to watch',
)

args = parser.parse_args()

log_level = args.log
logging.basicConfig(level=log_level)

observer = Observer()
event_handler = Handler()
for dir in args.folder:
    observer.schedule(
        event_handler,
        dir,
        recursive=True,
    )
observer.start()

systemd.daemon.notify('READY=1')

if args.rescan:
    rescan_function()

try:
    process_function()
except Exception as e:
    exit_code = 1
    logging.error(e)
    # raise e

logging.info("Exitting")
running = False

observer.stop()
observer.join()

sys.exit(exit_code)
