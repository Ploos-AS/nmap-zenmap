# Release validation

## Static checks

```sh
sh -n rootfs/usr/local/bin/container-entrypoint
docker compose config --quiet
git diff --check
```

## Build and CLI smoke test

```sh
docker build -t nmap-zenmap:test .
docker run --rm --cap-add NET_RAW --cap-add NET_ADMIN \
  nmap-zenmap:test nmap --version
```

## Browser smoke test

Start the container using the README quick start and confirm:

1. Docker reports `running / healthy`.
2. noVNC accepts the configured password.
3. Zenmap opens and reports version 7.991.
4. Closing Zenmap relaunches it without restarting the container.
5. An authorized localhost scan completes.
6. Selecting the scanned host does not trigger the `vl_6_logo` crash.
7. Disconnecting and reconnecting noVNC preserves the desktop session.

## Published manifest

```sh
docker buildx imagetools inspect ghcr.io/ploos-as/nmap-zenmap:0.1.0
```

Confirm both `linux/amd64` and `linux/arm64` manifests before announcing the
release.
