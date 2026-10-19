#
#docker build --build-arg USER_UID=$(id -u)  --build-arg USER_GID=$(id -g) -t rosl .
#
FROM ros:lyrical-ros-base

ENV ROS_DISTRO=lyrical
SHELL ["/bin/bash", "-c"]


RUN apt-get update
RUN apt-get install -y vim
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN apt-get install -y \
    python3-colcon-common-extensions \
    python3-rosdep \
    git sudo



ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000

COPY setup_user.sh /tmp/setup_user.sh

RUN chmod +x /tmp/setup_user.sh && \
    /tmp/setup_user.sh "$USERNAME" "$USER_UID" "$USER_GID" "$USER_HOME" && \
    rm /tmp/setup_user.sh


WORKDIR /uros_ws

#agent
RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    git clone -b $ROS_DISTRO https://github.com/micro-ROS/micro-ROS-Agent.git src/micro-ROS-Agent && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -y --skip-keys \
       "microxrcedds_agent rmw_microxrcedds micro_ros_agent microxrcedds_client microcdr" && \
    source /opt/ros/$ROS_DISTRO/setup.bash && colcon build


RUN git clone -b $ROS_DISTRO https://github.com/micro-ROS/micro_ros_setup.git src/micro_ros_setup
RUN source /opt/ros/$ROS_DISTRO/setup.bash && source install/local_setup.bash && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -y --skip-keys \
      "microxrcedds_agent rmw_microxrcedds micro_ros_agent" && \
    source /opt/ros/$ROS_DISTRO/setup.bash && \
    colcon build 

RUN source /opt/ros/$ROS_DISTRO/setup.bash && source install/local_setup.bash && \
    ros2 run micro_ros_setup create_firmware_ws.sh host && \
    ros2 run micro_ros_setup build_firmware.sh

RUN apt-get install -y lttng-tools ros-lyrical-ros2trace
RUN apt-get install -y kmod

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /uros_ws/bashrc && \
    echo "source /uros_ws/install/local_setup.bash" >> /uros_ws/bashrc

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /ros2

CMD ["bash"]
