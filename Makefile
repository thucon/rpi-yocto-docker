# build settings
BUILD_DIR=build
# flash variables
#MACHINE=qemu
MACHINE=raspberrypi3-64
#TARGET=core-image-minimal
TARGET=docker-image
SD_CARD=/dev/mmcblk0
ROOT_PART=2

# docker variables
DOCKER_FILE       = dockerfile
DOCKER_REGISTRY   = thucon/yocto-build-image

# global variables
ORG=$(shell pwd)

.PHONY: all flash erase

all: flash

docker-build:
	docker build -t ${DOCKER_REGISTRY} --progress=plain --no-cache --build-arg ARG_UID=$$(id -u) --build-arg ARG_GID=$$(id -g) -f dockerfile .

docker-push:
	docker push $(DOCKER_REGISTRY)

docker-clean:
	docker image rm -f ${DOCKER_REGISTRY}

docker-shell:
	docker run \
		--rm -ti \
		--user $$(id -u):$$(id -g) \
		-v $(ORG):/home/user/work \
		${DOCKER_REGISTRY} \
		/bin/bash

qemu-shell:
	docker run \
		--rm -ti \
		--privileged \
		--user $$(id -u):$$(id -g) \
		-v $(ORG):/home/user/work \
		${DOCKER_REGISTRY} \
		/bin/bash

#flash:
#	bzip2 -cd "${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${TARGET}-${MACHINE}.wic.bz2" | sudo dd status=progress of=${SD_CARD} conv=fdatasync bs=4M; sync

flash: erase
ifeq ($(MACHINE), raspberrypi3-64)
	@if [ ! -e "${SD_CARD}" ]; then \
		echo "No sdcard found (cannot flash)!"; \
		exit 1; \
	fi
	#bzip2 -cd "${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${TARGET}-${MACHINE}.wic.bz2" | sudo dd iflag=direct status=progress of=${SD_CARD} conv=fdatasync bs=4M; sync
	bzip2 -cd "${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${TARGET}-${MACHINE}.wic.bz2" | sudo dd status=progress of=${SD_CARD} conv=fdatasync bs=4M; sync

	@# link: https://unix.stackexchange.com/questions/231643/increasing-partition-of-a-sd-card
	@ echo "resize root partition (expand sdcard)"
	sudo parted ${SD_CARD} resizepart ${ROOT_PART} -- -1
	sudo e2fsck -f ${SD_CARD}p${ROOT_PART}
	sudo resize2fs ${SD_CARD}p${ROOT_PART}
else
	@echo "ERROR: '${MACHINE}' doesn't support flashing!"
endif

erase:
ifeq ($(MACHINE), raspberrypi3-64)
	@#if [ ! -e "${SD_CARD}" ]; then echo "No sdcard found (cannot erase)!" && exit 1; fi
	@if [ ! -e "${SD_CARD}" ]; then \
		echo "No sdcard found (cannot flash)!"; \
		exit 1; \
	fi
	sudo dd if=/dev/zero of=${SD_CARD} bs=10M count=16 status=progress
else
	@echo "ERROR: '${MACHINE}' doesn't support erasing!"
endif
