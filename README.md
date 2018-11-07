# Highthroughput
Docker Container for Analysis of High Throughput Sequencing Data training course

## To run the container for the first time with generic graphics:
```
xhost +
docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix:rw --privileged -e DISPLAY=unix$DISPLAY \
-v $HOME/:/home/training/ --device /dev/dri --privileged --name highthroughput \
ebitraining/highthroughput:latest
```
## To run with Nvidia graphics, add the following option:
```
-v /usr/lib/nvidia-340:/usr/lib/nvidia-340 -v /usr/lib32/nvidia-340:/usr/lib32/nvidia-340
```
## To resume using an container:
```
docker exec -it highthroughput /bin/bash
```
## To build the container:
```
docker build -f ./Dockerfile -t highthroughput .
docker tag highthroughput ebitraining/highthroughput:latest
docker push ebitraining/highthroughput:latest
```
