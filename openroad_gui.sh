#!/usr/bin/env bash
# ==============================================================================
# Launch OpenROAD Native Chip Design GUI (Nangate 45nm)
# ==============================================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODULE="${1:-riscv_core_bus}"
if [ "$MODULE" = "core" ]; then
    MODULE="riscv_core_bus"
elif [ "$MODULE" = "prng" ]; then
    MODULE="lfsr_nfsr_top"
fi

echo "=========================================================="
echo "  Launching OpenROAD Physical Design GUI for: $MODULE"
echo "=========================================================="

# Grant local display access for GUI rendering from Docker
xhost +local:docker >/dev/null 2>&1 || xhost +local:root >/dev/null 2>&1 || xhost + >/dev/null 2>&1 || true

docker run --rm \
  -v "${PWD}:/work" \
  -w /work \
  -e DISPLAY="${DISPLAY:-:0}" \
  -e TOP_MODULE="$MODULE" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --ipc=host \
  efabless/openlane:2023.09.07 \
  /build/bin/openroad -gui synth/scripts/load_design.tcl
