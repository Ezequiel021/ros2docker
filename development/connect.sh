#!/bin/bash
docker run -it --name ros_dev_env \
  -v $(pwd)/src:/uros_ws/src \
  --net=host \
  rosl bash
