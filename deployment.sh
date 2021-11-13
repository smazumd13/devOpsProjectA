#!/bin/bash
containerString=$(docker ps -a|grep -c con1)
if [ $containerString -eq 1 ]; then
    docker stop con1
    docker rm con1
fi
