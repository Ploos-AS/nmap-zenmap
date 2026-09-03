# Nmap + Zenmap Web

An unofficial multi-architecture OCI container built from the official Nmap
scanner and matching official Zenmap GTK frontend from `nmap.org`. The desktop
is exposed in a browser with noVNC; Zenmap is not replaced by another web UI.

Current upstream version: **Nmap/Zenmap 7.991**

```text
ghcr.io/ploos-as/nmap-zenmap:latest
```

Supported platforms are `linux/amd64` and `linux/arm64`. Docker and Podman are
supported.

> Only scan systems and networks that you own or are authorized to test.

## Quick start

```sh
mkdir -p nmap-zenmap/config
cd nmap-zenmap
docker run -d \
  --name zenmap \
  --network host \
  --cap-add NET_RAW \
  --cap-add NET_ADMIN \
  -e TZ=Europe/Oslo \
  -e WEB_PORT=6080 \
  -e VNC_PASSWORD='changeMe' \
  -e PUID="$(id -u)" \
  -e PGID="$(id -g)" \
  -v "$PWD/config:/config" \
  --restart unless-stopped \
  ghcr.io/ploos-as/nmap-zenmap:latest
```

Open `http://localhost:6080/vnc.html?autoconnect=1&resize=remote`.
Replace `localhost` with the server address from another LAN machine.

## Docker Compose

```sh
git clone https://github.com/Ploos-AS/nmap-zenmap.git
cd nmap-zenmap
cp .env.example .env
# Edit .env before continuing.
docker compose pull
docker compose up -d
docker compose ps
```

Build the checkout locally with `docker build -t nmap-zenmap:local .`.

## Podman Quadlet

```sh
mkdir -p ~/.config/containers/systemd ~/.config/nmap-zenmap
cp podman/nmap-zenmap.container ~/.config/containers/systemd/
cp podman/nmap-zenmap.env.example ~/.config/nmap-zenmap/nmap-zenmap.env
chmod 600 ~/.config/nmap-zenmap/nmap-zenmap.env
mkdir -p ~/.local/share/nmap-zenmap
# Edit the environment file before continuing.
systemctl --user daemon-reload
systemctl --user enable --now nmap-zenmap.service
```

Rootless Podman may limit raw-packet operations on some hosts. TCP connect
scans (`-sT`) remain available when raw networking is unavailable.

## Verify the deployment

```sh
docker inspect --format \
  '{{.State.Status}} / {{if .State.Health}}{{.State.Health.Status}}{{end}}' \
  zenmap
docker exec zenmap nmap --version
docker exec zenmap sh -c \
  "grep -n 'min(lvl, 5)' /usr/lib/python3.*/site-packages/zenmapGUI/Icons.py"
```

The container should report `running / healthy`. Closing the Zenmap window
relaunches Zenmap without terminating the noVNC desktop.

## Command-line use

```sh
docker exec -it zenmap nmap -sn 192.168.1.0/24
docker exec -it zenmap nmap -sT -sV 192.168.1.10
```

An ephemeral CLI container needs the same packet capabilities:

```sh
docker run --rm --cap-add NET_RAW --cap-add NET_ADMIN \
  ghcr.io/ploos-as/nmap-zenmap:latest nmap --version
```

## Configuration

`WEB_PORT` defaults to `6080`, `VNC_PORT` to internal port `5900`, `PUID` and
`PGID` to `1000`, `GEOMETRY` to `1440x900`, and `DEPTH` to `24`.
`VNC_PASSWORD` is required unless `ALLOW_INSECURE_VNC=1` is explicitly set.

Traditional VNC authentication uses only the first eight password characters.
Use exactly eight random characters. This authentication is not a substitute
for HTTPS and proper network access control.

## Persistence and privileges

`/config` is Zenmap's home directory. Save scans under `/config/scans` to keep
them across replacement. Startup adjusts the mounted directory to `PUID:PGID`.

Host networking avoids bridge/NAT artifacts while scanning the LAN. It also
means `WEB_PORT` listens directly on the host; Compose port mappings do not
apply.

The desktop runs as `PUID:PGID`, not root. Nmap and Nping receive scoped packet
capabilities, while the container receives `NET_RAW` and `NET_ADMIN`. Do not
add `--privileged`. Without these capabilities, SYN scans, OS detection and
some discovery methods are limited.

## Security

- Never expose port 6080 directly to the public Internet.
- Restrict access with a firewall or an authenticated HTTPS reverse proxy.
- Treat scan results as sensitive and protect the persistent config directory.
- Prefer immutable release tags in long-lived deployments.
- Never commit `.env`, passwords, or `config/`.

See [SECURITY.md](SECURITY.md) for reporting and operational guidance.

## Image tags and releases

- `edge`: latest successful build from `main`.
- `latest`: most recent stable tagged release.
- `0.1.0`: immutable release tag for `v0.1.0`.
- `0.1`: moving tag for the latest compatible `0.1.x` release.

Tagged releases include SBOM/provenance metadata and a GitHub artifact
attestation. See [CHANGELOG.md](CHANGELOG.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

## Upstream and repositories

Forgejo is authoritative and GitHub is the public distribution mirror:

- Forgejo: `http://localhost:3000/Ploos-AS/nmap-zenmap`
- GitHub: <https://github.com/Ploos-AS/nmap-zenmap>
- GHCR: `ghcr.io/ploos-as/nmap-zenmap`

Nmap and Zenmap are official upstream components. This container, its noVNC
transport, packaging, and the documented Zenmap 7.991 icon workaround are
community maintained and are not endorsed by the Nmap Project.
