#!/bin/bash

#
# @file    vcan_setup.sh
# @brief   Virtual CAN interface setup script for development and testing.
#
# Configures a virtual CAN (vcan) network interface for testing Reikon Dash without
# physical CAN hardware. The vcan module provides a loopback CAN interface where
# frames sent to the interface are immediately received back, perfect for development,
# unit testing, and CI/CD pipelines.
#
# Usage:
#   sudo ./vcan_setup.sh
#
# Requirements:
#   - Linux kernel with CONFIG_CAN_VCAN enabled
#   - Root/sudo privileges
#   - iproute2 package (ip command)
#
# Design Philosophy:
#   - Safe idempotent execution (can run multiple times)
#   - Clear user feedback and next steps
#   - Standard vcan0 interface name for consistency
#
# @author  Kevin Delaney
# @date    January 10, 2026
# @company Delaney Motorsports, LLC
# @address Sarasota, FL
#

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
