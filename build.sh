#!/bin/bash

PREFIX="/usr/local"

# copy main scripts
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc
mkdir -p ${PREFIX}/doc
chmod +x bin/*.py
cp bin/* ${PREFIX}/bin/
cp etc/configuration.cfg ${PREFIX}/etc/
cp doc/* ${PREFIX}/doc/

# copy script to download database
chmod +x download-human-db.sh
cp download-human-db.sh ${PREFIX}/bin
