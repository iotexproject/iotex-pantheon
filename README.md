<p align="center">
  <img src="https://github.com/iotexproject/iotex-pantheon/blob/master/logo.png" width="480px">
</p>

Pantheon is the consortium blockchain built with IoTeX techonology. With trial, The chain will be running on standalone mode in this setup(one single node produce blocks).

## Usage:
    ./setup.sh                     - Use the mirror provided by the official docker hub, and
                                     the tag of the image is trial to start the service. The
                                     configuration file uses the contents of the directory trial.

## Setup guide
1. Install [Docker](https://docs.docker.com/get-docker/) if not already.
2. Download/unzip https://github.com/iotexproject/iotex-pantheon/archive/master.zip or ```git clone``` this repo.
3. Please make sure your following ports are available to use: 3000, 33306, 4004, 4689, 8089, 8090, 8200, 9090, 9901, 10000, 14014, 14689, 15015, 18080, 33060
4. Run: ```./setup.sh``` and follow the instructions. Once this script is done, the blockchain backend and frontend should be already up and running. 
5. Open up a browser to visit http://localhost:4004.
6. If this is the first time everything is up, you need to select "Don’t have an account? Sign up". 
7. Search “Initial Root Token” in your terminal to find a string like ```s.brtnkbVTDGzM7uQSRuGa2sVW```, and use it to register a new user and login the system.
8. If you need advanced monitoring, login http://localhost:3000/login with ```admin/admin``` and configure your own dashboard.

## Access xun-explorer remotely
If you are accessing explorer not on the mechine where you plan to deploy the iotex-pantheon, please change following entries in ./docker-compose/docker-compose-one-node.yml before you run `setup.sh`:
```
      ANALYTICS_API_GATEWAY_URL: http://localhost:8089/query
      API_GATEWAY_URL: http://localhost:4004/api-gateway/
      GRAFANA_LINK: http://localhost:3000
```
Change from `localhost` to the remote mechine address/ip.


## Use command line tool
1. Set command line tool to connect with chain node
```
ioctl config set endpoint 127.0.0.1:14014 --insecure
```

2. import the demo private key (c4fc484f35479d50b3f9f21dbdf63d466db1f432fa8ea2ad7a4e80bc8cacadcc)
```
ioctl account import key 4b
```

3. Now you can make transcation or deploy contract with demo account
```
ioctl action transfer io1gakgrsnsxmg9ed0tlcc2ukxzxdg6v8z2glw82e 10000 -s 4b
```
```
ioctl action deploy -b "0x3838533838f3" -s 4b
```

## Features Compare
|   | IoTeX Mainnet  | Pantheon Trial  |  Pantheon Production  |
|---|---|---|---|
| Delegate Election | YES | NO | NO |
| 0 Fee Transction | NO | YES | YES |
| Private Access | NO | YES  | YES |
| User Management | NO | YES  | YES |
| Block Producer Management | NO | NO | YES |
| Multiple Block Producers | YES | NO | YES |
| Layer 2 Scalability | NO  | NO  | YES  |
