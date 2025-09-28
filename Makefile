DOCKER_AS_ROOT:=docker run -t --rm -w /opt/share -v $(shell pwd):/opt/share
DOCKER_AS_USER:=$(DOCKER_AS_ROOT) -u $(shell id -u):$(shell id -g)
DOCKER_AS_USER_IT:=$(DOCKER_AS_USER) -i
DOCKER_AS_ROOT_IT:=$(DOCKER_AS_ROOT) -i

all: build

build:
	docker build . -t oracle_ros_fasstdds
	docker build . -f Dockerfile.ros2 -t oracle_ros

run:
	docker run -it --rm --name oracle_ros oracle_ros bash

fetch_rmw_fastrtps:
	git clone https://github.com/ros2/rmw_fastrtps.git
	cd rmw_fastrtps && git checkout humble

debug:
	${DOCKER_AS_ROOT_IT} oracle_ros