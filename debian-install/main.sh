#!/bin/bash

set -e
OLD_ISO="$1"
NEW_ISO="$2"

python render.py preseed.cfg.j2 preseed.cfg
./mkpreseediso.sh "$OLD_ISO" "$NEW_ISO"
