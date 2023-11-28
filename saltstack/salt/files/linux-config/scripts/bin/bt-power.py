#!/usr/bin/env python

import dbus
from xml.etree import ElementTree

def rec_intro(bus, service, object_path):
    print(object_path)
    obj = bus.get_object(service, object_path)
    iface = dbus.Interface(obj, 'org.freedesktop.DBus.Introspectable')
    xml_string = iface.Introspect()
    for child in ElementTree.fromstring(xml_string):
        if child.tag == 'node':
            if object_path == '/':
                object_path = ''
            new_path = '/'.join((object_path, child.attrib['name']))
            rec_intro(bus, service, new_path)

bus = dbus.SystemBus()
rec_intro(bus, 'org.freedesktop.UPower', '/org/freedesktop/UPower')

