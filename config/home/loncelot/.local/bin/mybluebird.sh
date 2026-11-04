#!/bin/bash

set -e

echo "Stopping Bluetooth..."
systemctl stop bluetooth

echo "Resetting Broadcom Bluetooth controller..."
echo -n 'serial1-0' > /sys/bus/serial/drivers/hci_uart_bcm/unbind

sleep 1
echo -n 'serial1-0' > /sys/bus/serial/drivers/hci_uart_bcm/bind

sleep 1
echo "Starting Bluetooth..."
systemctl start bluetooth

echo "Bluetooth controller reset complete."