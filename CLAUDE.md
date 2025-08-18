# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker image project that creates an Alpine Linux-based OpenHAB container specifically configured for Synology NAS systems. The main purpose is to enable Amazon Dash Button functionality through OpenHAB by providing the necessary network capabilities that are difficult to configure in Synology's GUI.

## Architecture

- **Base Image**: `openhab/openhab:latest-alpine`
- **Key Feature**: Network sniffing capabilities for Amazon Dash Button integration
- **Target Platform**: Synology NAS (but works on any Docker host)
- **Multi-architecture**: Supports both linux/amd64 and linux/arm64

## Core Problem Solved

The official OpenHAB Docker image requires `--cap-add NET_ADMIN --cap-add NET_RAW` for network sniffing, but Synology's Docker GUI doesn't expose these options. This image solves this by:

1. Using `setcap` to grant network capabilities directly to the Java binary
2. Creating symbolic links to resolve Java library loading issues that occur after granting capabilities
3. Working around the known Java bug with POSIX capabilities

## Development Commands

### Building the Docker Image
```bash
# Basic build
docker build -t openhab-synology .

# Build with specific tag
docker build -t andgineer/openhab-synology:latest .

# Multi-platform build (requires buildx)
docker buildx build --platform linux/amd64,linux/arm64 -t openhab-synology .
```

### Running Locally for Testing
```bash
# Standard run for testing
docker run --network=host --privileged openhab-synology

# Run with explicit port mapping (alternative to --network=host)
docker run -p 8080:8080 --privileged openhab-synology

# Run with interactive shell for debugging
docker run -it --network=host --privileged openhab-synology /bin/sh
```
Server will be available at `http://localhost:8080`

### Debugging Network Capabilities
```bash
# Check if capabilities are properly set on Java binary
docker run --rm openhab-synology getcap /usr/bin/java

# Verify symbolic links are created
docker run --rm openhab-synology ls -la /usr/lib/libjli.so /usr/lib/libjava.so /usr/lib/libjvm.so

# Check library dependencies
docker run --rm openhab-synology ldd /usr/bin/java
```

### CI/CD
- Automated builds are configured via GitHub Actions (`.github/workflows/dockerhub.yml`)
- Builds are triggered on pushes to master branch and pull requests
- Multi-architecture images (linux/amd64, linux/arm64) are automatically built and pushed to Docker Hub
- Docker Hub repository: `andgineer/openhab-synology`

## Key Files

- `Dockerfile`: Core container definition with capability grants and library fixes
- `README.md`: Detailed usage instructions and implementation rationale
- `.github/workflows/dockerhub.yml`: Automated build and deployment pipeline

## Technical Details

The Dockerfile handles two critical issues:
1. **Network Capabilities**: Uses `setcap 'cap_net_raw,cap_net_admin,cap_net_bind_service=+eip'` on Java binary
2. **Library Linking**: Creates symbolic links for libjli.so, libjava.so, and libjvm.so to resolve Java runtime issues after capability grants

The Java version has been upgraded to Java 17 (from Java 8 in earlier versions), reflected in the library paths.

## Synology-Specific Usage

For Synology NAS deployment:
1. Use the Docker Hub image: `andgineer/openhab-synology:latest`
2. Enable "Execute container using high privilege" in Synology Docker GUI
3. Enable "Use the same network as Docker host" in Synology Docker GUI
4. These settings are equivalent to the `--privileged` and `--network=host` flags

## Troubleshooting

### Common Issues
- **Java won't start after capability grant**: Check that symbolic links exist in `/usr/lib/`
- **Network sniffing not working**: Verify capabilities are set with `getcap /usr/bin/java`
- **Library loading errors**: Use `ldd /usr/bin/java` to check dependencies

### Verifying the Fix
The container should start without errors and OpenHAB should be able to detect Amazon Dash Button network traffic. The key indicators of success:
1. Java binary has network capabilities: `cap_net_raw,cap_net_admin,cap_net_bind_service=eip`
2. Required libraries are accessible via symbolic links
3. OpenHAB Amazon Dash Button binding can capture network packets