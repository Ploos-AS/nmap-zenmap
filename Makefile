.PHONY: build up down logs check smoke

IMAGE ?= nmap-zenmap:local

build:
	docker build -t $(IMAGE) .

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

check:
	sh -n rootfs/usr/local/bin/container-entrypoint
	docker compose config --quiet
	git diff --check

smoke: build
	docker run --rm --cap-add NET_RAW --cap-add NET_ADMIN $(IMAGE) nmap --version
	docker run --rm $(IMAGE) sh -c \
		"grep -q 'min(lvl, 5)' /usr/lib/python3.*/site-packages/zenmapGUI/Icons.py"
