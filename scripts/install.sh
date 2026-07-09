#!/usr/bin/env bash

set -e

clear

echo "======================================================================"
echo "    ______     __               ______actical                         "
echo "   / ____/_  _/ /_  ___  _____ /_  __/___  _____                      "
echo "  / /   / / / / __ \/ _ \/ ___/  / / / __ \/ ___/                      "
echo " / /___/ /_/ / /_/ /  __/ /     / / / /_/ / /__                        "
echo " \____/\__, /_.___/\___/_/     /_/  \____/\___/   v1.0                "
echo "      /____/                                                           "
echo "      EDICIÓN OPERATIVA MILITAR - LINUX MINT                           "
echo "======================================================================"

echo "Versión: 0.1.0"
echo

echo "[1/5] Verificando conexión..."

ping -c 1 github.com >/dev/null

echo "✔ Conexión correcta"

echo
echo "[2/5] Actualizando paquetes..."

sudo apt update

echo
echo "[3/5] Instalando dependencias..."

sudo apt install -y \
git \
curl \
wget \
kitty \
btop \
conky-all \
fastfetch \
plank \
picom

echo
echo "[4/5] Preparando configuración..."

mkdir -p ~/.config

echo
echo "[5/5] Finalizado"

echo
echo "Cyber Tactical Mint instalado correctamente."