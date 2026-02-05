#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
JOBS=6
SKIP_DEPS="${SKIP_DEPS:-0}"

usage() {
  echo "Usage: $0 [-j <threads>] [target ...]"
  echo "  -j <threads>   set build parallelism (default: 6)"
  echo "  target ...     optional cmake build targets (default: all)"
  echo "Examples:"
  echo "  $0"
  echo "  $0 -j 12 zedcoind zedcoin-wallet-cli"
}

while getopts ":j:h" opt; do
  case "$opt" in
    j)
      JOBS="$OPTARG"
      ;;
    h|\?)
      usage
      exit 0
      ;;
  esac
done
shift $((OPTIND - 1))
TARGETS=("$@")

map_target() {
  case "$1" in
    zedcoind) echo "daemon" ;;
    zedcoin-wallet-cli) echo "simplewallet" ;;
    zedcoin-wallet-rpc) echo "wallet_rpc_server" ;;
    zedcoin-gen-ssl-cert) echo "gen_ssl_cert" ;;
    zedcoin-gen-trusted-multisig) echo "gen_multisig" ;;
    zedcoin-genesis-tx) echo "genesis_tx" ;;
    zedcoin-blockchain-import) echo "blockchain_import" ;;
    zedcoin-blockchain-export) echo "blockchain_export" ;;
    zedcoin-blockchain-depth) echo "blockchain_depth" ;;
    zedcoin-blockchain-ancestry) echo "blockchain_ancestry" ;;
    zedcoin-blockchain-usage) echo "blockchain_usage" ;;
    zedcoin-blockchain-stats) echo "blockchain_stats" ;;
    zedcoin-blockchain-prune) echo "blockchain_prune" ;;
    zedcoin-blockchain-prune-known-spent-data) echo "blockchain_prune_known_spent_data" ;;
    zedcoin-blockchain-mark-spent-outputs) echo "blockchain_blackball" ;;
    *) echo "$1" ;;
  esac
}

install_deps() {
  if [ "$SKIP_DEPS" = "1" ]; then
    echo "Skipping dependency installation (SKIP_DEPS=1)."
    return 0
  fi
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get not found. Install build dependencies manually."
    return 0
  fi

  local sudo_cmd=""
  if [ "$(id -u)" -ne 0 ]; then
    sudo_cmd="sudo"
  fi

  $sudo_cmd apt-get update
  $sudo_cmd apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    git \
    ca-certificates \
    ccache \
    gperf \
    libboost-all-dev \
    libssl-dev \
    libzmq3-dev \
    libunbound-dev \
    libsodium-dev \
    libreadline-dev \
    libhidapi-dev \
    libusb-1.0-0-dev \
    liblzma-dev \
    qttools5-dev-tools
}

cd "$ROOT_DIR"

install_deps

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=17 \
  -DUSE_DEVICE_TREZOR=OFF \
  -DMANUAL_SUBMODULES=1 \
  -DBUILD_TESTS=OFF

if [ ${#TARGETS[@]} -eq 0 ]; then
  cmake --build build -j"$JOBS"
else
  MAPPED_TARGETS=()
  for t in "${TARGETS[@]}"; do
    MAPPED_TARGETS+=("$(map_target "$t")")
  done
  cmake --build build -j"$JOBS" --target "${MAPPED_TARGETS[@]}"
fi

echo ""
echo "=============================================================="
echo "BUILD SUCCESSFUL"
echo "BINARIES: $ROOT_DIR/build/bin"
echo "=============================================================="
