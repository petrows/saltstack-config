#!/usr/bin/env python3

import time
import shlex
import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import threading
import logging
import argparse
import random
import docker

class Handler(FileSystemEventHandler):

    @staticmethod
    def on_any_event(event):
        if event.is_directory:
            return None

        elif event.event_type == 'created':
            # Take any action here when a file is first created.
            logging.info("Created: %s" % event.src_path)
            update_event.set()

def detect_indexer_running():
    # running = bool(random.getrandbits(1))
    # if running:
    #     logging.info("Indexer is running, wait")
    # return running
    client = docker.from_env()
    container = client.containers.get(args.container)
    logs = container.logs().splitlines()

    # Find last line with "indexer"
    for line in reversed(logs):
        s = line.decode("utf-8")
        if "index:" in s:
            #print (f"Last indexer message: {s}")
            message = dict(token.split('=') for token in shlex.split(s))
            message_time = message['time']
            # Convert UTC time to local datetime object
            message_time = datetime.datetime.fromtimestamp(datetime.datetime.strptime(
                message_time, "%Y-%m-%dT%H:%M:%S%z").timestamp())
            message_diff = (datetime.datetime.now() -
                            message_time).total_seconds()

            logging.info(
                "Last indexer activiy detected %d seconds ago" % message_diff)

            if message_diff < 30:
                return True
            break

    return False

def start_indexer():
    logging.info("Indexer started")
    client = docker.from_env()
    container = client.containers.get(args.container)
    stream = container.exec_run(
        cmd='photoprism index',
        #cmd='ls -lah /',
        stream=True
    )
    for data in stream.output:
        for line in data.decode('utf-8').strip().split('\n'):
            logging.info(line)

    logging.info("Indexer finished")

def indexer_function():
    while running:
        flag = update_event.wait(3600)
        if flag:
            update_event.clear()
            logging.info("Update scheduled")
            # Wait indexer?
            while detect_indexer_running() and running:
                logging.info("Indexer is running, wait")
                time.sleep(10)
            if not running:
                return
            start_indexer()


parser = argparse.ArgumentParser(
    description='Watch import folder for new files')

parser.add_argument(
    '-l', '--log',
    choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
    default='INFO',
    help='set log level',
)

parser.add_argument(
    '--container',
    type=str,
    action='store',
    help='container to notify',
)

parser.add_argument(
    'folder',
    type=str,
    action='store',
    help='path to directory to watch',
)

args = parser.parse_args()

log_level = args.log
logging.basicConfig(level=log_level)

update_event = threading.Event()
running = True
observer = Observer()
indexer = threading.Thread(target=indexer_function)
indexer.start()

directory_to_watch = args.folder

event_handler = Handler()

observer.schedule(
    event_handler,
    directory_to_watch,
    recursive=True
)
observer.start()

update_event.set()

try:
    while True:
        time.sleep(5)
except:
    observer.stop()
    #logging.info("")

logging.info("Exitting")
running = False
update_event.set()

observer.join()
