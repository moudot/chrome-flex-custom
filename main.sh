#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/moudot/chrome-flex-custom/refs/heads/main"
INSTALL_DIR="${HOME}/chrome-flex-custom"

echo "[+] Détection du gestionnaire de paquets..."

install_deps_apt() {
  sudo apt update
  sudo apt install -y \
    bash curl wget ca-certificates coreutils findutils grep sed gawk \
    util-linux mount fdisk gdisk parted kmod \
    e2fsprogs dosfstools xz-utils zstd gzip bzip2 tar unzip \
    rsync pv file blkid
}

install_deps_dnf() {
  sudo dnf install -y \
    bash curl wget ca-certificates coreutils findutils grep sed gawk \
    util-linux mount fdisk gdisk parted kmod \
    e2fsprogs dosfstools xz zstd gzip bzip2 tar unzip \
    rsync pv file
}

install_deps_pacman() {
  sudo pacman -Sy --noconfirm \
    bash curl wget ca-certificates coreutils findutils grep sed gawk \
    util-linux fdisk gptfdisk parted kmod \
    e2fsprogs dosfstools xz zstd gzip bzip2 tar unzip \
    rsync pv file
}

install_deps_apk() {
  sudo apk add --no-cache \
    bash curl wget ca-certificates coreutils findutils grep sed gawk \
    util-linux mount lsblk blkid fdisk sfdisk parted kmod \
    e2fsprogs dosfstools xz zstd gzip bzip2 tar unzip \
    rsync pv file
}

if command -v apt >/dev/null 2>&1; then
  install_deps_apt
elif command -v dnf >/dev/null 2>&1; then
  install_deps_dnf
elif command -v pacman >/dev/null 2>&1; then
  install_deps_pacman
elif command -v apk >/dev/null 2>&1; then
  install_deps_apk
else
  echo "[!] Gestionnaire de paquets non supporté automatiquement."
  echo "    Installe au minimum: bash curl wget grep sed awk util-linux parted fdisk gdisk e2fsprogs dosfstools rsync tar xz zstd pv"
  exit 1
fi

echo "[+] Création du dossier ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

echo "[+] Téléchargement des scripts..."
curl -fL "${BASE_URL}/devmod.sh" -o devmod.sh
curl -fL "${BASE_URL}/linuxloops-v2.sh" -o linuxloops-v2.sh

chmod +x devmod.sh linuxloops-v2.sh

echo "[+] Scripts téléchargés :"
ls -lh devmod.sh linuxloops-v2.sh