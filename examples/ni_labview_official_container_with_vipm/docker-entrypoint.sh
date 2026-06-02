#!/usr/bin/env bash
# Source the VIPM/LabVIEW environment bootstrap so the headless X server and
# Runtime Engine markers are in place before any command runs, then hand off
# to the container's command (CMD or `docker run` arguments).
source /usr/local/jki/vipm/support/docker-display.sh

exec "$@"
