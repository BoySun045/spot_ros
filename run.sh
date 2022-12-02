xhost +

echo "=========================" 
echo "=nvidia docker installed="
echo "========================="
docker run -it \
--privileged \
--env=DISPLAY=$DISPLAY \
--env="XAUTHORITY=${XAUTH}" \
--env="QT_X11_NO_MITSHM=1" \
--env="LIBGL_ALWAYS_INDIRECT=" \
--env="LIBGL_ALWAYS_SOFTWARE=1" \
--rm \
-v /etc/group:/etc/group:ro \
-v /etc/passwd:/etc/passwd:ro \
-v "/$(pwd)/user_launch/:/catkin_ws/src/Azure_Kinect_ROS_Driver/launch/user_launch" \
-v "/$(pwd)/scripts/:/catkin_ws/src/Azure_Kinect_ROS_Driver/scripts/scripts" \
-v "/$(pwd)/rviz/:/catkin_ws/src/Azure_Kinect_ROS_Driver/rviz" \
-v "/$(pwd)/pose_data/:/pose_data" \
--net host \
cvg/spot_ros_driver:latest
