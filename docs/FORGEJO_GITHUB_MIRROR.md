# Forgejo primary with a GitHub mirror

Forgejo is authoritative. GitHub is a public, read-only-by-convention mirror
whose Actions workflow publishes the OCI image to GHCR.

## 1. Create empty repositories

Create these repositories without README, license, or `.gitignore` files:

- Forgejo: `Ploos-AS/nmap-zenmap`
- GitHub: `Ploos-AS/nmap-zenmap`

Make the GitHub repository public. Do not initialize either repository because
this project already has Git history.

## 2. Push the initial repository to Forgejo

The included Git repository has `origin` configured for Forgejo:

```sh
git push -u origin main
```

## 3. Create a repository-scoped GitHub token

In GitHub, create a fine-grained personal access token with:

- Resource owner: `Ploos-AS`
- Repository access: only `nmap-zenmap`
- Repository permission: **Contents — Read and write**

No Packages permission is needed for the mirror. The GitHub Actions workflow
uses its own repository `GITHUB_TOKEN` to publish GHCR packages.

## 4. Configure the Forgejo push mirror

In the Forgejo repository, open **Settings → Repository → Mirror Settings** and
add a push mirror:

```text
https://github.com/Ploos-AS/nmap-zenmap.git
```

Use your GitHub username and the fine-grained token as the password. Enable
sync on commit and include all branches and tags. Do not enable force-push
unless deliberately recovering a diverged mirror.

After saving, run **Synchronize Now** once and confirm that `main` appears on
GitHub at the same commit as Forgejo.

## 5. Protect directionality

- Treat Forgejo as the only writable development origin.
- Do not merge pull requests or commit directly on GitHub.
- Put the authoritative issue tracker URL in the GitHub repository description.
- Protect `main` in Forgejo according to the desired review policy.

GitHub cannot technically make a normal public repository read-only while
still letting the Forgejo token push. This convention and branch protection
prevent accidental divergence.

## 6. Publish the first image

A mirrored push to `main` publishes `edge`. Create and push the release tag:

```sh
git tag -a v0.1.0 -m "Nmap + Zenmap Web v0.1.0"
git push origin v0.1.0
```

Forgejo mirrors the tag. GitHub Actions then publishes `latest`, `0.1.0`, and
`0.1` to `ghcr.io/ploos-as/nmap-zenmap`, emits an attestation, and creates the
mirrored GitHub Release.

In Forgejo, create the release from the existing tag and use
`docs/releases/v0.1.0.md` as the release notes.

After first publication, set the GHCR package visibility to public and connect
the package to the GitHub repository if GitHub has not linked it automatically.

## Verification

```sh
git ls-remote http://localhost:3000/Ploos-AS/nmap-zenmap.git refs/heads/main
git ls-remote https://github.com/Ploos-AS/nmap-zenmap.git refs/heads/main
```

The two commit IDs must match.
