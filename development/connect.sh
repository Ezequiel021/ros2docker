#!/bin/bash
docker run -it --name ros_dev_env \
  -v $(pwd)/src:/ros2/src \
  --net=host \
  rosl bash
