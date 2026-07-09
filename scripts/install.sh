#!/usr/bin/env bash

set -e

GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m"
NC="\033[0m"

clear

echo -e "${GREEN}"
echo "=============================================="
echo "        CYBER TACTICAL MINT v0.1"
echo "=============================================="
echo -e "${NC}"

echo -e "${BLUE}[1/6] Comprobando sistema...${NC}"

if ! grep -q "Linux Mint" /etc/os-release; then
    echo -e "${RED}Este instalador solo funciona en Linux Mint.${NC}"
    exit 1
fi

echo -e "${GREEN}Sistema compatible.${NC}"

echo -e "${BLUE}[2/6] Actualizando paquetes...${NC}"
sudo apt update

echo -e "${BLUE}[3/6] Instalando programas...${NC}"

sudo apt install -y \
kitty \
btop \
fastfetch \
conky-all \
plank \
picom \
git \
curl \
wget \
unzip

echo -e "${BLUE}[4/6] Creando carpetas...${NC}"

mkdir -p ~/.config/{kitty,btop,fastfetch,conky}

echo -e "${BLUE}[5/6] Preparando Cyber Tactical Mint...${NC}"

sleep 2

echo -e "${BLUE}[6/6] Finalizando...${NC}"

echo
echo -e "${GREEN}✔ Instalación completada correctamente.${NC}"
echo
echo "La configuración personalizada se instalará en la siguiente versión."