#!/usr/bin/env bash
# Bootstrap a headless X display + LabVIEW container marker so the
# LabVIEW Runtime Engine (used by `vipm install` and vipm-desktop)
# can initialize inside this Docker container.
#
# The X server always lives on display :99. DISPLAY handling:
#   - If DISPLAY is already :99 (e.g. Dockerfile `ENV DISPLAY=:99` or
#     `docker run -e DISPLAY=:99`), nothing is exported and the script is
#     safe to run either sourced or as a subprocess.
#   - If DISPLAY is unset or points elsewhere, the script exports
#     DISPLAY=:99 ? which only persists in your shell when sourced:
#
#       source ./bootstrap-display.sh    # or:  . ./bootstrap-display.sh
#
#     A conflicting non-:99 value is overridden, with a warning.
#
# Safe to invoke multiple times ? skips Xvfb if one is already running.

# `set -e` is a shell option, so sourcing this script would otherwise leak
# `errexit` into the caller's interactive shell. Capture the caller's
# setting now and restore it on the way out.
_saved_errexit=$(set +o | grep errexit)
set -e

# This container's headless X server always lives on :99, and the rest of
# the LabVIEW container tooling assumes it. TARGET_DISPLAY is the single
# source of truth for both the Xvfb server and the exported DISPLAY.
readonly TARGET_DISPLAY=":99"

# A pre-set DISPLAY pointing somewhere other than :99 conflicts with the
# server this script starts. Flag it loudly; it is overridden below.
if [ -n "${DISPLAY:-}" ] && [ "$DISPLAY" != "$TARGET_DISPLAY" ]; then
    echo "WARNING: DISPLAY=$DISPLAY conflicts with this container's X server," >&2
    echo "         which always runs on $TARGET_DISPLAY ? overriding to $TARGET_DISPLAY." >&2
fi

# Ensure DISPLAY ends up as :99. If it is already correct there is nothing
# to export and the script is safe to run sourced or as a subprocess.
# Otherwise it must export ? which only reaches the calling shell when the
# script is sourced, since a subprocess cannot mutate its parent's env.
if [ "${DISPLAY:-}" != "$TARGET_DISPLAY" ]; then
    # `return` only succeeds in a sourced script; the subshell keeps the
    # failure non-fatal under `set -e`.
    if ! (return 0 2>/dev/null); then
        script_path="${BASH_SOURCE:-$0}"
        echo "ERROR: DISPLAY is not $TARGET_DISPLAY and $script_path was run as a" >&2
        echo "       subprocess, so it cannot export DISPLAY into your shell. Either:" >&2
        echo >&2
        echo "         source $script_path    # export DISPLAY into this shell" >&2
        echo >&2
        echo "       or set DISPLAY=$TARGET_DISPLAY in the container before invoking it" >&2
        echo "       (Dockerfile 'ENV DISPLAY=$TARGET_DISPLAY' or 'docker run -e DISPLAY=$TARGET_DISPLAY')." >&2
        exit 1
    fi

    export DISPLAY="$TARGET_DISPLAY"
fi


# /usr/local/natinst/LabVIEW-2026-64/labviewprofull &

# Start Xvfb if it is not already running. If it is already running, assume it is correctly configured for this container and do nothing.
if ! pgrep -x Xvfb > /dev/null; then
    Xvfb "$TARGET_DISPLAY" -screen 0 1280x720x24 -ac +extension GLX +render -noreset \
        > /tmp/xvfb.log 2>&1 &
fi
# Writing this marker file is critical and if if it is not present, the LabVIEW Runtime Engine (required by vipm) may not start properly.
mkdir -p /tmp/natinst && echo "1" > /tmp/natinst/LVContainer.txt
# Start Xvfb before the LabVIEW Runtime Engine initializes, which happens on the first `vipm` command.
echo "$(pgrep -x Xvfb > /dev/null && echo "Xvfb running (DISPLAY=$TARGET_DISPLAY)" || echo "WARNING: Xvfb is required by vipm, but failed to start; DISPLAY=$DISPLAY may not work. Check /tmp/xvfb.log for details.")"

# Restore the caller's errexit setting (only observable when sourced).
eval "$_saved_errexit"
unset _saved_errexit
