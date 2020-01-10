NAME = registry.cn-beijing.aliyuncs.com/docker_wachoo_1/yapi
YAPI_VERSION = 1.8.1
VERSION = 0.0.1
PARAMS = --spring.profiles.active=dev
CONTAINER_NAME = yapi-${YAPI_VERSION}_${VERSION}-0
CONTAINER_PORT = 3002:3001
CONTAINER_NET = tools-net
CONTAINER_IP = 172.18.0.4

.PHONY: build start push

build: build-version

build-version:
	docker build --rm -t ${NAME}:${VERSION}  .

tag-latest:
	docker tag ${NAME}:${VERSION} ${NAME}:latest

start:
	echo "start yapi server"
	docker run -d -p ${CONTAINER_PORT} --name ${CONTAINER_NAME} --net ${CONTAINER_NET} --ip ${CONTAINER_IP} ${NAME}:${VERSION}
	echo "end yapi server"


push:   build-version tag-latest
	docker push ${NAME}:${VERSION}; docker push ${NAME}:latest



#
contianer-rm:
	docker rm -f ${CONTAINER_NAME}


#
container-clear:
	bash start.sh stop

build-mongodb-rm:
	bash start.sh remove

# network
init-network:
	bash start.sh  init-network

# mongo
start-mongo:
	bash start.sh start-mongo

init-mongo:
	bash start.sh init-mongo

# yapi
download-yapi:
#	sh code_download_hub.sh ${YAPI_VERSION}
	sh code_download_git.sh

init-yapi:
	bash start.sh init-yapi

logs-yapi:
	bash start.sh logs-yapi


