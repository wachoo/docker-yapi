#!/bin/bash

function init-network(){
    docker network rm tools-net
    docker network create --subnet=172.18.0.0/16 tools-net
}

function mk_d(){
 local dir_name=$1
 if [ ! -d $dir_name  ];then
      mkdir -p $dir_name
 else
      echo "dir ${dir_name} exist"
 fi

}


function start-mongo(){
    mk_d ${HOME}/data/opt/mongodb/data/configdb
    mk_d ${HOME}/data/opt/mongodb/data/db/

    docker kill mongod
    docker rm -f mongod
    docker run  \
    --name mongod \
    -p 27017:27017  \
    -v ${HOME}/data/opt/mongodb/data/configdb:/data/configdb/ \
    -v ${HOME}/data/opt/mongodb/data/db/:/data/db/ \
    -v ${HOME}/data/opt/mongodb/data/backup/:/data/backup/ \
    --net tools-net --ip 172.18.0.2 \
    -d mongo:4 --auth
}

function init-mongo(){
    echo "init mongodb account for admin and yapi"
    docker cp  init-mongo.js  mongod:/data
    docker exec -it mongod mongo admin /data/init-mongo.js
#    docker cp  data/yapi_mongo_data0.js  mongod:/data
#    docker exec -it mongod mongo admin /data/yapi_mongo_data0.js
    echo "init mongodb done"
}

function dump-mongo(){
    echo "backup mongodb account for admin and yapi"
    docker exec -it mongod sh -c 'exec var=`date +%Y%m%d%H%M` &amp;&amp; mongodump -h localhost --port 27017 -u admin -p amdin123456 -d yapi -o /data/backup/$var_yapi.dat'
    echo "backup mongodb done"
}

function restore-mongo(){
    if [ -n "$1" ]; then
     local file=$1
    fi
    echo "restore mongodb via $file"
    docker cp $file mongod:/data/backup/
    echo "restore mongodb account for admin and yapi"
    docker exec -it mongod sh -c 'exec mongorestore -h localhost --port 27017 -u admin -p amdin123456 -d yapi -o /data/backup/20200421.dat/'
    echo "restore mongodb done"
}

function build-yapi(){
    echo -e "\033[32m build new image \033[0m"
    docker build -t yapi .
    docker tag yapi yapi:$version
    echo "end yapi server"
}

function start-yapi(){
    echo "start yapi server"
    docker run -d -p 3001:3001 --name yapi --net tools-net --ip 172.18.0.3 yapi
    echo "end yapi server"
}

function init-yapi(){
    echo "init yapi db and start yapi server"
    docker run -d -p 3001:3001 --name yapi --net tools-net --ip 172.18.0.3 yapi --initdb
    echo "init yapi done"
}

function logs-yapi(){
     docker logs --tail 10 yapi
}

function remove(){
    rm -r ${HOME}/data/opt/mongodb/
}

function stop(){
    docker kill mongod yapi
    docker rm -f mongod
    docker rm -f yapi
}


function print_usage(){
  echo " Usage: bash start.sh <param>"
  echo " 可用参数：    "
  echo "   init-network:  初始化网络，第一次运行的时候执行，多次执行只会删除重建 "
  echo "   start-mongo: 创建数据目录/data/opt/mongodb/data/db/，并启动MongoDB， 前提是init-network完成"
  echo "   init-mongo:  初始化mongodb的用户，创建yapi用户和db，前提是mongodb已安装，即start-mongo完成"
  echo "   start-yapi:  单纯启动yapi"
  echo "   init-yapi:   初始化yapi的db，并启动。前提是MongoDB可以连接，即init-mongo完成"
  echo "   logs-yapi:  查看yapi容器的日志"
  echo "   stop:   停止mongodb和yapi，但保留mongodb文件/data/opt/mongodb/data/db/"
  echo "   remove: 删除db文件"
}


case $1 in
    init-network)
       init-network
       ;;
    start-mongo)
       start-mongo
       ;;
    init-mongo)
       init-mongo
       ;;
    dump-mongo)
       dump-mongo
       ;;
    restore-mongo)
       restore-mongo $2
       ;;
    build-yapi)
       build-yapi
       ;;
    start-yapi)
       start-yapi
       ;;
    init-yapi)
       init-yapi
       ;;
    logs-yapi)
       logs-yapi
       ;;
    remove)
        remove
        ;;
    stop)
        stop
        ;;
    *)
       print_usage
       ;;
esac
