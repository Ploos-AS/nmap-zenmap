# Changelog

All notable container-packaging changes are documented here. Upstream Nmap and
Zenmap changes are documented by the Nmap Project.

## [0.1.0] - 2026-09-03

First stable container release.

### Added

- Official Nmap 7.991 built from the upstream source archive.
- Matching official Zenmap 7.991 Python wheel.
- Browser access through Xvfb, Openbox, x11vnc, websockify, and noVNC.
- Multi-architecture `linux/amd64` and `linux/arm64` images on GHCR.
- Docker Compose and rootless Podman Quadlet examples.
- Persistent Zenmap state and scan output under `/config`.
- Non-root desktop with scoped Nmap/Nping packet capabilities.
- Healthcheck, SBOM, provenance, and tagged-release attestations.

### Fixed

- Preserve the complete Zenmap wheel filename required by pip.
- Build Nmap with its bundled Lua implementation.
- Install the PyCairo and PyXDG runtime dependencies.
- Use isolated X display `:99` and correctly initialize its socket directory.
- Preserve VNC password-file ownership for the configured UID/GID.
- Keep noVNC alive and relaunch Zenmap when its window is closed.
- Bind the raw VNC listener to container loopback only.
- Work around upstream Zenmap 7.991 `vl_6_logo` result-view crash.
- Force the entrypoint executable bit during image construction.

[0.1.0]: https://github.com/Ploos-AS/nmap-zenmap/releases/tag/v0.1.0
