FROM golang:bookworm AS builder
# Use the official Golang image as the base image for building the application
RUN apt-get update && apt-get upgrade -y

RUN mkdir -p /go/src/github.com/ajaxe/mc-configurator
WORKDIR /go/src/github.com/ajaxe/mc-configurator
RUN git clone https://github.com/ajaxe/mc-configurator.git . \
    && git pull origin main
RUN go mod download

RUN go build -o ./tmp/linux/mc-config .


FROM ubuntu:25.04 AS final

ARG MinecraftPackage=bedrock-server-1.21.131.1.zip
ARG InstallFolder=/home/app/minecraft

ENV LD_LIBRARY_PATH=$InstallFolder

RUN apt-get update && apt-get upgrade -y 

RUN mkdir -p $InstallFolder

WORKDIR $InstallFolder

RUN apt-get update -y && apt-get install -y unzip curl

# COPY $MinecraftPackage .
RUN curl -H "User-Agent: Mozilla/5.0" -L -o $MinecraftPackage \
    https://www.minecraft.net/bedrockdedicatedserver/bin-linux/$MinecraftPackage

COPY --from=builder "/go/src/github.com/ajaxe/mc-configurator/tmp/linux/mc-config" .
COPY runner.sh .

RUN unzip $MinecraftPackage && rm $MinecraftPackage && chmod +x bedrock_server \
    && chmod +x runner.sh && chmod +x mc-config

RUN groupadd -g 999 minecraft && useradd -g minecraft minecraft

EXPOSE 19132 25575

ENTRYPOINT [ "./runner.sh" ]
