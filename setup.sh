#!/bin/bash

# This script is used to setup all servers in one host.
# Usage:
#    ./setup.sh                     - Compile using the trial of each service image. 
#                                     And start them up. The configuration
#                                     file for the service comes from the trial directory
#                                     of this project.

# Colour codes
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

WHITE_LINE="echo"

BRANCH="trial"
IOTEX_MODE="one-node"

function usage () {
    echo ' Usage:
    ./setup.sh                     - Compile using the trial of each service image. 
                                     And start them up. The configuration
                                     file for the service comes from the trial directory
                                     of this project.
'
    exit 2
}

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

function setVar4Trial() {
    IOTEX_IMAGE=iotex/iotex-core:trial
    IOTEX_ELECTION_IMAGE=iotex/iotex-election:trail
    IOTEX_ANALYTICS_IMAGE=iotex/iotex-analytics:trail
    IOTEX_EXPLORER_IMAGE=iotex/iotex-explorer:trail
    IOTEX_XUN_EXPLORER_IMAGE=iotex/xun-explorer:trial
    IOTEX_HIGH_TABLE_IMAGE=iotex/high-table:trail
    IOTEX_GOLDEN_GATE_IMAGE=iotex/golden-gate:trail
}

function setVar() {
    producerPrivKey=""
    externalHost=""
    defaultdatadir="$HOME/iotex-var"

    COPY="cp -vf"
    DOCKER_PULL_CMD="docker pull"

    RM="sudo rm -rf"

    PROJECT_ABS_DIR=$(cd "$(dirname "$0")";pwd)

    IOTEX_DOCKER_COMPOSE_DIR=docker-compose

    IOTEX_MONITOR_IMAGE=iotex/iotex-monitor:v1
    IOTEX_VAULT_IMAGE=vault:1.3.2
    IOTEX_DB_IMAGE=mysql:8.0.19
    IOTEX_ENVOY_IMAGE=envoyproxy/envoy-alpine:d920944aed67425f91fc203774aebce9609e5d9a

    setVar4Trial
}

function determinIotexHome() {
    ##Input Data Dir
    echo "The current user of the input directory must have write permission!!!"
    echo -e "${RED} Input your directory \$IOTEX_HOME !!! ${NC}"
    
    #while True: do
    read -p "Input your \$IOTEX_HOME [e.g., $defaultdatadir]: " inputdir
    IOTEX_HOME=${inputdir:-"$defaultdatadir"}
}

function confirmEnvironmentVariable() {
    echo -e "Confirm IOTEX_HOME directory: ${RED} ${IOTEX_HOME} ${NC}"
    read -p "Press any key to continue ... [Ctrl + c exit!] " key1
}

function determinIotexAnalyticsDatabaseRootPass() {
    ##Input Database root password
    echo "The database of the input password is used to the Analytics service."
    echo -e "${RED} Set the password: [ Default is 'rootuser' ]${NC}"
    read -s userpass
 
    DB_ROOT_PASSWORD=${userpass:-"rootuser"}
}

function makeDbWorkspace() {
    mkdir -p data/mysql
}

function makeCoreWorkspace() {
    mkdir -p data/core log/core etc/core
}

function makeVaultWorkspace() {
    mkdir -p etc/vault data/vault log/vault
}

function makeHighTableWorkspace() {
    mkdir -p data/high-table etc/high-table key/high-table
}

function makeMonitorWorkspace() {
    mkdir -p etc/monitor
}

function makeGoldenGateWorkspace() {
    mkdir -p etc/golden-gate
}

function makeEnvoyWorkspace() {
    mkdir -p etc/envoy
}

function makeAnalyticsWorkspace() {
    mkdir -p etc/analytics
}

function makeElectionWorkspace() {
    mkdir -p etc/election
}

function makeWorkspace() {
    mkdir -p ${IOTEX_HOME}
    pushd ${IOTEX_HOME}

    makeDbWorkspace
    makeCoreWorkspace
    makeVaultWorkspace
    makeHighTableWorkspace
    makeMonitorWorkspace
    makeGoldenGateWorkspace
    makeEnvoyWorkspace
    makeAnalyticsWorkspace
    makeElectionWorkspace
    
    mkdir -p docker-compose
    popd
}

