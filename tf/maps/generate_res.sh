#!/bin/bash

if [ -f ../cfg/mapcycle_zi.txt ]; then
    while IFS= read -r mapname || [ -n "$mapname" ]; do 
        cp -au ../zi/cfg/downloads_zi.kv $mapname.res; 
    done < ../cfg/mapcycle_zi.txt
else
    echo "mapcycle_zi.txt not found"
    ls -la ../cfg/*.txt
    exit 1
fi