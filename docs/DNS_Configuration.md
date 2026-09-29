# Panduan Instalasi dan Konfigurasi DNS Server

Dokumen ini berisi langkah-langkah detail untuk melakukan instalasi serta pengaturan DNS Server di Ubuntu menggunakan layanan **BIND9**, sekaligus cara mengatur klien DNS di Windows Anda.

> 💡 **INFO PENTING**: 
> - Pada panduan di bawah ini, domain **`haris.local`** (dan **`haris.cloud`**) serta nama file seperti **`db.haris`** hanyalah contoh. Anda **bebas menyesuaikan/menggantinya** dengan nama domain keinginan Anda sendiri (misalnya: `nama-kamu.com`, `budi.id`, dll).
> - **Pastikan** nama domain yang Anda buat di sini **sama persis** dengan nama domain yang Anda konfigurasi di dalam file konfigurasi **Nginx**. Hal ini diwajibkan agar *web server* dapat mendeteksi dan mengarahkan domain tersebut dengan benar.

## 1. Instalasi BIND9
Buka terminal Anda dan jalankan perintah berikut untuk menginstal paket DNS Server (`bind9`) beserta utilitas pendukungnya:

```bash
sudo apt install bind9 bind9-utils -y
```

---

## 2. Konfigurasi *Options*
Selanjutnya, kita akan mengatur *forwarders* dan izin koneksi pada server. 

Buka file konfigurasi *options* menggunakan *nano*:
```bash
sudo nano /etc/bind/named.conf.options
```

Isi (atau timpa) bagian dalam file tersebut dengan kode di bawah ini. *Pastikan untuk menyalinnya sama persis:*

```text
options {
    directory "/var/cache/bind";

    forwarders {
        8.8.8.8;
        1.1.1.1;
    };

    allow-query { any; };
    listen-on { any; };
    listen-on-v6 { any; };
};
```

Setelah file disimpan, jalankan perintah pengecekan sintaks berikut:
```bash
sudo named-checkconf
```
*(Catatan: Jika setelah perintah dijalankan tidak muncul output atau teks error apa pun, artinya konfigurasi sukses dan valid).*

---

## 3. Menambahkan Konfigurasi *Zone*
Setelah konfigurasi umum selesai, atur pendaftaran domain lokal Anda dan tentukan letak lokasi file database DNS-nya.

Buka file konfigurasi *local* BIND:
```bash
sudo nano /etc/bind/named.conf.local
```

Tambahkan blok konfigurasi *zone* berikut di dalam file tersebut:
```text
zone "haris.local" {
    type master;
    file "/etc/bind/db.haris";
};
```

---

## 4. Pembuatan *Database* DNS Record
Di tahap ini, Anda akan memasukkan *record* DNS sesungguhnya yang menentukan ke mana domain diarahkan.

Buka atau buat file *database* DNS dengan perintah berikut:
```bash
sudo nano /etc/bind/db.haris
```

Masukkan kode di bawah ini. **Perhatian: Jaga setiap indentasi (spasi dan formatnya) persis seperti ini agar tidak terjadi *error* pada sistem BIND.**

```text
;
; Database DNS Record untuk haris.local
;
$TTL    604800
@       IN      SOA     ns.haris.local. root.haris.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.haris.local.
ns      IN      A       192.168.10.1
@       IN      A       192.168.10.1
www     IN      A       192.168.10.1
```

---

## 5. Pengecekan, Firewall, dan Menerapkan Konfigurasi
Langkah terakhir di server Ubuntu adalah memverifikasi semua *record*, membuka jalur (*port*) khusus DNS pada Firewall, dan merestart *service* BIND9. 

Jalankan serangkaian perintah ini:

```bash
sudo named-checkzone haris.local /etc/bind/db.haris
sudo ufw enable
sudo ufw allow 53 comment 'DNS Server'
sudo ufw reload
sudo systemctl restart named
```

*(Penjelasan singkat:* 
- *`named-checkzone` digunakan untuk memastikan data konfigurasi domain sudah berstatus OK atau belum.*
- *`ufw allow 53` adalah proses mengizinkan port standar layanan DNS agar dapat diakses jaringan).*

---

## 6. Konfigurasi DNS Client (PowerShell di Windows)
Agar browser dan sistem Windows Anda mengetahui letak alamat DNS yang baru saja Anda buat, Anda perlu menambahkan aturan khusus di Windows.

**Buka PowerShell sebagai Administrator (Run as Administrator)** dan jalankan perintah di bawah ini:

```powershell
Add-DnsClientNrptRule -Namespace "haris.cloud" -Nameservers "192.168.10.1"
Clear-DnsClientCache
```

*(Tips: Jika Anda menggunakan Firefox dan website dengan DNS baru belum bisa terbuka, ketik url `about:networking#dns` di address bar Firefox Anda untuk memantau/membersihkan cache internal browser).*

### Perintah Pengecekan
Untuk mengecek pengaturan DNS yang sedang aktif, gunakan perintah ini:
```powershell
# Menampilkan semua detail (DNS, IP, dan parameter lainnya)
Get-DnsClientNrptRule

# Hanya menampilkan kolom Domain (Namespace) dan IP (NameServers)
Get-DnsClientNrptRule | Format-Table Namespace, NameServers
```

### Perintah Penghapusan
Jika Anda perlu menghapus aturan DNS yang sudah dibuat:
```powershell
# Menghapus khusus untuk aturan dns "haris.cloud" saja
Get-DnsClientNrptRule | Where-Object {$_.Namespace -eq "haris.cloud"} | Remove-DnsClientNrptRule -Force

# MENGHAPUS SEMUA ATURAN YANG ADA (Gunakan hati-hati!)
Get-DnsClientNrptRule | Remove-DnsClientNrptRule -Force
```

---

### 📝 Template (Jika membuat DNS Baru)
Jika di lain waktu Anda membuat nama domain dan IP yang berbeda, Anda bisa menggunakan template perintah ini di PowerShell:
```powershell
Add-DnsClientNrptRule -Namespace "budi.id" -Nameservers "IP_SERVER_BARU"
```