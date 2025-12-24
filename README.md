## Apa itu MenheraOS?

MenheraOS adalah OS bertemakan kawaii dan anime based, dengan package lengkap untuk memberikan pengalaman terbaik bagi developers.
Sistem operasi ini berbasis [Arch Linux](https://archlinux.org/) dan memiliki
[repository pacman tambahan berisi paket-paket kawaii](https://wiki.archlinux.org/title/Unofficial_user_repositories#kawaii).

Di dalamnya terdapat berbagai paket dengan utilitas yang berguna (contohnya
[what-anime-cli](https://github.com/irevenko/what-anime-cli)) serta berbagai tema Desktop Environment (DE).

MenheraOS menggunakan **Kawaii Desktop Environment**, yaitu [KDE Plasma](https://kde.org/), dan sudah dilengkapi dengan
tema warna kawaii, wallpaper, layar SDDM, dan berbagai elemen visual lainnya yang terpasang secara default.

Selain itu, MenheraOS memiliki **installer grafis berbasis** [Calamares](https://calamares.io/), sehingga proses instalasi
jauh lebih mudah dibandingkan Arch Linux standar. Kamu juga bisa **mencoba MenheraOS tanpa menginstalnya**
dengan melakukan boot langsung dari USB flash drive.

MenheraOS menggunakan [Zsh](https://www.zsh.org/) sebagai shell bawaan. Di dalamnya juga sudah terpasang
[Oh My Zsh](https://ohmyz.sh/) lengkap dengan
[skema warna kawaii](https://github.com/LeonidPilyugin/kawaii-oh-my-zsh),
Update Script package dan tools lainnya(https://github.com/CruelFlakySnow/MenharaOS_Setup/blob/master/install-dev-tools%20(1).sh).
Serta plugin git, autocomplete, dan syntax highlighting.

Beberapa tampilan pratinjau dapat dilihat di bawah ini.

<img src="doc/preview.png">
<img src="doc/load.png">
<img src="doc/wallpaper.png">
<img src="doc/plymouth.png">
<img src="doc/grub.png">

---

## Cara Menginstal MenheraOS

Sebagai langkah awal, unduh file ISO MenheraOS terbaru dari halaman **Releases**.

Selanjutnya, [buat USB bootable](https://ubuntu.com/tutorials/create-a-usb-stick-on-windows#1-overview).
Setelah itu, [boot komputer dari USB](https://www.acronis.com/en-us/blog/posts/usb-boot/).
Ketika sistem berhasil dimuat, klik ikon **"Install"** di desktop dan ikuti instruksi instalasi yang tersedia.

> [!WARNING]
> Sangat disarankan untuk **menguji instalasi terlebih dahulu di mesin virtual (VMware maupun VirtualBox)** dan **membuat backup sistem**
> sebelum menginstal MenheraOS di komputer utama, karena proses instalasi mungkin belum sepenuhnya stabil.
>
> Selain itu, cobalah beberapa tindakan awal dulu di VM seperti melakukan update sistem dan
> generate image initramfs.
