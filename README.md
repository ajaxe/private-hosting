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

```bash
docker compose --env-file ../.env up -d
```

## Validate config

```bash
docker compose --env-file ../.env -f docker-compose.yml -f ../docker-compose.networks.yml config --quiet
```

## Syncing parent .env to compose stacks

```bash
pwsh -File ./sync_env.ps1
```

## Configuration

### Adding Traefik Forward Authentication

For any service needing forward authentication on the Traefik instance, set last middleware to _"fwdauth-global"_ defined in _traefik/traefik_dynamic.yml_. For the service then set the _Servicetoken_ using _Headers_ middleware like following docker label. We will add custom header `X-Service-Token` to every request to identify the service with internal forward authentication service.

```yaml
labels:
  # other labels
  - traefik.http.middlewares.[middleware-name].headers.customrequestheaders.X-Service-Token=${ServiceToken}
```
