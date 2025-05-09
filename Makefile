export FORCE_COLOR = 1
export NPM_FORCE_COLOR = 1
export DOCKER_BUILDKIT = 1
export DOCKER_BUILDKIT_PROGRESS = auto
export DOCKER_BUILDKIT_METADATA_FILE ?= build-metadata.json

DOCKER_SERVICE ?= base
REST_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

DOCKER = docker
DOCKER_COMPOSE = $(DOCKER) compose

.PHONY: add_lockfile
add_lockfile:
	pnpm npm:no:offline pnpm add --lockfile-only

.PHONY: update_lockfile
update_lockfile:
	pnpm npm:no:offline pnpm install --lockfile-only --no-frozen-lockfile

.PHONY: install_lockfile
install_lockfile:
	pnpm npm:no:offline pnpm install --frozen-lockfile --config.confirmModulesPurge=false


.PHONY: clean
clean:
	pnpm clean $(REST_ARGS)

.PHONY: check
check:
	pnpm check $(REST_ARGS)

.PHONY: fix
fix:
	pnpm fix $(REST_ARGS)

.PHONY: test
test:
	pnpm test $(REST_ARGS)

.PHONY: env
env:
	pnpm run script env

.PHONY: build
build: env
	$(DOCKER) buildx bake base \
		--file docker-compose.yml \
		--load \
		--progress=$(DOCKER_BUILDKIT_PROGRESS) \
		--metadata-file $(DOCKER_BUILDKIT_METADATA_FILE) \
		$(REST_ARGS)

.PHONY: exec
exec:
	$(DOCKER_COMPOSE) exec $(DOCKER_SERVICE) $(REST_ARGS)

.PHONY: shell
shell: env
	$(DOCKER_COMPOSE) run --rm --entrypoint /bin/bash --user nodeuser $(DOCKER_SERVICE)

.PHONY: start
start:
	$(DOCKER_COMPOSE) up -d --remove-orphans $(REST_ARGS)
	$(DOCKER_COMPOSE) rm -f

.PHONY: up
up: env start

.PHONY: down
down:
	$(DOCKER_COMPOSE) down --rmi local $(REST_ARGS)
