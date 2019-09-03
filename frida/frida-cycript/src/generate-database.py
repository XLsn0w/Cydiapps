#!/usr/bin/env python3

import codecs
import os
import sqlite3
import sys

system = sys.argv[1]
dbfile = sys.argv[2]
brdefs = sys.argv[3]
nodejs = sys.argv[4]
merges = sys.argv[5:]

system = int(system)
nodejs = os.path.join(nodejs, 'lib')

keys = {}

with codecs.open(brdefs, 'r', 'utf-8') as brdefs_file:
    while True:
        line = brdefs_file.readline()
        if line == "":
            break
        elif line == "\n":
            continue
        assert line[-1] == '\n'
        line = line[0:-1]

        pipe = line.index('|')
        name = line[0:pipe]
        line = line[pipe+1:]

        quote = line.index('"')
        flags = int(line[0:quote])
        code = line[quote+1:-1]

        key = (name, flags, code)
        keys[key] = system

for db in merges:
    with sqlite3.connect(db) as sql:
        c = sql.cursor()
        for name, system, flags, code in c.execute('SELECT name, system, flags, code FROM cache'):
            key = (name, flags, code)
            keys[key] = keys.get(key, 0) | system

if os.path.exists(dbfile):
    os.unlink(dbfile)

with sqlite3.connect(dbfile) as sql:
    c = sql.cursor()

    c.execute("CREATE TABLE CACHE (name TEXT NOT NULL, system INT NOT NULL, flags INT NOT NULL, code TEXT NOT NULL, PRIMARY KEY (name, system))")
    c.execute("CREATE TABLE MODULE (name TEXT NOT NULL, flags INT NOT NULL, code BLOB NOT NULL, PRIMARY KEY (name))")

    for name in [js[0:-3] for js in os.listdir(nodejs) if js.endswith('.js')]:
        with open(os.path.join(nodejs, name + '.js'), 'r') as file:
            code = file.read()
        c.execute("INSERT INTO module (name, flags, code) VALUES (?, ?, ?)", [name, 0, code])

    many = []
    for key, system in keys.items():
        name, flags, code = key
        many.append((name, system, flags, code))
    c.executemany("INSERT INTO cache (name, system, flags, code) VALUES (?, ?, ?, ?)", many)
