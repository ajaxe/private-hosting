# --- STAGE 1: Build the mc-configurator utility ---
FROM golang:bookworm AS builder

RUN apt-get update && apt-get upgrade -y && apt-get install -y git

RUN mkdir -p /go/src/github.com/ajaxe/mc-configurator
WORKDIR /go/src/github.com/ajaxe/mc-configurator

# Clone and build the Go utility
RUN git clone https://github.com/ajaxe/mc-configurator.git . \
    && git pull origin main
RUN go mod download
RUN go build -o ./tmp/linux/mc-config .

# --- STAGE 2: Final Bedrock Server Image ---
FROM ubuntu:22.04 AS final

ARG MinecraftPackage=bedrock-server-1.21.131.1.zip
ARG InstallFolder=/home/app/minecraft

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install core dependencies, networking tools, and gosu (Ubuntu alternative to su-exec)
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    libcurl4 \
    libcap2-bin \
    iproute2 \
    unzip \
    procps \
    strace \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Create a dedicated user for the server (UID 999)
RUN groupadd -g 999 minecraft && useradd -u 999 -g minecraft -m minecraft

RUN mkdir -p $InstallFolder
WORKDIR $InstallFolder

# 2. Install legacy libssl1.1 (Required for RakNet)
RUN curl -O http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    ldconfig

# 3. Download the Minecraft Bedrock Dedicated Server binary
RUN curl -H "User-Agent: Mozilla/5.0" -L -o $MinecraftPackage \
    https://www.minecraft.net/bedrockdedicatedserver/bin-linux/$MinecraftPackage

# 4. Copy assets from builder and local context
COPY --from=builder "/go/src/github.com/ajaxe/mc-configurator/tmp/linux/mc-config" .
COPY runner.sh .

# 5. Extract server and setup permissions
RUN unzip $MinecraftPackage && rm $MinecraftPackage && \
    chmod +x bedrock_server && \
    # Grant binary permission to bind to privileged ports
    setcap 'cap_net_bind_service,cap_net_raw=+ep' ./bedrock_server && \
    chmod +x runner.sh && \
    chmod +x mc-config && \
    # Set initial ownership (runner.sh will handle volume mounts at runtime)
    chown -R minecraft:minecraft $InstallFolder && \
    chmod -R 755 $InstallFolder

# NOTE: We start as ROOT to allow runner.sh to fix volume permissions.
# runner.sh will use gosu to drop to the minecraft user.
USER root

# Minecraft Bedrock UDP ports
EXPOSE 19132/udp
EXPOSE 19133/udp

ENTRYPOINT [ "./runner.sh" ]