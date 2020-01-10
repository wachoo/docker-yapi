#!/bin/bash

version=1.8.1
if [ -n "$1" ]; then
 version=$1
fi

github_url=https://github.com/YMFE/yapi/archive/v$version.tar.gz

echo "usage:  sh code_download.sh  <version>"
echo "yapi的版本:  https://github.com/YMFE/yapi/releases"
echo "我们将从这里下载:  $github_url"

echo -e "\033[32m download new package ($version) \033[0m"

wget -O yapi.tar.gz $github_url

 if [ $? -ne 0 ]; then
    echo -e "\033[31m wget failed for yapi, make sure ( wget -O yapi.tar.gz $github_url ) can work \033[0m"
    return ;
 fi

