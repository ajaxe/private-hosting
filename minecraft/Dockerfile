FROM ubuntu:25.04 AS build

ARG MinecraftPackage=bedrock-server-1.21.80.3.zip
ARG InstallFolder=/home/app/minecraft

ENV LD_LIBRARY_PATH=$InstallFolder

RUN mkdir -p $InstallFolder

WORKDIR $InstallFolder

RUN apt-get update -y && apt-get install -y unzip curl

COPY $MinecraftPackage .
COPY mc-config .
COPY runner.sh .

RUN unzip $MinecraftPackage && rm $MinecraftPackage && chmod +x bedrock_server \
    && chmod +x runner.sh && chmod +x mc-config

RUN groupadd -g 999 minecraft && useradd -g minecraft minecraft

EXPOSE 19132

ENTRYPOINT [ "./runner.sh" ]
