FROM golang:bookworm AS builder

# Use shallow clone for speed and reproducibility
WORKDIR /go/src/github.com/ajaxe/mc-configurator
RUN git clone --depth 1 https://github.com/ajaxe/mc-configurator.git . \
    && go mod download

RUN go build -o /mc-config .

# Switch to Debian Slim for smaller footprint
FROM debian:bookworm-slim AS final

ARG MinecraftPackage=bedrock-server-1.21.131.1.zip
ARG InstallFolder=/home/app/minecraft

ENV LD_LIBRARY_PATH=$InstallFolder

# Combine installs and clean up apt cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    curl \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 999 minecraft && useradd -r -g minecraft -u 999 minecraft

WORKDIR $InstallFolder

COPY $MinecraftPackage .
COPY --from=builder /mc-config .
COPY runner.sh .

# Unzip, set permissions, and chown in one step
RUN unzip -q $MinecraftPackage \
    && rm $MinecraftPackage \
    && chmod +x bedrock_server runner.sh mc-config \
    && chown -R minecraft:minecraft $InstallFolder

EXPOSE 19132/udp 25575/tcp

# Run as non-root user
USER minecraft

ENTRYPOINT [ "./runner.sh" ]
