#!/bin/bash

cd $(dirname $0)

function showGreen()
{
    echo -e "\033[32m${1}\033[0m"    
}

showGreen "===================================="
showGreen "是否需要更新index索引？（y/n）"
showGreen "===================================="

read flag

if [ $flag == "y" ] || [ $flag == "Y" ] || [ $flag == "yes" ] || [ $flag == "YES" ] 
then
    pod update
else
    pod update --no-repo-update
fi