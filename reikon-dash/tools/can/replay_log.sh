#!/bin/bash

# Replay CAN log file to virtual CAN interface

if [ $# -lt 2 ]; then
    echo "Usage: $0 <log_file> <interface>"
    echo "Example: $0 recording.log vcan0"
    exit 1
fi

LOG_FILE=$1
INTERFACE=$2

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found"
    exit 1
fi

echo "Replaying CAN log from $LOG_FILE to $INTERFACE"
canplayer -I $LOG_FILE $INTERFACE=vcan0
