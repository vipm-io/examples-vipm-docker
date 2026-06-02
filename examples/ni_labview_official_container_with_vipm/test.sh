#!/usr/bin/env bash
# Build the LabVIEW + VIPM image and drop into an interactive shell inside a
# fresh container. The entrypoint sources docker-display.sh on the way in, so
# the headless X server and Runtime Engine markers are ready before the prompt
# appears.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE="${IMAGE:-ni-labview-vipm:test}"

docker build -t "$IMAGE" .

docker run --rm -it "$IMAGE"
