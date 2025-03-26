#!/bin/bash
# Setup script for Node-RED and MQTT with RS485 device on Raspberry Pi

# Create necessary directories
mkdir -p node-red-data
mkdir -p mosquitto-config
mkdir -p mosquitto-data
mkdir -p mosquitto-log

# Copy the Mosquitto config file
cat > mosquitto-config/mosquitto.conf << 'EOL'
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log

# Include default listeners
listener 1883
protocol mqtt

listener 9001
protocol websockets

# Allow anonymous connections (for development)
# For production, consider setting up authentication
allow_anonymous true
EOL

# Set permissions
sudo chown -R 1000:1000 mosquitto-data
sudo chown -R 1000:1000 mosquitto-log
sudo chown -R 1000:1000 node-red-data
sudo chown -R 1000:1000 mosquitto-config

# Ensure the USB device is accessible
# Find the USB device (adjust if your device is not ttyUSB0)
USB_DEVICE="/dev/ttyUSB0"

# Check if the device exists
if [ -e "$USB_DEVICE" ]; then
    echo "Found USB device at $USB_DEVICE"
    # Make it accessible to the container
    sudo chmod 666 $USB_DEVICE
else
    echo "USB device not found at $USB_DEVICE. Please check your connection and device name."
    echo "You may need to adjust the device path in docker-compose.yml"
fi

# Start the services
echo "Starting Docker Compose..."
docker compose up -d

echo "Setup complete!"
echo "- Access Node-RED at http://localhost:1880"
echo "- MQTT broker is running on port 1883 (MQTT) and 9001 (WebSockets)"
echo "- MQTT Dashboard (MQTTX Web) is available at http://localhost:8080"