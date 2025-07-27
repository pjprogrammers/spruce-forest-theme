#!/bin/bash
# spruce-forest-theme/scripts/launch-conky.sh

# Kill previous conky instances
killall -q conky

# Path to your conky configs
CONKY_DIR="$HOME/Documents/spruce-forest-theme/conky"

# Launch each conky config with proper paths
conky -c "$CONKY_DIR/conkyrc_time" &
conky -c "$CONKY_DIR/Hermoso_Rc" &
conky -c "$CONKY_DIR/disk" &
conky -c "$CONKY_DIR/procs" &
conky -c "$CONKY_DIR/mem" &
conky -c "$CONKY_DIR/cpu_4_cores" &

