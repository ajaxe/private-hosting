FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache curl

# Store the static application jar outside of the user volume mount
WORKDIR /opt/geyser
RUN curl -fSL -o Geyser-Standalone.jar \
    https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone

# App runtime directory (mount your volume here)
WORKDIR /app

EXPOSE 19132/udp

ENTRYPOINT ["java", "-Xms512M", "-Xmx1G", "-jar", "/opt/geyser/Geyser-Standalone.jar"]