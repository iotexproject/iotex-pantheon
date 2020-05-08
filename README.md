# iotex-pantheon
trial installer for iotex consortium blockchain

## Usage:
    ./setup.sh                     - Use the mirror provided by the official docker hub, and
                                     the tag of the image is trial to start the service. The
                                     configuration file uses the contents of the directory trial.

## Visit web explorer
http://localhost:4004/

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
