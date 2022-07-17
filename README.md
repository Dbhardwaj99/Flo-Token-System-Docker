# FLO Token-Smart Contract System Docker 

Docker resources to build components required for FLO Token-Smart Contract system, all at one place! 

## Why do I need this?

FLO Token-Smart Contract system consists of three apps working together 
* FLO Token & Smart Contract tracking scripts (Python)
* RanchiMall FLO API (Python-Flask)
* Floscout Token & Smart Contract explorer (JavaScript)

RanchiMall wants to made things easy for you by packing all the three systems together, so you can get started using out system for your Dapps :) 

## How do I use this?

Clone the repository and build the docker image by the following command

```
sudo docker build .
```

Crete a docker volume

```
docker volume inspect ranchimall-flo-volume
```

Run the docker container with exposing all the port and mounting the volume

```
docker run -it -p 3023:3023 -p 6200:6200 -p 6012:6012 -v ranchimall-flo-volume --env NETWORKK='test' --env FLOAPIURL="0.0.0.0:3023" <IMAGE-ID>
```

To Check if FLO-API is running

```
http://0.0.0.0:5009/api/v1.0/getSystemData
```

To Check if FLOSCOUT is running

```
http://0.0.0.0:4256
```

## Development of the docker commands for regular Floscout on Docker

```

docker volume create floscout

docker run -d --name=floscout \
    -p 3023:3023 -p 6200:6200 -p 6012:6012 \
    -v floscout:/data \
    -e NETWORK=mainnet \
    -e FLOSCOUT_BOOTSTRAP=https://ranchimallflo.duckdns.org/api/v1.0/floscout-bootstrap \
    ranchimallfze/floscout

docker logs -f floscout

```
