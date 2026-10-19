#!/bin/bash
set -eo pipefail

ANALYSIS_DIR="/data/alice/aenderic/CME_verify_results"
export ALIBUILD_WORK_DIR="/data/alice/aenderic/alice/sw"

echo "Host: $(hostname)"

source /data/alice/aenderic/o2physics_env.sh

export JALIEN_TOKEN_CERT=/data/alice/aenderic/GridTokens/tokencert_11900.pem
export JALIEN_TOKEN_KEY=/data/alice/aenderic/GridTokens/tokenkey_11900.pem

echo "Checking executable..."
command -v o2-analysis-cf-flow-pid-cme

cd "$ANALYSIS_DIR"
exec ./run_local.sh