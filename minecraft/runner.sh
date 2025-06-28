#!/bin/bash

./mc-config /home/app/minecraft/data/server.properties /home/app/minecraft/server.properties

exec ./bedrock_server
