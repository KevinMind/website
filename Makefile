
RUN_WEB = docker compose run --rm --remove-orphans web

setup:
	npm run setup

build: setup
	docker compose build --progress=plain

exec:
	docker compose exec web $(ARGS)

up: setup
	docker compose up -d --remove-orphans --build
