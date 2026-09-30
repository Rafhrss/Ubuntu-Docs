# Panduan Instalasi dan Konfigurasi SSL/TLS (HTTPS)

Dokumen ini berisi panduan tingkat lanjut (*enterprise level*) untuk membangun *Private PKI (Public Key Infrastructure)*, membuat *Certificate Authority (CA)* lokal, menerbitkan sertifikat mandiri, dan mengamankan lalu lintas *web server* Nginx.

> 💡 **INFO & PERINGATAN PENTING**: 
> - **Penyesuaian Nama Domain**: Pada panduan ini kita menggunakan domain contoh seperti `rafa.net` dan `rafa.net.id`. **Pastikan** nama domain yang Anda masukkan pada konfigurasi SSL ini **harus sama persis** dengan konfigurasi `server_name` yang sudah Anda buat di file Nginx.
> - **Penyesuaian Domisili (Identitas SSL)**: Pada perintah pembuatan sertifikat yang memuat subjek data diri seperti `"/C=ID/ST=East Kalimantan/L=Samarinda/O=Rafa Website/CN=rafa.net"`, **silakan ubah dan sesuaikan** parameter tersebut (Provinsi, Kota, Organisasi) dengan lokasi domisili Anda sendiri.

## 1. Tahap 1: Membuat Root CA
Tahap pertama adalah membuat *Private Key* dan menerbitkan sertifikat otoritas induk (*Root CA*) yang berlaku panjang.

Buat direktori penyimpanannya dan masuk ke dalamnya:
```bash
sudo mkdir -p /etc/ssl/localCA
cd /etc/ssl/localCA
```

Buat *Private Key* untuk Root CA dan terbitkan sertifikat Root CA publik yang berlaku selama 10 tahun (3650 hari):
```bash
sudo openssl genrsa -out rootCA.key 4096
sudo openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.crt -subj "/C=ID/ST=East Kalimantan/L=Samarinda/O=Rafa Authority/CN=Rafa Local Root CA"
```

---

## 2. Tahap 2: Menerbitkan Sertifikat SSL untuk Domain
Langkah berikutnya adalah membuat *Private Key* spesifik untuk domain Anda dan membuat *Certificate Signing Request* (CSR).

Buat *Private Key* (khusus website) dan CSR:
```bash
sudo openssl genrsa -out rafa.net.key 2048
sudo openssl req -new -key rafa.key -out rafa.csr -subj "/C=ID/ST=East Kalimantan/L=Samarinda/O=Rafa Website/CN=rafa.net"
```

Buat file ekstensi agar sertifikat memiliki atribut *Subject Alternative Name* (SAN) yang diwajibkan oleh *browser* modern:
```bash
sudo nano rafa.ext
```
*(Catatan: Isikan file tersebut dengan kode di bawah ini. Pastikan tidak merubah format indentasi pada bagian bawah `[alt_names]`).*
```text
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = rafa.net
DNS.2 = www.rafa.net
IP.1 = 192.168.10.1
```

Lalu, terbitkan sertifikat domain dan pindahkan sertifikat serta *Private Key*-nya ke tempat yang dapat dibaca Nginx:
```bash
sudo openssl x509 -req -in rafa.net.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out rafa.net.crt -days 825 -sha256 -extfile rafa.ext
sudo cp rafa.net.id.crt /etc/ssl/certs/
sudo cp rafa.net.id.key /etc/ssl/private/
```

---

## 3. Tahap 3: Konfigurasi Port 443 & Redirect HTTPS di Nginx
Kita akan mengubah *Virtual Host* Nginx agar otomatis mengalihkan *traffic* menjadi HTTPS.

Buka file *server block* Nginx Anda:
```bash
sudo nano /etc/nginx/sites-available/rafa.conf
```
*(Catatan Penting: Di dalam file editor `nano` tersebut, **matikan** seluruh kode yang saat ini aktif dengan memberikan tanda pagar `#` di depan barisnya, lalu letakkan salinan konfigurasi di bawah ini pada baris yang paling bawah).*

```text
# Blok 1: Mengalihkan semua lalu lintas HTTP (Port 80) ke HTTPS secara otomatis
server {
    listen 80;
    listen [::]:80;

    server_name rafa.net.id www.rafa.net.id;

    return 301 https://$host$request_uri;
}

# Blok 2: Melayani konten website dengan enkripsi HTTPS (Port 443)
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name rafa.net.id www.rafa.net.id;

    root /var/www/rafa;
    index index.html index.htm;

    # Jalur Sertifikat SSL dan Private Key
    ssl_certificate /etc/ssl/certs/rafa.net.id.crt;
    ssl_certificate_key /etc/ssl/private/rafa.net.id.key;

    # Standar Protokol Keamanan Modern
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Izinkan jalur akses *Nginx SSL* (port 443) pada *firewall* (UFW), lalu terapkan aturan (*reload*) dan *restart* Nginx:
```bash
sudo ufw allow 443/tcp comment 'Nginx SSL'
sudo ufw reload
sudo systemctl restart nginx
```

---

## 4. Tahap 4: Mengamankan Kepercayaan *Browser* Windows
Karena sertifikat Root CA kita ini adalah *self-signed*, sistem Windows belum mengenalinya secara *default*. Agar status web menjadi *Secure* dan gembok hijau di *browser*, ikuti langkah ini.

Lihat isi dari *Root CA* yang telah Anda buat:
```bash
cat /etc/ssl/localCA/rootCA.crt
```
*(Tugas Anda: Salin seluruh karakter mulai dari tulisan `-----BEGIN CERTIFICATE-----` sampai dengan `-----END CERTIFICATE-----`. Buka aplikasi Notepad di Windows Anda, salin isinya, lalu *Save As* dengan ekstensi `.crt` / beri nama `rootCA.crt`).*

**Langkah Instalasi Sertifikat di Windows:**
1. Buka *File Explorer*, cari file `rootCA.crt` yang baru disimpan. 
2. Klik 2x atau klik kanan lalu pilih **Install Certificate**.
3. Pilih lokasi ke **Local Machine**.
4. Pilih opsi *"Place all certificates in the following store"*, lalu klik **Browse**.
5. Pilih direktori sasaran yaitu folder **"Trusted Root Certification Authorities"**.
6. Klik **OK**, lalu **Next**, sampai muncul notifikasi *"The import was successful"*.

---

> *"Kalau cuma sekadar klik-klik Certbot Let's Encrypt, semua orang juga bisa. Tapi di video ini, kita belajar cara kerja Private PKI yang dipakai oleh Sysadmin di level enterprise: bagaimana sebuah organisasi menerbitkan, mengamankan, dan mempercayai sertifikat enkripsinya sendiri di jaringan tertutup."*
