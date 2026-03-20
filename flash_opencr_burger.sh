#!/bin/bash
set -e

echo "--- Förbereder flashning av OpenCR för Burger ---"

# 1. Lägg till 32-bitars arkitektur (krävs för flash-verktyget)
echo "Lägger till armhf-arkitektur..."
sudo dpkg --add-architecture armhf
sudo apt update
sudo apt install libc6:armhf -y

# 2. Definiera variabler
export OPENCR_PORT=/dev/ttyACM0
export OPENCR_MODEL=burger

# 3. Ladda ner firmware-paketet
echo "Laddar ner senaste OpenCR-firmware för ROS 2..."
rm -rf ./opencr_update.tar.bz2
wget https://github.com/ROBOTIS-GIT/OpenCR-Binaries/raw/master/turtlebot3/ROS2/latest/opencr_update.tar.bz2

# 4. Packa upp och installera
echo "Packar upp och startar flashning..."
tar -xvf opencr_update.tar.bz2
cd ./opencr_update

# Kör själva uppdateringen
# OBS: Se till att OpenCR är ansluten via USB till pajen
./update.sh $OPENCR_PORT $OPENCR_MODEL.opencr

echo "--- Flashning klar! ---"
echo "Starta om roboten (power cycle) för att säkerställa att allt hoppar igång."
