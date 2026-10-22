#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

export ALIBUILD_WORK_DIR="/data/alice/aenderic/alice/sw"
source /data/alice/aenderic/o2physics_env.sh

o2-analysis-cf-flow-pid-cme \
  -b \
  --configuration "json://$SCRIPT_DIR/configuration_local.json" \
  --aod-file "$SCRIPT_DIR/AO2D_small_LHC23zzh_with_input_local.root" \
  --shm-segment-size 4000000000 \
  --aod-memory-rate-limit 200000000