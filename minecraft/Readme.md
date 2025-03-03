# Mincecraft docker setup

## Image build

Build docker image using current folder as builc context. Download a copy of Ubuntu distribution of [Minecraft server](https://www.minecraft.net/en-us/download/server/bedrock) to the current folder which will be used as part fot he docker build.

Docker build command

```bash
docker build . --tag apogee-dev/minecraft:local
```
