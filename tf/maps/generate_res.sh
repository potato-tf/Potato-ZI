#!/bin/bash

if [ -f ../cfg/mapcycle_zi.txt ]; then
    while IFS= read -r mapname || [ -n "$mapname" ]; do 
        cp -au ../cfg/downloads_zi.kv $mapname.res; 
    done < ../cfg/mapcycle_zi.txt
fi