#!/bin/bash

branch=master
git_url=https://github.com/wachoo/yapi.git

if [ -n "$1" ]; then
 branch=$1
fi

echo "usage:  sh code_download_git_clone.sh  <branch>"
echo "yapi的版本：  https://github.com/YMFE/yapi/releases"

echo -e "\033[32m git clone new branch: $branch from $git_url \033[0m"

git clone -b $branch $git_url yapi

 if [ $? -ne 0 ]; then
    echo -e "\033[31m git clone failed for yapi，please make sure( git clone -b $branch $git_url yapi) can work \033[0m"
    return ;
 fi

echo -e "\033[32m build new image \033[0m"

tar -cvf yapi /yapi.tar.gz
