# private-hosting

This repository contains the `docker compose` configuration files for self-hosting various services, primarily acting as a reverse proxy and an observability stack. It's designed to be run using `docker compose` on a single host, rather than Docker Swarm, as indicated by certain configurations within the `docker-compose.yml`.

For more details, refer to the Self-Hosting project documentation.

## Services Overview

The `docker-compose.yml` defines the following core services:

- **`reverse-proxy` (Traefik)**: An edge router and reverse proxy that exposes various internal services to the outside world, handles SSL/TLS termination (via ACME/Let's Encrypt), and provides a web UI.
- **`grafana`**: A powerful open-source platform for monitoring and observability, allowing you to visualize metrics, logs, and traces from various data sources.
- **`otel-collector` (OpenTelemetry Collector)**: A vendor-agnostic proxy that receives, processes, and exports telemetry data (metrics, traces, and logs) to various backends.
- **`jaeger`**: A distributed tracing system used for monitoring and troubleshooting microservices-based architectures. It collects and visualizes trace data.
- **`prometheus`**: An open-source monitoring system with a flexible data model and a powerful query language (PromQL), used for collecting and storing time-series data.

## Prerequisites

Before running these services, ensure you have:

- **Docker and Docker Compose**: Installed on your host machine.
- **`.env` file**: A `.env` file must be present in the parent directory (`../.env`) containing the `HOSTING_DIR` environment variable. This variable specifies the base directory on your host where configuration files and persistent data for the services are stored.

  Example `../.env` content:

  ```
  HOSTING_DIR=/opt/private-hosting
  ```

  _Note_: The `acme.json` file (used by Traefik for Let's Encrypt certificates) mounted from `${HOSTING_DIR}/traefik/acme.json` must have file permissions set to `600` (read/write only by owner) for Traefik to start correctly.

## Command

```console
docker compose --env-file ../.env up -d
```
