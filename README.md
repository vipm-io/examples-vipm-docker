# examples-vipm-docker

This repository contains docker examples.

## Using NI's offical LabVIEW Container

You can find more information about NI's official container image, as well as some other examples, here:

- https://hub.docker.com/r/nationalinstruments/labview
- https://github.com/ni/labview-for-containers

### Setting up and running the container

#### Change directories into the example

`cd examples/ni_labview_official_container_with_vipm`

#### Understand the contents of this folder:

- `.env.example` is a template file you will populate and save as `.env` which contains the environment variables that will be used by your running container.
- `docker-compose.yml` is a `docker compose` file that adds a little bit of structure to your docker configuration.
- `Dockerfile` the specific commands (and base/starting container) for building your container.

#### Create a .env file with your VIPM Pro serial number information.

Note: You can your VIPM Pro serial number information on the https://www.vipm.io/account/ page.

Make a copy of the `.env.example` template file and save it as `.env`

`cp .env.example .env`

Edit the .env placeholder values with VIPM Pro serial number information.

```
VIPM_SERIAL_NUMBER=your-serial-number-here
VIPM_FULL_NAME=Your Full Name
VIPM_EMAIL=your.email@example.com
```

#### Run (and build, if needed) the vipm-labview container
Run the following command on your host computer, to build and then run your container, opening a bash shell within the container:

`docker compose run --rm vipm-labview`

### Using VIPM (to install packages in LabVIEW) from inside the running container

The following steps are useful for CI automation like GitHub actions.  We intend to provide examples, which will likely end up in the .github/workflows/ directory of this repository. 

Note that some of these steps are subject to change, during the [VIPM 2026 Q1 Preview](https://docs.vipm.io/preview/) program, based on your feedback and issues we have discovered.

This information is provided to help you get started, based on the latest VIPM release, and we will be updating is as things progress.

#### Activate vipm with a valid VIPM Pro serial number

Currently, to use VIPM inside of the container, it requires activating VIPM Pro.  However, it is intended to work with VIPM Community Edition and VIPM Free Edition as well -- we are working on a fix.

`vipm vipm-activate --serial-number "$VIPM_SERIAL_NUMBER" --name "$VIPM_FULL_NAME" --email "$VIPM_EMAIL"`

```
root@52d5d86e2385:/# vipm vipm-activate --serial-number "$VIPM_SERIAL_NUMBER" --name "$VIPM_FULL_NAME" --email "$VIPM_EMAIL" 
✓ Activation succeeded!
```

#### Refresh vipm's package metadata from the vipm.io community repository

```
root@52d5d86e2385:/# vipm package-list-refresh
✓ Package list refreshed successfully
```

#### Verify that vipm can see labview and the installed packages

use the `list --installed` command which will list the installed packages in LabVIEW. Note that if you have multiple LabVIEW versions installed, you will need to specify `--labview-version`

`vipm list --installed`

```
root@52d5d86e2385:/# vipm list --installed
Listing installed packages
Auto-detected LabVIEW 2025 (64-bit)
Found 0 packages:
```

#### Install a package

Use the `install` command to install a package:

`vipm install oglib_boolean`


```
root@52d5d86e2385:/# vipm install oglib_boolean
Installing 1 package
Auto-detected LabVIEW 2025 (64-bit)
install: 100 (1/1; 100%) - Installation complete
✓ Installed 1 package from LabVIEW 2025 (64-bit) in 23.5s
Successfully installed 1 package:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
```

#### List the installed packages

use `list --installed` command to list the installed packages:

`vipm list --installed`

```
root@52d5d86e2385:/# vipm list --installed
Listing installed packages
Auto-detected LabVIEW 2025 (64-bit)
Found 1 packages:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
```

#### Uninstall a package

Use the `uninstall` command to uninstall a package from LabVIEW:

`vipm uninstall oglib_boolean`

```
root@52d5d86e2385:/# vipm uninstall oglib_boolean
Launching VIPM...
Uninstalling 1 package
Auto-detected LabVIEW 2025 (64-bit)
validate: 100 (1/1; 100%) - Validation complete
Uninstalling oglib_boolean v6.0.0.9...
uninstall: 100 (1/1; 100%) - Uninstall complete
✓ Uninstalled 1 package from LabVIEW 2025 (64-bit) in 10.3s
Successfully uninstalled 1 package:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
```

#### Install all packages in a VI Package Configuration `.vipc` file

Use can use the `install` to install a `.vipc` file:

`vipm install path/to/project.vipc`


#### Install multiple packages

Use the `install` command to install a package:

`vipm install oglib_boolean oglib_numeric`

```
root@52d5d86e2385:/# vipm install oglib_boolean oglib_numeric
Installing 2 packages
Auto-detected LabVIEW 2025 (64-bit)
install: 0 (0/1; 0%) - Installing packages
install: 100 (1/1; 100%) - Installation complete
✓ Installed 2 packages from LabVIEW 2025 (64-bit) in 28.5s
Successfully installed 2 packages:
  OpenG Boolean Library (oglib_boolean v6.0.0.9)
  OpenG Numeric Library (oglib_numeric v6.0.0.9)
```

#### Sanity check OpenG package installation

We know from past experience that the OpenG packages are installed in the `/usr/local/natinst/LabVIEW-2025-64/user.lib/` directory, so we'll list the contents of that directory with the `ls -al /usr/local/natinst/LabVIEW-2025-64/user.lib/_OpenG.lib` command to sanity check that the installation was successful:

```
root@52d5d86e2385:~# ls -al /usr/local/natinst/LabVIEW-2025-64/user.lib/_OpenG.lib
total 16
drwxr-xr-x 4 root root 4096 Nov 11 21:19 .
drwxr-xr-x 1 root root 4096 Nov 11 21:19 ..
drwxr-xr-x 3 root root 4096 Nov 11 21:19 boolean
drwxr-xr-x 3 root root 4096 Nov 11 21:19 numeric
```

#### Building a VI Package from a .vipb VI package build spec

Note that this is not fully functional (due to some errors) on Linux, but we're working on it.

Use the `build` command to build your package.

`vipm build path/to/your_package.vipb`

This will then build your package.
