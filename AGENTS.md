# AGENTS.md - Private Hosting Infrastructure

This document provides a contextual anchor for AI agents to understand the architecture, conventions, and operational patterns of this repository.

## 1. Project Mission
**Private Hosting** is a centralized infrastructure-as-code repository for managing a modular home lab environment. Its mission is to provide a highly observable, secure, and automated deployment pipeline for diverse services using **Docker Compose** and **Infisical** secrets management.

## 2. Tech Stack & Core Dependencies
- **Containerization:** Docker & Docker Compose (Standalone, **NOT** Swarm).
- **Reverse Proxy:** **Traefik** (Edge Router) with ACME/Let's Encrypt and AWS Route53 DNS challenges.
- **Secrets Management:** **Infisical** (Primary source of truth for all environment variables).
- **Observability:** **Prometheus**, **Grafana**, **Loki**, **OpenTelemetry (OTEL)**, and **Jaeger**.
- **Database Layer:** PostgreSQL, Redis, and MongoDB.
- **Identity & Auth:** **Apogee Identity Server** (Custom OIDC Provider) and **Traefik Forward Auth**.
- **Automation:** Makefile, PowerShell (`sync_env.ps1`), and Go (`sync-env` utility).

## 3. Architecture & Design Patterns
- **Modular Tiers:** Services are partitioned into functional tiers (`database`, `infrastructure`, `observability`, `apps`) managed via separate compose files (`compose.<tier>.yml`).
- **Base Inheritance:** Services extend `x-base-service` from `compose.base.yml` for consistent restart policies, resource limits, and network attachment.
- **Environment Synchronization:** A "Master .env" pattern is used. Infisical injects secrets into the root `.env`, which is then propagated to subdirectories using `sync_env.ps1` or the `sync-env` Go utility.
- **Global Forward Auth:** A centralized authentication pattern is implemented via Traefik middlewares (`fwdauth-global`), allowing services to delegate authentication to a single forward-auth endpoint.
- **Dual-Zone Routing:** Traefik handles both public (Cloudflare/ACME) and internal (VPN/Route53) traffic with distinct certificate resolvers (`default` vs `dns_route53`).

## 4. Directory Mental Model
- **Root (`/`):** Global orchestration logic. Contains `Makefile`, tier-specific `compose.*.yml`, and global network definitions.
- **`traefik/`:** Static and dynamic configurations for the edge router, including global middlewares.
- **`grafana/`:** Observability stack configuration, dashboards, and datasource provisioning.
- **`sync-env/`:** Source code for the Go utility that manages environment variable distribution across sub-stacks.
- **`[service-folder]/`:** Individual service definitions. Each folder typically contains a `docker-compose.yml` and its own `.env` (auto-synced).
- **`logs/`:** Centralized log storage (managed by Loki/Promtail).

## 5. Development Standards
- **Secrets:** **NEVER** commit hardcoded secrets. All sensitive values must be stored in Infisical and referenced via `${VARIABLE_NAME}`.
- **Routing:** Use **Traefik labels** for service exposure. Always specify `traefik.docker.network=public-proxy`.
- **Naming:** 
  - Folders: `kebab-case` (e.g., `apogee-identity-server`).
  - Networks: `public-proxy` (External).
- **Auth Pattern:** For services requiring authentication, attach the `fwdauth-global@file` middleware in Traefik labels.
- **Persistence:** Mount volumes to `${HOSTING_DIR}/[service-name]/data` to ensure consistent state management.

## 6. Hard Constraints & Anti-Patterns
- **No Docker Swarm:** The configurations use features (like certain volume mounts or network types) that are incompatible or untested with Swarm.
- **No Manual Env Edits:** Do not manually edit `.env` files inside service subfolders. Change the root `.env` or Infisical and run the sync script.
- **No Hardcoded IPs:** Use service names for inter-container communication. Use host IPs only for external resources (e.g., `192.168.0.x`).
- **Network Isolation:** Only expose services to `public-proxy` if they need to be reachable via the reverse proxy.

## 7. Operational Commands
- **Full Start:** `make up` (Starts all tiers in sequence: Observability -> Infra -> DB -> Apps).
- **Tier-Specific:** 
  - `make up-database` / `make down-database`
  - `make up-infra` / `make down-infra`
  - `make up-observability` / `make down-observability`
- **Environment Sync:** 
  - PowerShell: `pwsh -File ./sync_env.ps1`
  - Go: `cd sync-env && go run main.go`
- **Validate Configuration:** `docker compose -f compose.yml config`
- **Secrets Injection:** `infisical run -- [command]` (e.g., `infisical run -- make up`).
