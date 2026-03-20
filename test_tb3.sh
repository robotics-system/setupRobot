#!/bin/bash

# Se till att miljön är laddad
source /opt/ros/jazzy/setup.bash
export TURTLEBOT3_MODEL=burger

echo "--- Startar TurtleBot3 Basic Node ---"
echo "OBS: Detta startar kommunikationen med motorer och sensorer."
echo "Tryck Ctrl+C för att avsluta testet helt."

# Starta robot-noden i bakgrunden
ros2 launch turtlebot3_bringup robot.launch.py &
BRINGUP_PID=$!

# Vänta lite så noden hinner initiera
sleep 5

echo "--- Startar Teleop (Tangentbordsstyrning) ---"
echo "Använd W-A-S-D eller X för att köra. Tryck 'q' för att stänga teleop."

# Kör teleop
ros2 run turtlebot3_teleop teleop_keyboard

# När teleop stängs, döda även bringup-processen
kill $BRINGUP_PID
echo "--- Test avslutat ---"
