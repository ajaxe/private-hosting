FROM ubuntu:24.04 AS build

ARG MinecraftPackage=bedrock-server-1.21.60.10.zip
ARG InstallFolder=/home/app/minecraft

ENV LD_LIBRARY_PATH=$InstallFolder

RUN mkdir -p $InstallFolder

WORKDIR $InstallFolder

RUN apt-get update -y && apt-get install -y unzip curl

COPY $MinecraftPackage .

RUN unzip $MinecraftPackage && rm $MinecraftPackage && chmod +x bedrock_server

RUN groupadd -g 999 minecraft && useradd -g minecraft minecraft

EXPOSE 19132

ENTRYPOINT [ "./bedrock_server" ]
