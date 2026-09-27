# Project Context: Ubuntu-Docs

## 📌 Deskripsi Proyek
Proyek **Ubuntu-Docs** adalah repositori yang berisi sekumpulan dokumentasi, file konfigurasi, dan skrip otomasi untuk melakukan persiapan (*provisioning*) dan pengamanan (*hardening*) pada sebuah server Ubuntu. Proyek ini difokuskan untuk membangun lingkungan server yang siap digunakan untuk web hosting (menggunakan LEMP Stack) maupun pengembangan modern (menggunakan Node.js).

## 📂 Struktur Direktori & Analisis File

1. **`config/nginx.conf`**
   File ini merupakan konfigurasi *server block* (virtual host) untuk web server Nginx. Konfigurasi ini mengatur agar Nginx melayani domain lokal `latihan.local` (dan `www.latihan.local`) pada port 80. Direktori root diarahkan ke `/var/www/latihan.local/html` dan sudah disiapkan untuk memproses file `.php` menggunakan **PHP 8.4 FPM** melalui Unix socket.

2. **`docs/prompts.md`**
   Dokumen ini adalah panduan inti yang berisi sekumpulan perintah Bash/Linux yang mencakup beberapa tahapan konfigurasi server:
   - **Jaringan**: Mengkonfigurasi IP statis (`192.168.50.10/24`) melalui Netplan.
   - **Manajemen User & SSH**: Membuat user baru bernama `haris`, memberikan akses `sudo`, menonaktifkan login Root, dan memindahkan port SSH ke 2222.
   - **Hardening / Keamanan**: Menyiapkan akses SSH menggunakan *Public Key Authentication* (menonaktifkan login password), menyalakan firewall UFW, serta menginstal dan mengkonfigurasi `fail2ban` untuk memblokir serangan *brute-force* pada SSH.
   - **LEMP Stack**: Menginstal Nginx, MySQL Server (termasuk proses `mysql_secure_installation`), dan PHP-FPM beserta ekstensi MySQL.

3. **`scripts/install-deps.sh`**
   Skrip *bash* yang berfungsi untuk mengotomatisasi instalasi kebutuhan (dependencies) tambahan di dalam sistem operasi. Skrip ini memperbarui sistem, lalu menginstal **Node.js versi 20.x**, Git, dan paket `build-essential`.

4. **`README.md`**
   File pengantar (sangat singkat) dengan judul "Documentation Ubuntu Configuration".

## ⚙️ Ringkasan Teknologi
- **OS**: Ubuntu (kemungkinan besar dijalankan di atas Virtual Machine, mengingat adanya adapter jaringan `enp0s3` dan `enp0s8`).
- **Web & Database**: Nginx, MySQL, PHP 8.4 (LEMP Stack).
- **Runtime**: Node.js (v20.x) & npm.
- **Security Tools**: UFW (Firewall), Fail2Ban, OpenSSH (Hardened).

## 🚀 Kesimpulan
Repositori ini berfungsi sebagai modul / *cheat sheet* infrastruktur. Dengan mengikuti *prompts* dan menjalankan skrip di dalam repo ini, pengguna dapat mengubah instalasi bersih (fresh install) Ubuntu Server menjadi server web terproteksi yang siap menjalankan aplikasi PHP atau aplikasi JavaScript (Next.js/Node.js).
