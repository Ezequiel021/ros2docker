#!/bin/bash
ROS_DISTRO=lyrical

#agent 
source /opt/ros/$ROS_DISTRO/setup.bash && \
git clone -b $ROS_DISTRO https://github.com/micro-ROS/micro-ROS-Agent.git src/micro-ROS-Agent && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -y --skip-keys \
       "microxrcedds_agent rmw_microxrcedds micro_ros_agent microxrcedds_client microcdr" && \
    source /opt/ros/$ROS_DISTRO/setup.bash && colcon build


#libs
source /opt/ros/$ROS_DISTRO/setup.bash && source install/local_setup.bash && \
git clone -b $ROS_DISTRO https://github.com/micro-ROS/micro_ros_setup.git src/micro_ros_setup
rosdep update && \
    rosdep install --from-paths src --ignore-src -y --skip-keys "microxrcedds_agent rmw_microxrcedds micro_ros_agent" && \
    source /opt/ros/$ROS_DISTRO/setup.bash && \
    colcon build

source /opt/ros/$ROS_DISTRO/setup.bash && source install/local_setup.bash && \
ros2 run micro_ros_setup create_firmware_ws.sh host && \
ros2 run micro_ros_setup build_firmware.sh

#echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /$HOME/.bashrc && \
#echo "source /uros_ws/install/local_setup.bash" >> /$HOME/.bashrc
