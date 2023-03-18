export IMAGE_NAME?=rcarmo/handbrake
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/rcarmo/docker-handbrake
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
export TAG_DATE=`date -u +"%Y%m%d"`
export TARGET_ARCHITECTURES=amd64
export BASE=ubuntu:20.04

# Permanent local overrides
-include .env

default:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
	    --build-arg BASE=$(BASE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		-t $(IMAGE_NAME) . 


push:
	docker push $(IMAGE_NAME)


clean:
	-docker rm -fv $$(docker ps -a -q -f status=exited)
	-docker rmi -f $$(docker images -q -f dangling=true)
	-docker rmi -f $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(IMAGE_NAME))