function copyConfig() {
    if [ ! -d $PROJECT_ABS_DIR/$1 ];then
        echo "branch $1 is not supported now."
        exit 2
    fi

    echo -e "$YELLOW Copy the configure files... $NC"
    $COPY $PROJECT_ABS_DIR/$1/core-config.yaml $IOTEX_HOME/etc/core/config.yaml
    $COPY $PROJECT_ABS_DIR/$1/genesis.yaml $IOTEX_HOME/etc/core/genesis.yaml

    $COPY $PROJECT_ABS_DIR/$1/prometheus-one-node.yml $IOTEX_HOME/etc/monitor/prometheus.yml

    $COPY $PROJECT_ABS_DIR/$1/election-config.yaml $IOTEX_HOME/etc/election/config.yaml
    $COPY $PROJECT_ABS_DIR/$1/analytics-config.yaml $IOTEX_HOME/etc/analytics/config.yaml
    $COPY $PROJECT_ABS_DIR/$1/high-table-ec256-private.test.pem $IOTEX_HOME/key/high-table/ec256-private.test.pem
    $COPY $PROJECT_ABS_DIR/$1/high-table.json $IOTEX_HOME/etc/high-table/high-table.json
    $COPY $PROJECT_ABS_DIR/$1/envoy.yaml $IOTEX_HOME/etc/envoy/envoy.yaml
    $COPY $PROJECT_ABS_DIR/$1/golden-gate-config.yaml $IOTEX_HOME/etc/golden-gate/config.yaml
    $COPY $PROJECT_ABS_DIR/$1/admin-policy.hcl $IOTEX_HOME/etc/vault/admin-policy.hcl
    $COPY $PROJECT_ABS_DIR/$1/regular-policy.hcl $IOTEX_HOME/etc/vault/regular-policy.hcl

    $COPY $PROJECT_ABS_DIR/docker-compose/docker-compose-one-node.yml $IOTEX_HOME/$IOTEX_DOCKER_COMPOSE_DIR/docker-compose.yml
    $COPY $PROJECT_ABS_DIR/docker-compose/.env $IOTEX_HOME/$IOTEX_DOCKER_COMPOSE_DIR/.env
    echo -e "$YELLOW Copy done. $NC"

    $WHITE_LINE
}

function pullImage(){
    echo -e "$YELLOW docker pull $1... $NC"
    $DOCKER_PULL_CMD $1
    echo -e "$YELLOW Pull $1 done. $NC"
    $WHITE_LINE
}

function pullImages() {
    pullImage $IOTEX_MONITOR_IMAGE
    pullImage $IOTEX_DB_IMAGE
    pullImage $IOTEX_VAULT_IMAGE
    pullImage $IOTEX_ENVOY_IMAGE
}

function pullTrialImages() {
    pullImage $IOTEX_IMAGE
    pullImage $IOTEX_ELECTION_IMAGE
    pullImage $IOTEX_ANALYTICS_IMAGE
    pullImage $IOTEX_XUN_EXPLORER_IMAGE
    pullImage $IOTEX_HIGH_TABLE_IMAGE
    pullImage $IOTEX_GOLDEN_GATE_IMAGE
}

function exportAll() {
    export IOTEX_HOME DB_ROOT_PASSWORD IOTEX_IMAGE IOTEX_ELECTION_IMAGE IOTEX_ANALYTICS_IMAGE IOTEX_EXPLORER_IMAGE IOTEX_XUN_EXPLORER_IMAGE IOTEX_HIGH_TABLE_IMAGE IOTEX_GOLDEN_GATE_IMAGE IOTEX_VAULT_IMAGE IOTEX_ENVOY_IMAGE IOTEX_DB_IMAGE IOTEX_MONITOR_IMAGE
}

function startup() {
    echo -e "$YELLOW Start iotex-server, iotex-election, iotex-analytics and it's database, iotex-explorer and iotex-server monitor. $NC"
    pushd $IOTEX_HOME/$IOTEX_DOCKER_COMPOSE_DIR
    docker-compose up -d --no-recreate
    if [ $? -eq 0 ];then
        echo -e "${YELLOW} To view blockchain explorer, visit: http://localhost:4004. For first time usage, you will need to create a user ${NC}"
        echo ""
        echo -e "${YELLOW} To view blockchain status dashboard, visit: localhost:3000. The default User/Pass: admin/admin.  ${NC}"
    fi
    popd
}

