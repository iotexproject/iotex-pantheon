#!/bin/bash

CODE_URL=""
TMP_DIR="/tmp/.iotex/pantheon/"
UNZIP="unzip"

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

function checkDockerPermissions() {
    docker ps > /dev/null
    if [ $? = 1 ];then
        echo -e "your $RED [$USER] $NC not privilege docker" 
        echo -e "please run $RED [sudo bash] $NC first"
        echo -e "Or docker not install "
        exit 1
    fi
}

function checkDockerCompose() {
    docker-compose --version > /dev/null 2>&1
    if [ $? -eq 127 ];then
        echo -e "$RED docker-compose command not found $NC"
        echo -e "Please install it first"
        exit 1
    fi
}

function checkCommandUnzip() {
    unzip --version > /dev/null 2>&1
    if [ $? -ne 0 ];then
	echo -e "$RED unzip command not found $NC"
        echo -e "Please install it first"
        exit 1
    fi
}

function fetchCode() {
    curl -sS $downloadCode > $tmp_dir/master.zip
    pushd $tmp_dir
    $UNZIP master.zip
    popd
}


function main() {
    checkDockerPermissions
    checkDockerCompose
    checkCommandUnzip
    
    fetchCode

    pushd $tmp_dir/iotex-pantheon-master
    ./setup.sh 
    popd
}

main $@
