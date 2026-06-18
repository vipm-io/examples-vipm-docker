# Building a LabVIEW for Windows Container with VIPM

This example demonstrates how to build a Windows container with LabVIEW and VIPM installed.

This approach builds LabVIEW from scratch using NI Package Manager (NIPM) on a Windows Server Core base image, rather than using NI's official LabVIEW container image (which is Linux-based).

## Setting up and running the container

### Understand the contents of this folder:

- `.env.example` is a template file you will populate and save as `.env` which contains the environment variables that will be used by your running container.
- `docker-compose.yml` is a `docker compose` file that adds a little bit of structure to your docker configuration.
- `Dockerfile` defines the Windows container build process, including installation of NIPM, LabVIEW, and VIPM.
- `download_nipm.ps1` is a PowerShell script that downloads NI Package Manager.
- `LabVIEW.ini` is a configuration file for LabVIEW settings.

### Create a .env file with your VIPM Pro serial number information and Windows version.

Note: You can find your VIPM Pro serial number information on the https://www.vipm.io/account/ page.

Make a copy of the `.env.example` template file and save it as `.env`

**PowerShell:**
```powershell
Copy-Item .env.example .env
```

**Command Prompt:**
```cmd
copy .env.example .env
```

Edit the .env file and replace the placeholder values with your VIPM Pro serial number information.

```
VIPM_SERIAL_NUMBER=your-serial-number-here
VIPM_FULL_NAME=Your Full Name
VIPM_EMAIL=your.email@example.com

# Windows base image tag - use one of:
# WINDOWS_VERSION=windowsservercore-ltsc2022
# WINDOWS_VERSION=10.0.19042.1706-amd64
WINDOWS_VERSION=10.0.19042.1706-amd64
```

### Run (and build, if needed) the vipm-labview-windows container

**Note:** Building this container for the first time will take a significant amount of time (potentially 30+ minutes) as it downloads and installs NI Package Manager, LabVIEW 2022, and VIPM.

Run the following command on your host computer to build and then run your container, opening a PowerShell session within the container:

```powershell
docker compose run --rm vipm-labview-windows
```

## Using VIPM (to install packages in LabVIEW) from inside the running container

**Note:** The examples below show commands as they would be run inside the Windows container's PowerShell environment.

The following steps are useful for CI automation like GitHub actions. We intend to provide examples, which will likely end up in the .github/workflows/ directory of this repository. 

Note that some of these steps are subject to change, during the [VIPM 2026 Q1 Preview](https://docs.vipm.io/preview/) program, based on your feedback and issues we have discovered.

This information is provided to help you get started, based on the latest VIPM release, and we will be updating is as things progress.

### Activate vipm with a valid VIPM Pro serial number

Currently, to use VIPM inside of the container, it requires activating VIPM Pro. However, it is intended to work with VIPM Community Edition and VIPM Free Edition as well -- we are working on a fix.

**In the Windows container PowerShell:**
```powershell
vipm vipm-activate --serial-number "$env:VIPM_SERIAL_NUMBER" --name "$env:VIPM_FULL_NAME" --email "$env:VIPM_EMAIL"
```

```
PS C:\> vipm vipm-activate --serial-number "$env:VIPM_SERIAL_NUMBER" --name "$env:VIPM_FULL_NAME" --email "$env:VIPM_EMAIL" 
✓ Activation succeeded!
```

### Refresh vipm's package metadata from the vipm.io community repository

```powershell
vipm package-list-refresh
```

```
PS C:\> vipm package-list-refresh
✓ Package list refreshed successfully
```

### Verify that vipm can see labview and the installed packages

Use the `list --installed` command which will list the installed packages in LabVIEW. Note that if you have multiple LabVIEW versions installed, you will need to specify `--labview-version`

```powershell
vipm list --installed
```

```
PS C:\> vipm list --installed
Listing installed packages
Auto-detected LabVIEW 2022 (32-bit)
Found 0 packages:
```

### Install a package

Use the `install` command to install a package:

```powershell
vipm install oglib_boolean
```

```
PS C:\> vipm install oglib_boolean
Installing 1 package
Auto-detected LabVIEW 2022 (32-bit)
install: 100 (1/1; 100%) - Installation complete
✓ Installed 1 package from LabVIEW 2022 (32-bit) in 23.5s
Successfully installed 1 package:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
```

### List the installed packages

Use `list --installed` command to list the installed packages:

```powershell
vipm list --installed
```

```
PS C:\> vipm list --installed
Listing installed packages
Auto-detected LabVIEW 2022 (32-bit)
Found 1 packages:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
```

### Uninstall a package

Use the `uninstall` command to uninstall a package from LabVIEW:

```powershell
vipm uninstall oglib_boolean
```

```
PS C:\> vipm uninstall oglib_boolean
Launching VIPM...
Uninstalling 1 package
Auto-detected LabVIEW 2022 (32-bit)
validate: 100 (1/1; 100%) - Validation complete
Uninstalling oglib_boolean v6.0.0.9...
uninstall: 100 (1/1; 100%) - Uninstall complete
✓ Uninstalled 1 package from LabVIEW 2022 (32-bit) in 10.3s
Successfully uninstalled 1 package:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
```

### Install all packages in a VI Package Configuration `.vipc` file

Use can use the `install` command to install a `.vipc` file:

```powershell
vipm install path\to\project.vipc
```


### Install multiple packages

Use the `install` command to install multiple packages:

```powershell
vipm install oglib_boolean oglib_numeric
```

```
PS C:\> vipm install oglib_boolean oglib_numeric
Installing 2 packages
Auto-detected LabVIEW 2022 (32-bit)
install: 0 (0/1; 0%) - Installing packages
install: 100 (1/1; 100%) - Installation complete
✓ Installed 2 packages from LabVIEW 2022 (32-bit) in 28.5s
Successfully installed 2 packages:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
  OpenG Numeric Library (oglib_numeric v6.0.0.9)
```

### Sanity check OpenG package installation

We know from past experience that the OpenG packages are installed in the LabVIEW user.lib directory. For this Windows container setup, LabVIEW 2022 (32-bit) is installed at `C:\Program Files (x86)\National Instruments\LabVIEW 2022`, so we can check the installation with:

```powershell
Get-ChildItem "C:\Program Files (x86)\National Instruments\LabVIEW 2022\user.lib\_OpenG.lib"
```

```
PS C:\> Get-ChildItem "C:\Program Files (x86)\National Instruments\LabVIEW 2022\user.lib\_OpenG.lib"

    Directory: C:\Program Files (x86)\National Instruments\LabVIEW 2022\user.lib\_OpenG.lib

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        11/18/2025   9:19 PM                boolean
d-----        11/18/2025   9:19 PM                numeric
```

### Building a VI Package from a .vipb VI package build spec

Use the `build` command to build your package:

```powershell
vipm build path\to\your_package.vipb
```

This will then build your package.
