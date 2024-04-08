#!/bin/bash

echo "Installing microservice..."
sudo cp qrcode.service /etc/systemd/system/
echo "    ✔ DONE."
echo "Reloading daemons..."
sudo systemctl daemon-reload
echo "    ✔ DONE."
echo "Enabling service on boot..."
sudo systemctl enable qrcode.service
echo "    ✔ DONE."
echo "Starting service..."
sudo service qrcode start
echo "    ✔ DONE."
