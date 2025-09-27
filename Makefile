all: build

build:
	docker build . -t oracle_ros_fasstdds
	docker build . -f Dockerfile.ros2 -t oracle_ros
