#!/usr/bin/env bash

[ -n "${XENU_DEBUG:-}" ] && set -x

usage() {
  echo "usage: $0 [init <iso>]" >&2
  exit 1
}

read -ra _t <<< "${XENU_ARGS:-}"
XENU_ARGS=("${_t[@]}")

XENU_DISK=$(realpath "${XENU_DISK:-disk.img}"

if [ -t 0 ];
  # setup console if launched interactively
  XENU_ARGS+=("--device" "virtio-serial,stdio")
fi

if [ "${1:-}" = "init" ]; then
  if [ ! -r "${2:-}" ]; then
    echo "could not read \"${2:-}\"" >&2
    usage
  fi

  XENU_ARGS+=("--device" "usb-mass-storage,path=$(realpath "$2"),readonly")
  qemu-img create -f raw "$XENU_DISK" "${XENU_DISK_SIZE:-@diskSize@}M"

  # generate random mac address and store as xattr
  xattr -w -s vm.mac $(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/:$//') "$XENU_DISK"
fi

XENU_MAC_ADDR=$(xattr -p vm.mac "$XENU_DISK")
: ${XENU_MAC_ADDR:?could not read mac address from "$XENU_DISK"}

XENU_VSOCK_PORTS=(${XENU_VSOCK_PORTS[@]:-$(seq 1337 $((1337+9)))})
for n in "${XENU_VSOCK_PORTS[@]}"; do
  XENU_ARGS+=("--device" "virtio-vsock,port=$n,socketURL=$n.sock,connect")
done

vfkit \
  --log-level "error" \
  --cpus "'{XENU_CORES:-@cores@}" \
  --memory "${XENU_MEMORY:-@memory@}" \
  --bootloader efi,variable-store=efi-variable-store,create \
  --device rosetta,mountTag=rosetta \
  --device virtio-rng \
  --device virtio-balloon \
  --device virtio-net,nat,mac="$XENU_MAC_ADDR" \
  --device virtio-blk,path="$XENU_DISK" \
  --device virtio-fs,sharedDir="${XENU_SHARED_DIR:-@sharedDir@}",mountTag=shared \
  "${XENU_ARGS[@]}"
