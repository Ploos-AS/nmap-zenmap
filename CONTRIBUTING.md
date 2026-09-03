# Contributing and releases

## Local checks

```sh
sh -n rootfs/usr/local/bin/container-entrypoint
make check
make smoke IMAGE=nmap-zenmap:test
```

Complete the browser tests in [`docs/TESTING.md`](docs/TESTING.md) before a
stable release.

## Release

1. Update `NMAP_VERSION` in `Dockerfile` when upstream Nmap changes.
2. Obtain and set `ZENMAP_WHEEL_SHA256` for a pinned production build.
3. Update `CHANGELOG.md` and complete the release validation checklist.
4. Push to Forgejo `main`; its GitHub mirror publishes `edge` after tests pass.
5. Create and push an annotated SemVer tag such as `v0.1.0`.
6. Create the Forgejo Release from that existing tag using the matching file in
   `docs/releases/` as its release notes.
7. The mirrored tag makes GitHub Actions publish `0.1.0`, `0.1`, and `latest`,
   emit the attestation, and create the mirrored GitHub Release.
8. Confirm amd64 and arm64 in the GHCR manifest and test a clean pull.

Never commit `.env`, passwords, scan results, or the persistent `config/`
directory.
