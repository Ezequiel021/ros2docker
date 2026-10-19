#!/bin/sh
# compile.sh - build the packages
#
#   sh compile.sh  [pkg]

. /opt/ros/$ROS_DISTRO/setup.sh
if [ -z "$1" ]; then
  echo "$0  package"
  exit 1
fi
pkg="$1"
colcon build --packages-select ${pkg}
