# Nmap + Zenmap Web

This image runs the official **Nmap** scanner and official **Zenmap** GTK
frontend, exposing the desktop through noVNC. It does not replace Zenmap with a
third-party web UI.

The default image compiles Nmap 7.991 from the official source archive and
installs the matching official Zenmap wheel from `nmap.org`.

One multi-architecture OCI image is published to GitHub Container Registry and
works with both Docker and Podman:

```text
ghcr.io/ploos-as/nmap-zenmap:latest
```

## Repositories

- Primary: `http://localhost:3000/Ploos-AS/nmap-zenmap`
- Public mirror: `https://github.com/Ploos-AS/nmap-zenmap`
- Container: `ghcr.io/ploos-as/nmap-zenmap`

Development, issues, pull requests, releases, and tags originate in Forgejo.
Forgejo push-mirrors Git refs to GitHub. The mirrored GitHub refs trigger the
container workflow and publish the image to GHCR. See
[`docs/FORGEJO_GITHUB_MIRROR.md`](docs/FORGEJO_GITHUB_MIRROR.md).

## Start it

```sh
cp .env.example .env
# Edit .env and choose a strong password.
docker compose pull
docker compose up -d
```

Open `http://SERVER-IP:6080/` and enter the password from `.env`.

To build locally instead, run `docker compose up -d --build`.

`network_mode: host` lets Nmap see the LAN without Docker bridge/NAT artifacts.
The web port is consequently configured with `WEB_PORT`, rather than a Compose
`ports` mapping.

## Command line

The same official Nmap build is available inside the running container:

```sh
docker exec -it zenmap nmap --version
docker exec -it zenmap nmap -sn 192.168.1.0/24
```

With Podman, replace `docker` with `podman`.

## Podman Quadlet

```sh
mkdir -p ~/.config/containers/systemd ~/.config/nmap-zenmap
cp podman/nmap-zenmap.container ~/.config/containers/systemd/
cp podman/nmap-zenmap.env.example ~/.config/nmap-zenmap/nmap-zenmap.env
nano ~/.config/nmap-zenmap/nmap-zenmap.env
systemctl --user daemon-reload
systemctl --user enable --now nmap-zenmap.service
```

The Quadlet uses `%h/.local/share/nmap-zenmap` for persistent state.

Only scan systems and networks you own or are authorized to test.

## Persistence

`./config` becomes Zenmap's home directory. Save scans under `/config/scans`
from Zenmap so they persist across container replacement.

## Permissions and scan fidelity

The GUI runs as `PUID:PGID` (default `1000:1000`), not root. Only the Nmap and
Nping executables receive packet-level file capabilities. Compose adds the
matching `NET_RAW` and `NET_ADMIN` capabilities to the container's bounding
set. This permits raw-packet features without making the browser-visible
desktop privileged. Environments that disable file capabilities can still use
TCP connect scans (`-sT`), but SYN scans, OS detection, and some discovery
methods will be limited.

Do not expose port 6080 directly to the public Internet. Keep it on the trusted
LAN or place it behind an authenticated HTTPS reverse proxy.

## Build arguments

| Argument | Default | Purpose |
| --- | --- | --- |
| `ALPINE_VERSION` | `3.22` | Alpine base version |
| `NMAP_VERSION` | `7.991` | Matching upstream Nmap/Zenmap release |
| `ZENMAP_WHEEL_SHA256` | empty | Optional required checksum when supplied |

For a reproducible production build, set `ZENMAP_WHEEL_SHA256` and pin the base
image by digest.

## Architecture

The Dockerfile is architecture-neutral and is intended for Buildx builds on
`linux/amd64` and `linux/arm64`. Nmap is compiled natively in the build stage.

## Publishing

GitHub Actions validates pull requests. Pushes to `main` publish the `edge`
tag. A Git tag such as `v7.991-1` publishes `7.991-1`, `7.991`, `7`, and
`latest`, plus immutable architecture manifests for amd64 and arm64. GitHub's
artifact attestation is emitted for tagged releases.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the release procedure.

## Upstream status

Nmap and Zenmap are official upstream components. This container, its noVNC
transport, and its packaging are community maintained and are not endorsed by
the Nmap Project.
