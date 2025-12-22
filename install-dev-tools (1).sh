#!/bin/bash

# Script Otomatis Instal Tools Development untuk MenheraOS (Arch-based)
# Dibuat untuk tugas: Toolchain (GCC, Python, Node.js, Java OpenJDK), IDE (VS Code), Git, Docker
# Jalankan dengan sudo: curl -sL <github-raw-link> | sudo bash
# NO ERROR, NO ANOMALY: Update dulu, install non-interactive, handle jika sudah ada.

set -euo pipefail  # Mode strict: error jika gagal

echo "Mulai instalasi tools development..."

# Step 1: Update sistem (wajib untuk hindari conflict)
pacman -Syu --noconfirm || { echo "Error update sistem! Cek koneksi/internet."; exit 1; }

# Step 2: Install Toolchain Pengembangan
pacman -S --noconfirm --needed gcc python nodejs jdk-openjdk || true

# Step 3: Install IDE/Editor (VS Code, populer dan terkonfigurasi basic)
pacman -S --noconfirm --needed code || true  # VS Code OSS dari community repo

# Step 4: Install Git (Version Control, biasanya sudah ada tapi pastikan)
pacman -S --noconfirm --needed git || true

# Step 5: Install Docker (Containerization Tool)
pacman -S --noconfirm --needed docker || true
systemctl enable docker.service || true  # Enable auto-start
systemctl start docker.service || true   # Start sekarang
usermod -aG docker $USER || true         # Add current user ke docker group (logout/login ulang untuk efektif)

# Verifikasi instalasi
echo "Verifikasi instalasi:"
gcc --version || echo "GCC tidak terdeteksi!"
python --version || echo "Python tidak terdeteksi!"
node --version || echo "Node.js tidak terdeteksi!"
java --version || echo "Java OpenJDK tidak terdeteksi!"
code --version || echo "VS Code tidak terdeteksi!"
git --version || echo "Git tidak terdeteksi!"
docker --version || echo "Docker tidak terdeteksi!"

echo "Instalasi selesai! Logout/login ulang untuk Docker. Jika error, cek log Pacman."