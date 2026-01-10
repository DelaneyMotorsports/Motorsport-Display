#!/bin/bash

# Setup virtual CAN interface for testing

VCAN_INTERFACE="vcan0"

# Load vcan module
sudo modprobe vcan

# Create vcan interface
sudo ip link add dev $VCAN_INTERFACE type vcan

# Bring up the interface
sudo ip link set up $VCAN_INTERFACE

echo "Virtual CAN interface $VCAN_INTERFACE is now up"
echo "Use 'candump $VCAN_INTERFACE' to monitor traffic"
echo "Use 'cansend $VCAN_INTERFACE' to send frames"
