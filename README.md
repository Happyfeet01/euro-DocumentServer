<!--
SPDX-FileCopyrightText: 2026 Euro-Office contributors
SPDX-License-Identifier: AGPL
-->

# euro-DocumentServer

Community build of [Euro-Office DocumentServer](https://github.com/Euro-Office/DocumentServer), maintained as a small downstream fork for self-hosted deployments such as Nextcloud.

The main reason for this fork is to provide an easy-to-consume Docker image based on Euro-Office, including the mobile web editor work maintained by the Euro-Office project, without relying on the commercial ONLYOFFICE mobile-editing edition.

> This project is not affiliated with or endorsed by ONLYOFFICE or Euro-Office. It is a downstream AGPL-licensed fork of Euro-Office DocumentServer.

## Docker image

Images are built from this repository with GitHub Actions and published to GitHub Container Registry:

```bash
docker pull ghcr.io/happyfeet01/euro-documentserver:latest
```

Example:

```bash
docker run -d \
  --name euro-documentserver \
  --restart unless-stopped \
  -p 8080:80 \
  -e JWT_ENABLED=true \
  -e JWT_SECRET='replace-with-a-long-random-secret' \
  ghcr.io/happyfeet01/euro-documentserver:latest
```

For a Nextcloud deployment, put the DocumentServer behind HTTPS/reverse proxy as usual and configure the same JWT secret in the Nextcloud Office/ONLYOFFICE connector.

## Builds

The fork intentionally keeps changes small so that updates from Euro-Office can be merged with as little friction as possible.

The GitHub workflow builds the standalone DocumentServer for:

- amd64
- arm64

A push to `main` publishes `:latest`. Git tags beginning with `v` publish a matching version tag and also update `:latest`.

## Upstream

Upstream project:

- https://github.com/Euro-Office/DocumentServer
- https://github.com/Euro-Office/

Euro-Office itself is based on the open-source ONLYOFFICE DocumentServer codebase.

## License

GNU Affero General Public License v3.0. Existing copyright, attribution and license notices from upstream are retained.
