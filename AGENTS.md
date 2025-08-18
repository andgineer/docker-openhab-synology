# Repository Guidelines

## Project Structure & Module Organization
- Root: `Dockerfile` (image build), `README.md` (usage), `AGENTS.md` (this guide).
- CI: `.github/workflows/dockerhub.yml` builds and pushes multi-arch images.
- Config: Local dev artifacts live outside the image; no app source tree or tests in-repo.

## Build, Test, and Development Commands
- Build image: `docker build -t andgineer/openhab-synology:dev .`
- Run locally: `docker run --network=host --privileged andgineer/openhab-synology:dev`
- Tag + push (example):
  - `docker tag andgineer/openhab-synology:dev <user>/openhab-synology:latest`
  - `docker push <user>/openhab-synology:latest`
- CI build (on PR/merge to `master`) is handled by GitHub Actions; no local script required.

## Coding Style & Naming Conventions
- Dockerfile: Alpine-based, use chained `RUN` with `&&` and line continuations `\`.
- Keep layers minimal; prefer explicit paths (e.g., `/usr/lib/jvm/java-17-openjdk/...`).
- YAML (CI): two-space indentation, lower-kebab for job/step names.
- Tags: use `latest` for the default image; add explicit version tags when applicable.

## Testing Guidelines
- Manual validation: build and run locally, confirm OpenHAB responds on `http://localhost:8080`.
- Synology-specific: ensure container runs with host networking and privileged mode.
- Smoke check inside container: `ldd /usr/bin/java` and verify required libs are resolved; Dash binding can sniff network.

## Commit & Pull Request Guidelines
- Commits: short imperative subject (e.g., "upgrade Java path", "fix README link").
- PRs: include purpose, notable changes, testing notes (local run/commands), and link to issues.
- CI: ensure workflow passes; if changing Dockerfile or CI, explain impact on tags/platforms.

## Security & Configuration Tips
- Capabilities: image grants `cap_net_raw`, `cap_net_admin`, `cap_net_bind_service` to Java; avoid broad privilege in Dockerfile beyond these.
- Secrets: GitHub Actions require `DOCKER_HUB_USERNAME` and `DOCKER_HUB_ACCESS_TOKEN` repository secrets.
- Synology: use host network and high-privilege mode via GUI; do not embed credentials in the image.
