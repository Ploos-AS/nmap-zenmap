# Security policy

## Supported versions

Security fixes are applied to the latest stable release and `edge`. Older
release tags are immutable and are not rebuilt in place.

## Reporting

Do not disclose a suspected vulnerability in a public issue. Contact the
maintainers privately through the authoritative Forgejo instance or the
security contact published by the Ploos-AS organization.

For vulnerabilities in Nmap or Zenmap themselves, follow the Nmap Project's
upstream reporting process.

## Deployment guidance

- Run only on networks where scanning is authorized.
- Do not expose noVNC port 6080 directly to the Internet.
- Put remote access behind an authenticated TLS reverse proxy or VPN.
- Traditional VNC authentication uses only the first eight password characters.
- Protect `.env`, `/config`, and saved scan output as sensitive data.
- Keep `NET_RAW` and `NET_ADMIN`; do not grant `--privileged`.
- Prefer an immutable version tag instead of `edge` for stable deployments.

Setting `ALLOW_INSECURE_VNC=1` disables VNC authentication and is intended only
for an already isolated environment with another access-control layer.
