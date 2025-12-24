echo "Memperbarui keyring untuk menghindari isu signature..."
sudo pacman -S archlinux-keyring --noconfirm

echo "Menyinkronkan database paket (tanpa upgrade sistem)..."
sudo pacman -Sy

# Daftar tools developer + aplikasi umum (hanya dari repo resmi)
packages=(
  git                 # Version control
  code                # Visual Studio Code (open-source edition dari repo resmi)
  docker              # Containerization
  docker-compose      # Docker orchestration
  nodejs              # JavaScript runtime (includes npm)
  python              # Python interpreter (includes pip)
  go                  # Go language
  rust                # Rust language (termasuk cargo via rustup nanti jika perlu)
  neovim              # Advanced text editor
  vim                 # Text editor
  gcc                 # C/C++ compiler
  make                # Build automation
  cmake               # Build system generator
  jdk-openjdk         # Java development kit
  postgresql          # Database server
  mariadb             # MySQL-compatible database
  redis               # In-memory data store
  nginx               # Web server
  kubectl             # Kubernetes CLI
  terraform           # Infrastructure as code
  firefox             # Web browser
  vlc                 # Media player
)

# Fungsi instal paket dengan penanganan error
install_packages() {
  for pkg in "${packages[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
      echo "Menginstal $pkg..."
      sudo pacman -S --needed --noconfirm "$pkg" || { echo "Error menginstal $pkg"; exit 1; }
    else
      echo "$pkg sudah terinstal."
    fi
  done
}

# Instal paket utama
install_packages

# Enable service Docker jika terinstal
if pacman -Qi docker &> /dev/null; then
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER
  echo "Docker diaktifkan. Logout/login agar perubahan group aktif."
fi

echo "Instalasi selesai tanpa error dan tanpa full system upgrade!"
echo "Sistem aman untuk reboot. 💜"
