CONTAINER_ENGINE := $(shell which podman 2>/dev/null || which docker 2>/dev/null)
COMPOSE_CMD := $(shell if [ -x "$$(which podman-compose)" ] && [ "$(CONTAINER_ENGINE)" = "$$(which podman)" ]; then echo "podman-compose"; else echo "docker-compose"; fi)

.PHONY: start stop remove setup copy-config copy-pages copy-files backup

setup:
	mkdir -p nomadnet-net
	for i in {1..4}; do \
		mkdir -p nomadnet-net/nomad$$i/{nomadnet,reticulum}; \
		mkdir -p nomadnet-net/nomad$$i/nomadnet/storage/{pages,files}; \
	done
	chmod -R 755 nomadnet-net

copy-config:
	@if [ -n "$(NODE)" ]; then \
		cp -r nomadnet-config/* nomadnet-net/nomad$(NODE)/nomadnet/ 2>/dev/null || true; \
		cp -r reticulum-config/* nomadnet-net/nomad$(NODE)/reticulum/ 2>/dev/null || true; \
	else \
		for i in {1..4}; do \
			cp -r nomadnet-config/* nomadnet-net/nomad$$i/nomadnet/ 2>/dev/null || true; \
			cp -r reticulum-config/* nomadnet-net/nomad$$i/reticulum/ 2>/dev/null || true; \
		done; \
	fi

copy-pages:
	@if [ -n "$(NODE)" ]; then \
		cp -r pages/* nomadnet-net/nomad$(NODE)/nomadnet/storage/pages/ 2>/dev/null || true; \
	else \
		for i in {1..4}; do \
			cp -r pages/* nomadnet-net/nomad$$i/nomadnet/storage/pages/ 2>/dev/null || true; \
		done; \
	fi

copy-files:
	@if [ -n "$(NODE)" ]; then \
		cp -r files/* nomadnet-net/nomad$(NODE)/nomadnet/storage/files/ 2>/dev/null || true; \
	else \
		for i in {1..4}; do \
			cp -r files/* nomadnet-net/nomad$$i/nomadnet/storage/files/ 2>/dev/null || true; \
		done; \
	fi

start: setup copy-config copy-pages copy-files
	$(COMPOSE_CMD) up -d

stop:
	$(COMPOSE_CMD) stop

remove: stop
	$(COMPOSE_CMD) down
	rm -rf nomadnet-net

backup:
	@timestamp=$$(date +%Y%m%d_%H%M%S); \
	if [ -n "$(NODE)" ]; then \
		tar -czf nomadnet-backup-node$(NODE)-$$timestamp.tar.gz \
			-C nomadnet-net/nomad$(NODE) nomadnet reticulum; \
		echo "Backup created: nomadnet-backup-node$(NODE)-$$timestamp.tar.gz"; \
	else \
		tar -czf nomadnet-backup-all-$$timestamp.tar.gz nomadnet-net/; \
		echo "Backup created: nomadnet-backup-all-$$timestamp.tar.gz"; \
	fi
