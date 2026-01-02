INFISICAL_CMD = infisical run
.PHONY: up down config

up: up-observability up-infra up-database up-apps up-tools

down: down-infra down-database down-apps  down-tools down-observability

up-database:
	$(INFISICAL_CMD) --path /database -- docker compose --profile database up -d 
down-database:
	$(INFISICAL_CMD) --path /database -- docker compose --profile database down 

up-infra:
	$(INFISICAL_CMD) --path /infrastructure -- docker compose --profile infrastructure up -d 
down-infra:
	$(INFISICAL_CMD) --path /infrastructure -- docker compose --profile infrastructure down 

up-apps:
	$(INFISICAL_CMD) --path /apps -- docker compose --profile apps up -d 
down-apps:
	$(INFISICAL_CMD) --path /apps -- docker compose --profile apps down 

up-observability:
	$(INFISICAL_CMD) --path /observability -- docker compose --profile observability up -d 
down-observability:
	$(INFISICAL_CMD) --path /observability -- docker compose --profile observability down 

up-tools:
	$(INFISICAL_CMD) --path /tools -- docker compose --profile tools up -d 
down-tools:
	$(INFISICAL_CMD) --path /tools -- docker compose --profile tools down 

config:
	$(INFISICAL_CMD) --path /common --path /infrastructure --path /observability --path /apps --path /tools -- docker compose config