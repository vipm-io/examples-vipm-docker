# Using NI's Official LabVIEW 2026 Windows Container with VIPM

This example demonstrates how to use VIPM with NI's official LabVIEW **Windows** container image (`nationalinstruments/labview:latest-windows`).

For more information about NI's official container images:

- https://hub.docker.com/r/nationalinstruments/labview
- https://github.com/ni/labview-for-containers

## Prerequisites

- A **Windows host** with Docker installed and configured for **Windows containers**
- To switch Docker to Windows containers, see [Microsoft's guide](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-10-and-windows-11-2)

## Setting up and running the container

### Understand the contents of this folder

- `.env.example` is a template file you will populate and save as `.env` with your VIPM Pro credentials.
- `docker-compose.yml` is a `docker compose` file that configures your container.
- `Dockerfile` defines the container image, starting from NI's official Windows LabVIEW image and adding VIPM.

### Create a .env file with your VIPM Pro serial number information

You can find your VIPM Pro serial number on the https://www.vipm.io/account/ page.

Make a copy of the `.env.example` template and save it as `.env`:

```powershell
copy .env.example .env
```

Edit the `.env` file with your VIPM Pro credentials:

```
VIPM_SERIAL_NUMBER=your-serial-number-here
VIPM_FULL_NAME=Your Full Name
VIPM_EMAIL=your.email@example.com
```

### Run (and build, if needed) the vipm-labview container

Run the following command on your Windows host to build and then run the container, opening a PowerShell session inside it:

```powershell
docker compose run --rm vipm-labview
```

## Using VIPM (to install packages in LabVIEW) from inside the running container

The following steps are useful for CI automation like GitHub Actions. See the `.github/workflows/` directory of this repository for workflow examples.

### Activate VIPM with a valid VIPM Pro serial number

Currently, using VIPM inside a container requires activating VIPM Pro. Support for VIPM Community Edition and VIPM Free Edition is in progress.

```powershell
vipm activate --serial-number "$env:VIPM_SERIAL_NUMBER" --name "$env:VIPM_FULL_NAME" --email "$env:VIPM_EMAIL"
```

### Refresh package metadata

```powershell
vipm package-list-refresh
```

### List installed packages

Use `list --installed` to see what's installed in LabVIEW. If you have multiple LabVIEW versions, specify `--labview-version`.

```powershell
vipm list --installed
```

### Install a package

```powershell
vipm install oglib_boolean
```

### Install packages from a .vipc file

```powershell
vipm install path\to\project.vipc
```

### Install multiple packages

```powershell
vipm install oglib_boolean oglib_numeric
```

### Uninstall a package

```powershell
vipm uninstall oglib_boolean
```

### Build a VI Package from a .vipb build spec

```powershell
vipm build path\to\your_package.vipb
```

## Using LabVIEWCLI in the container

The Windows container includes LabVIEWCLI for headless LabVIEW operations. All LabVIEWCLI commands **must** include the `-Headless` flag (required for LabVIEW 2026 Q1 and later):

```powershell
LabVIEWCLI -OperationName MassCompile -DirectoryToCompile "C:\Program Files\National Instruments\LabVIEW 2026\examples\Arrays" -Headless
```

Without `-Headless`, LabVIEW may launch in UI mode, causing activation prompts or other popups that block execution indefinitely in CI environments.

## Notes

- This container image is ~10 GB — initial pulls will take some time.
- The container is designed for headless automation and CI/CD. The LabVIEW GUI is not available.
- Windows containers can only run on Windows hosts.
