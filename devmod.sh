#!/usr/bin/env bash
set -euo pipefail

LINUXLOOPS="./linuxloops-v2"
MOUNTPOINT="/mnt/chromeos-efi"
CRDY_URL="https://github.com/supechicken/crdyboot/releases/download/20251207/crdyboot.efi"
TMP_CRDY="/tmp/crdyboot.efi"

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "Merci de lancer ce script en root (sudo $0) ou en root direct."
    exit 1
  fi
}

require_root

if [[ ! -x "$LINUXLOOPS" ]]; then
  echo "Erreur : $LINUXLOOPS introuvable ou non exécutable."
  exit 1
fi

echo "=== Disques détectés ==="
# On n'affiche que les vrais disques (TYPE = disk)
lsblk -d -o NAME,SIZE,MODEL,TYPE | awk '$4=="disk"{printf "/dev/%-8s %8s  %s\n",$1,$2,$3}'

echo
read -rp "Nom du disque cible (ex: sdb, nvme0n1) : " disk_name
DISK="/dev/${disk_name}"

if [[ ! -b "$DISK" ]]; then
  echo "Erreur : $DISK n'est pas un block device valide."
  exit 1
fi

echo "ATTENTION : toutes les données sur $DISK seront effacées."
read -rp "Tape 'yes' pour confirmer : " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Annulé."
  exit 1
fi

echo "=== Installation de ChromeOS Flex sur $DISK avec linuxloops ==="
# Ici on ajoute bien -dst /dev/<nom du disque>
"$LINUXLOOPS" -distro ChromeOS-Flex -env Standard -dst "$DISK"

echo "=== Installation terminée, préparation de la partition EFI (12) ==="

# Gestion du suffixe 'p' pour NVMe & co
if [[ "$DISK" =~ [0-9]$ ]]; then
  EFI_PART="${DISK}p12"
else
  EFI_PART="${DISK}12"
fi

if [[ ! -b "$EFI_PART" ]]; then
  echo "Erreur : la partition EFI attendue ($EFI_PART) n'existe pas."
  echo "Vérifie le partitionnement (fdisk -l $DISK) et adapte si besoin."
  exit 1
fi

mkdir -p "$MOUNTPOINT"

echo "Montage de $EFI_PART sur $MOUNTPOINT..."
mount "$EFI_PART" "$MOUNTPOINT"

cleanup() {
  echo "Nettoyage..."
  umount "$MOUNTPOINT" 2>/dev/null || true
}
trap cleanup EXIT

echo "Téléchargement de crdyboot.efi..."
curl --fail --location --show-error \
  "$CRDY_URL" \
  -o "$TMP_CRDY"

echo "Création du répertoire efi/boot si nécessaire..."
mkdir -p "$MOUNTPOINT/efi/boot"

echo "Copie de crdyboot.efi vers efi/boot/crdybootx64.efi..."
mv "$TMP_CRDY" "$MOUNTPOINT/efi/boot/crdybootx64.efi"


chmod +x "$MOUNTPOINT/$POWERD_SCRIPT_NAME"

sync

echo "Démontage de la partition EFI..."
umount "$MOUNTPOINT"
trap - EXIT

echo "Terminé :"
echo "  - crdybootx64.efi est dans $EFI_PART:/efi/boot/"
