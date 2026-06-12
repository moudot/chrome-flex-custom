# Chrome Flex Custom

## Français

### Description
Ce projet fournit trois scripts pour automatiser l'installation et la préparation de ChromeOS Flex sur une machine compatible.

- `linuxloops-v2.sh` installe **ChromeOS Flex en FAT32**.
- `devmod.sh` exécute `linuxloops-v2.sh` avec les paramètres nécessaires, gère le **choix du disque**, puis modifie **`crdybootx64.efi`**.
- `main.sh` télécharge tous les scripts utiles et installe tous les paquets nécessaires au fonctionnement de l'ensemble.

### Scripts

#### `linuxloops-v2.sh`
Rôle : installation de ChromeOS Flex avec un format cible en FAT32.

#### `devmod.sh`
Rôle : automatisation du lancement de `linuxloops-v2.sh` avec les bons prérequis, sélection du disque cible et ajustement du fichier EFI `crdybootx64.efi`.

#### `main.sh`
Rôle : bootstrap complet de l'environnement, téléchargement des scripts nécessaires et installation des dépendances système.

### Utilisation

1. Lancer `main.sh` pour préparer l'environnement.
2. Utiliser `devmod.sh` pour démarrer le processus guidé.
3. Laisser `devmod.sh` appeler `linuxloops-v2.sh` avec les bons paramètres.

```bash
chmod +x main.sh devmod.sh linuxloops-v2.sh
./main.sh
./devmod.sh
```

### Remarques

- Vérifier attentivement le disque sélectionné avant de lancer l'installation.
- Une mauvaise sélection de disque peut entraîner une perte de données.
- L'exécution doit se faire avec les privilèges nécessaires selon la distribution utilisée.

***

## English

### Description
This project provides three scripts to automate the installation and preparation of ChromeOS Flex on a compatible machine.

- `linuxloops-v2.sh` installs **ChromeOS Flex using FAT32**.
- `devmod.sh` runs `linuxloops-v2.sh` with everything required, handles **disk selection**, then modifies **`crdybootx64.efi`**.
- `main.sh` downloads all useful scripts and installs all required packages.

### Scripts

#### `linuxloops-v2.sh`
Role: installs ChromeOS Flex with FAT32 as the target format.

#### `devmod.sh`
Role: automates the execution of `linuxloops-v2.sh` with the required setup, lets the user choose the target disk, and updates the EFI file `crdybootx64.efi`.

#### `main.sh`
Role: fully bootstraps the environment, downloads the required scripts, and installs system dependencies.

### Usage

1. Run `main.sh` to prepare the environment.
2. Use `devmod.sh` to start the guided process.
3. Let `devmod.sh` call `linuxloops-v2.sh` with the correct parameters.

```bash
chmod +x main.sh devmod.sh linuxloops-v2.sh
./main.sh
./devmod.sh
```

### Notes

- Carefully verify the selected disk before starting the installation.
- Choosing the wrong disk may result in data loss.
- Run the scripts with the required privileges depending on your Linux distribution.
