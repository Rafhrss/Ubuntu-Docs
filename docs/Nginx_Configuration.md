# Panduan Instalasi dan Konfigurasi Web Server Nginx

Dokumen ini berisi langkah-langkah praktis untuk melakukan instalasi Nginx, mengatur letak penyimpanan folder website kustom, serta melakukan konfigurasi *Virtual Host* (Server Block) agar domain Anda mengarah ke folder yang tepat.

> 💡 **INFO & PERINGATAN PENTING**: 
> - **Penyesuaian Nama**: Pada contoh panduan di bawah ini kita menggunakan nama user `haris`, nama domain `haris.local`, dan direktori `/home/haris/website`. Silakan sesuaikan nama-nama tersebut dengan nama pilihan Anda sendiri.
> - **Akses Domain**: Meskipun konfigurasi Nginx (*Virtual Host*) untuk nama domain Anda nantinya sudah selesai dan benar, **website tidak akan bisa dipanggil/diakses dari browser menggunakan nama domain** apabila DNS-nya belum dikonfigurasi. Anda wajib melakukan setup DNS Server, atau sebagai alternatif untuk pengetesan lokal di Windows, Anda bisa mendaftarkan nama domain dan IP Ubuntu Anda secara manual ke dalam file `C:\Windows\System32\drivers\etc\hosts`.
## 1. Instalasi dan Konfigurasi Firewall Nginx
Jalankan perintah di bawah ini untuk menginstal Nginx. Setelah terinstal, kita akan melihat statusnya dan membuka jalur *port HTTP* (Port 80) pada *firewall* (UFW).

```bash
sudo apt install nginx -y
sudo systemctl status nginx
```
*(Catatan: Setelah menjalankan `systemctl status`, pastikan muncul tanda bahwa *service* tersebut berstatus **active / berjalan**).*

Buka port 80 untuk akses web:
```bash
sudo ufw enable
sudo ufw allow 80/tcp comment 'Web Server HTTP'
sudo ufw reload
sudo ufw status verbose
```

---

## 2. Persiapan Direktori Website (Root)
Selanjutnya, kita akan membuat direktori tempat menyimpan file website (seperti `index.html`) di dalam folder user spesifik. (Anda juga bisa saja menyimpannya di jalur default seperti `/var/www/html/`, namun di sini kita mencoba lokasi *custom*).

Buat user baru dan direktorinya:
```bash
sudo adduser haris
sudo mkdir -p /home/haris/website
```

Buat file HTML sederhana sebagai halaman awal untuk testing:
```bash
sudo nano /home/haris/website/index.html
```

Masukkan kode HTML berikut ke dalamnya dan simpan:
```html
<h1>Selamat Datang di Website Haris!</h1>
<p>Domain berhasil diarahkan ke /home/haris/website</p>
```

Selanjutnya, kita perlu mengatur *ownership* (kepemilikan folder) dan *permission* (hak akses) agar web server Nginx dapat mengakses dan membaca file di folder tersebut:
```bash
sudo chown -R haris:haris /home/haris/website
sudo chmod -R 755 /home/haris/website
sudo chmod 755 /home/haris
```

---

## 3. Konfigurasi *Server Block* (Virtual Host)
Kita akan membuat konfigurasi yang menghubungkan domain ke folder website tadi. Anda bisa memanfaatkan *copy* dari isi file `sites-available/default` bawaan Nginx.

Buka file konfigurasi baru:
```bash
sudo nano /etc/nginx/sites-available/haris.conf
```

Pada file tersebut, Anda hanya perlu mengganti / memperhatikan bagian-bagian ini:
```text
listen 80;
listen [::]:80;
root /home/haris/website;
server_name haris.local www.haris.local;
```

*(Panduan penyesuaian dari teks Anda di atas:*
- *Pada bagian `listen 80;` dan `listen [::]:80;`, **hapus tulisan `default_server`**.*
- *Pada bagian `root`, ini adalah tempat tersimpannya `index.html` Anda. Sebaiknya disesuaikan menjadi `/home/haris/website`).*
- *Pada bagian `server_name`, **bebas** sesuka nama domain kalian.*

---

## 4. Mengaktifkan Website dan Testing
Langkah terakhir adalah mengaktifkan konfigurasi yang baru dibuat, menghapus konfigurasi bawaan, dan me-restart layanan Nginx.

```bash
sudo ln -s /etc/nginx/sites-available/haris.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

*(Penjelasan singkat:*
- *`ln -s` adalah fitur **Link Symbolic** pada Linux yang berfungsi untuk membuat jalan pintas (*shortcut*) penghubung konfigurasi.*
- *`rm` digunakan untuk menghapus situs bawaan (*default*) agar **tidak tabrakan** (*conflict*) pada port 80.*
- *`nginx -t` berfungsi sebagai pengetesan sistem untuk memastikan tidak ada konfigurasi yang *error*).*
