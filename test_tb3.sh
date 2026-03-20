#!/bin/bash

# 1. Ladda ROS 2-miljön
source /opt/ros/jazzy/setup.bash

# 2. Tvinga miljövariabler för denna session (viktigt för Jazzy!)
export TURTLEBOT3_MODEL=burger
export LDS_MODEL=LDS-01

echo "--- Startar TurtleBot3 Basic Node ---"
echo "OBS: Detta startar kommunikationen med motorer och sensorer."
echo "Modell: $TURTLEBOT3_MODEL | Lidar: $LDS_MODEL"

# Starta robot-noden i bakgrunden och skicka loggar till en fil istället för att skräpa ner terminalen
ros2 launch turtlebot3_bringup robot.launch.py > /tmp/tb3_bringup.log 2>&1 &
BRINGUP_PID=$!

# Vänta lite så noden hinner initiera och kolla om den fortfarande lever
sleep 3
if ! kill -0 $BRINGUP_PID 2>/dev/null; then
    echo "FEL: Robot-noden dog direkt. Kolla loggen: cat /tmp/tb3_bringup.log"
    exit 1
fi

echo "--- Startar Teleop (Tangentbordsstyrning) ---"
echo "Använd W-A-S-D eller X för att köra. Tryck 'q' för att stänga teleop."

# 3. Kör teleop (denna blockerar tills du trycker 'q' eller Ctrl+C)
ros2 run turtlebot3_teleop teleop_keyboard

# 4. Städa upp
echo "Stänger ner robot-noden..."
kill $BRINGUP_PID
echo "--- Test avslutat ---"
