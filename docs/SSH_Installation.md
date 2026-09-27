# Panduan Konfigurasi SSH Server (Passwordless Login)

Dokumen ini berisi panduan lengkap untuk mengatur akses SSH dari Windows ke Ubuntu Server menggunakan otentikasi *SSH Key* (tanpa *password*), sekaligus menerapkan konfigurasi pengamanan (*hardening*) pada SSH Server.

## 1. Troubleshooting (Jika Akses Ditolak)
Jika suatu saat Anda tidak bisa *login* karena status server SSH dianggap baru (konflik *fingerprint*), gunakan perintah berikut di **CMD Windows**:

```cmd
ssh-keygen -R "[192.168.10.1]:2222"
ssh-keygen -R 192.168.10.1
```
*(Catatan: Perintah pertama merupakan perintah yang paling manjur).*

---

## 2. Instalasi dan Pengecekan OpenSSH Server (di Ubuntu)
Buka terminal Ubuntu Anda dan jalankan perintah berikut untuk menginstal layanan OpenSSH, lalu pastikan statusnya berjalan dengan baik (warna hijau):

```bash
sudo apt install openssh-server -y
sudo systemctl status ssh
sudo systemctl status ssh.socket
```
*(Info: Untuk *setting network* di Windows, pastikan diatur tanpa *gateway*).*

---

## 3. Generate SSH Key (di CMD Windows)
Buka **Command Prompt (CMD)** di Windows untuk membuat kunci SSH dan menampilkan isinya:

```cmd
ssh-keygen -t ed25519
type .ssh\id_ed25519.pub
```
*Tugas: Salin (copy) seluruh teks *public key* yang muncul di layar untuk digunakan pada langkah selanjutnya.*

---

## 4. Memasukkan SSH Key (di Terminal Ubuntu)
Kembali ke terminal Ubuntu. Anda perlu membuat folder *hidden* `.ssh` dan menempelkan (*paste*) *public key* yang telah disalin ke dalam file *authorized_keys*.

```bash
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```
*(Keterangan: Pada perintah `nano ~/.ssh/authorized_keys`, silakan paste SSH Key Anda di dalamnya).*

---

## 5. Menonaktifkan Socket Service SSH (di Ubuntu)
Jalankan perintah ini agar SSH berjalan penuh sebagai *service* dan mematikan fungsi *socket*:

```bash
sudo systemctl disable --now ssh.socket
sudo systemctl enable --now ssh.service
```

---

## 6. Konfigurasi Hardening OpenSSH (di Ubuntu)
Buka file konfigurasi SSH:

```bash
sudo nano /etc/ssh/sshd_config
```

Di dalam file editor `nano`, cari dan atur nilai-nilai berikut:
- ubah port jadi 22
- `PermitRootLogin no` *(Mencegah penyerang langsung menargetkan akun dengan wewenang tertinggi)*
- `MaxAuthTries 3` *(coba hanya 3x)*
- `PubkeyAuthentication yes`
- `AuthorizedKeysFile .ssh/authorized_keys`
- `PasswordAuthentication no` *(Memblokir seluruh percobaan brute force password)*
- `AllowAgentForwarding no` *(Mencegah SSH Agent di komputer host diteruskan ke server)*
- `AllowTcpForwarding no` *(Mematikan kemampuan SSH Tunneling / Port Forwarding)*
- `X11Forwarding no` *(Mematikan fitur penerusan antarmuka grafis / GUI melalui tunnel SSH)*

---

## 7. Terapkan Konfigurasi dan Konfigurasi Firewall
Langkah terakhir adalah menghapus file konfigurasi *cloud-init* agar *setting* kita tidak tertimpa (*override*), mengizinkan port pada Firewall UFW, mengecek konfigurasi, dan me-*restart* SSH.

```bash
sudo rm /etc/ssh/sshd_config.d/50-cloud-init.conf
sudo ufw allow 2222/tcp comment 'Custom SSH Port'
sudo ufw enable
sudo ufw status
sudo sshd -t
sudo systemctl restart ssh
sudo ss -tulpn | grep ssh
```
*(Catatan: Jika perintah `sudo sshd -t` tidak mengeluarkan teks *error* apa pun, artinya konfigurasi Anda aman dan sudah benar).*