function grantPrivileges() {
    echo -e "$YELLOW Starting database...$NC"
    # maxRetryTime * sleeptime = timeout
    retryTimes=0
    maxRetryTime=10
    pushd $IOTEX_HOME/$IOTEX_DOCKER_COMPOSE_DIR
    docker-compose up -d database
    
    echo -e "$YELLOW Waiting for the mysqld daemon in the iotex-db container to successful... $NC"
    while true;do
        if [ $retryTimes -gt $maxRetryTime ];then
            echo -e "$RED Start mysql server container faild. $NC"
            echo -e "$RED Please check its logs by command \"docker logs iotex-db\" $NC"
            exit 1
        fi
        docker exec iotex-db mysql -uroot -p${DB_ROOT_PASSWORD} -e "\q" > /dev/null 2>&1
        if [ $? -eq 0 ];then
            break
        fi
        retryTimes=$((retryTimes+1))
        sleep 4
    done
    popd
    echo -e "$YELLOW Success! $NC"
    docker exec iotex-db mysql -uroot -p${DB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'"  > /dev/null 2>&1
    $WHITE_LINE
 }

function initVault() {
    echo -e "$YELLOW Start vault server... $NC"
    pushd $IOTEX_HOME/$IOTEX_DOCKER_COMPOSE_DIR
    docker-compose up -d vault
    popd

    # maxRetryTime * sleeptime = timeout
    retryTimes=0
    maxRetryTime=10
    echo -e "$YELLOW Waiting for the vault daemon in the iotex-vault container to successful... $NC"
    while true;do
        if [ $retryTimes -gt $maxRetryTime ];then
            echo -e "RED Start vault server container faild."
            echo -e "$RED Please check its logs by command \"docker logs iotex-vault\" $NC"
            exit 1
        fi
    
        docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" iotex-vault vault status > /dev/null 2>&1
    
        if [ $? -eq 2 ];then
            break
        fi
        retryTimes=$((retryTimes+1))
        sleep 4
    done
    echo -e "$YELLOW Success! $NC"
    $WHITE_LINE
    
    if [ ! -f $IOTEX_HOME/data/vault/initdata ];then    
    	docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" iotex-vault vault operator init > $IOTEX_HOME/data/vault/initdata
    else
    	echo -e "$YELLOW vault is already initialized. Unsealing the data...$NC"
    fi

    index=0
    while read -r line; do
	echo $line | grep 'Initial Root Token' > /dev/null 2>&1
	if [ $? -eq 0 ];then
	    rootToken=$(echo $line | awk -F':' '{print $2}' | tr -d '[:space:]')
	    continue
	fi
	echo $line | grep 'Unseal Key'  > /dev/null 2>&1
	if [ $? -eq 0 ];then
	    index=$(($index+1))
	    echo -e "$YELLOW Unseal the vault data $index time: $NC"
	    key=$(echo $line | awk -F':' '{print $2}' | tr -d '[:space:]')
	    docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" -e "VAULT_TOKEN=$rootToken" iotex-vault vault operator unseal $key
	    keys="$keys $key"
	    $WHITE_LINE
	fi
    done < $IOTEX_HOME/data/vault/initdata
    
    echo -e "$YELLOW Initial Root Token: $rootToken $NC"
    echo -e "$YELLOW Unseal Keys: $NC"
    for k in `echo $keys`; do
	echo $k
    done
    $WHITE_LINE

    if [ ! -f $IOTEX_HOME/data/vault/usertoken ];then
        echo -e "$YELLOW Create token: $NC"
        docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" -e "VAULT_TOKEN=$rootToken" iotex-vault vault token create | tee $IOTEX_HOME/data/vault/usertoken
        echo  -e "$YELLOW Please save these information to login vault. $NC"
    else
	echo -e "$YELLOW user is already created: $NC"
	cat $IOTEX_HOME/data/vault/usertoken
    fi
    IOTEX_USER_KEY=`cat $IOTEX_HOME/data/vault/usertoken|grep token_accessor | awk '{print $2}'`
    IOTEX_USER_TOKEN=`cat $IOTEX_HOME/data/vault/usertoken|grep -E "token\b" | awk '{print $2}'`
    export IOTEX_USER_KEY IOTEX_USER_TOKEN
    $WHITE_LINE

    # Write policy
    docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" -e "VAULT_TOKEN=$rootToken" iotex-vault vault policy read admin > /dev/null 2>&1
    if [ $? -ne 0 ];then
        echo -e "${YELLOW} Setup admin policy for vault. ${NC}"
        docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" -e "VAULT_TOKEN=$rootToken" iotex-vault vault policy write admin /vault/iotex-policy/admin-policy.hcl
    fi
    docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" -e "VAULT_TOKEN=$rootToken" iotex-vault vault policy read regular > /dev/null 2>&1
    if [ $? -ne 0 ];then
        echo -e "${YELLOW} Setup regular policy for vault. ${NC}"
        docker exec -e "VAULT_ADDR=http://127.0.0.1:8200" -e "VAULT_TOKEN=$rootToken" iotex-vault vault policy write regular /vault/iotex-policy/regular-policy.hcl
    fi
    $WHITE_LINE
}

function cleanAll() {
    echo -e "$YELLOW Starting clean all containers... $NC"
    pushd $IOTEX_HOME/$IOTEX_DOCKER_COMPOSE_DIR
    docker-compose rm -s -f -v
    popd
    echo -e "${YELLOW} Done. ${NC}"

    echo -e "${YELLOW} Starting delete all files... ${NC}"
    if [ "${IOTEX_HOME}X" = "X" ] || [ "${IOTEX_HOME}X" = "/X" ];then
        echo -e "${RED} \$IOTEX_HOME: ${IOTEX_HOME} is wrong. ${NC}"
        ## For safe.
        return
    fi
    
    $RM $IOTEX_HOME
    echo -e "${YELLOW} Done. ${NC}"
    
    popd
}

function main() {
    checkDockerPermissions
    checkDockerCompose

    setVar

    determinIotexHome
    confirmEnvironmentVariable

    if [ "$1" = "clean" ];then
        cleanAll
        exit 0
    fi
    
    determinIotexAnalyticsDatabaseRootPass

    makeWorkspace

    copyConfig $BRANCH

    pullImages

    pullTrialImages

    exportAll

    grantPrivileges

    initVault

    startup

    . $PROJECT_ABS_DIR/scripts/setup_cli.sh
    . $PROJECT_ABS_DIR/scripts/setup_userpass.sh

    # Set env for command userpass.
    VAULT_ADDR=localhost:8200
    HIGH_TABLE_ADDR=localhost:8090
    export VAULT_ADDR HIGH_TABLE_ADDR
}

main $@
