# Contributing and releases

## Local checks

```sh
sh -n rootfs/usr/local/bin/container-entrypoint
docker compose config --quiet
docker build -t nmap-zenmap:test .
docker run --rm nmap-zenmap:test nmap --version
```

The image normally starts Zenmap, so the final command above is only a binary
smoke test when an alternate command is supported during development.

## Release

1. Update `NMAP_VERSION` in `Dockerfile` and `compose.yaml` when upstream Nmap
   changes.
2. Obtain and set `ZENMAP_WHEEL_SHA256` for a pinned production build.
3. Build and test on a host with Docker or Podman.
4. Merge to `main`; the workflow publishes `edge`.
5. Create and push a packaging tag such as `v7.991-1`.
6. Confirm both amd64 and arm64 in the GHCR manifest and verify the attestation.

Never commit `.env`, passwords, scan results, or the persistent `config/`
directory.

