#!/bin/bash

#
# @file    replay_log.sh
# @brief   CAN log replay utility for testing and simulation.
#
# Replays previously recorded CAN traffic from a log file to a CAN interface
# (typically vcan0 for testing). Useful for recreating specific scenarios,
# regression testing, and developing UI features without live vehicle connection.
# Uses canplayer from the can-utils package for accurate timestamp replay.
#
# Usage:
#   ./replay_log.sh <log_file> <interface>
#   Example: ./replay_log.sh race_session_2024.log vcan0
#
# Requirements:
#   - can-utils package (canplayer command)
#   - Valid CAN log file (created with candump -l)
#   - Target CAN interface must exist (use vcan_setup.sh for vcan0)
#
# Design Philosophy:
#   - Input validation to prevent common errors
#   - Clear error messages for troubleshooting
#   - Standard canplayer format compatibility
#
# @author  Kevin Delaney
# @date    January 10, 2026
# @company Delaney Motorsports, LLC
# @address Sarasota, FL
#

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
