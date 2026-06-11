# examples-vipm-docker

This repository contains Docker examples demonstrating how to use VIPM (VI Package Manager) with LabVIEW in containerized environments.

## Repository Structure

The `examples/` directory contains various examples of using VIPM with Docker containers. Each example includes its own documentation and configuration files.

## Available Examples

### Using NI's Official LabVIEW Container with VIPM (Linux)

This example demonstrates how to use VIPM with NI's official LabVIEW **Linux** container image.

**Location:** [examples/ni_labview_official_container_with_vipm](examples/ni_labview_official_container_with_vipm)

For detailed setup instructions and usage, see the [README.md](examples/ni_labview_official_container_with_vipm/README.md) in the example directory.

### Using NI's Official LabVIEW 2026 Windows Container with VIPM

This example demonstrates how to use VIPM with NI's official LabVIEW **Windows** container image. It runs on a Windows host with Docker configured for Windows containers, and is verified in CI using the GitHub Actions `windows-latest` runner.

**Location:** [examples/ni_labview_2026_windows_container_with_vipm](examples/ni_labview_2026_windows_container_with_vipm)

For detailed setup instructions and usage, see the [README.md](examples/ni_labview_2026_windows_container_with_vipm/README.md) in the example directory.

---

You can find more information about NI's official container images here:

- https://hub.docker.com/r/nationalinstruments/labview
- https://github.com/ni/labview-for-containers
