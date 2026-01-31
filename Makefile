INFISICAL_CMD = infisical run

.PHONY: up down

up: up-observability up-infra up-database up-apps

down: down-infra down-database down-apps  down-observability

up-database:
	$(INFISICAL_CMD) --path /database -- docker compose --profile database -f compose.db.yml up -d --wait
down-database:
	$(INFISICAL_CMD) --path /database -- docker compose --profile database -f compose.db.yml down 

up-infra:
	$(INFISICAL_CMD) --path /infrastructure -- docker compose --profile infrastructure -f compose.infra.yml up -d 
down-infra:
	$(INFISICAL_CMD) --path /infrastructure -- docker compose --profile infrastructure -f compose.infra.yml down 

up-apps:
	$(INFISICAL_CMD) --path /apps -- docker compose --profile apps -f compose.apps.yml up -d 
down-apps:
	$(INFISICAL_CMD) --path /apps -- docker compose --profile apps -f compose.apps.yml down 

up-observability:
	$(INFISICAL_CMD) --path /observability --env=prod -- sh -c 'echo -n "$$PrometheusUptimeApiSecret" > grafana/configs/uptime_pwd.txt'
	$(INFISICAL_CMD) --path /observability -- docker compose --profile observability -f compose.observability.yml up -d 
down-observability:
	rm -f grafana/configs/uptime_pwd.txt
	$(INFISICAL_CMD) --path /observability -- docker compose --profile observability -f compose.observability.yml down 
