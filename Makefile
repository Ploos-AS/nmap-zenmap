.PHONY: build up down logs check

build:
	docker compose build

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f

check:
	docker compose config --quiet

