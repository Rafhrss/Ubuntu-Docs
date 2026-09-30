# Panduan Instalasi dan Konfigurasi DHCP Server

Dokumen ini berisi langkah-langkah praktis untuk melakukan instalasi serta konfigurasi layanan DHCP Server di Ubuntu menggunakan paket `isc-dhcp-server`.

> 💡 **INFO PENTING**: 
> - **Pengaturan Jaringan**: Panduan ini dikhususkan untuk mesin virtual (VirtualBox). Pastikan Anda menggunakan **Adapter 1: NAT** dan **Adapter 2: Host-Only Adapter**.
> - **Penyesuaian IP & Domain**: Pada konfigurasi di bawah ini, kita menggunakan IP Server `192.168.10.1` dan nama domain `rafa.com`. **Silakan sesuaikan nilai-nilai tersebut** dengan pengaturan alamat IP (*subnet*) dan domain milik Anda sendiri.

## 1. Pembaruan Sistem dan Instalasi
Jalankan perintah berikut untuk memperbarui daftar paket sistem dan menginstal DHCP server:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install isc-dhcp-server -y
```

---

## 2. Pengecekan Interface
Anda harus menentukan *interface* (kartu jaringan) mana yang akan bertugas membagikan IP (biasanya *Host-Only Adapter* seperti `enp0s8`). 

Cek nama *interface* Anda menggunakan perintah:
```bash
ip add
```

Buka file konfigurasi *default* dari paket DHCP:
```bash
sudo nano /etc/default/isc-dhcp-server
```
*(Catatan: Di dalam file tersebut, cari bagian `INTERFACESv4="..."`, lalu isikan dengan nama port/interface Anda (misalnya `"enp0s8"`). Sesuaikan dengan hasil dari perintah `ip add`).*

Anda juga bisa melihat tabel *routing* yang sedang aktif dengan perintah:
```bash
ip route
```

---

## 3. Konfigurasi Aturan DHCP (Subnet & IP Range)
Langkah terpenting adalah mengatur rentang IP (*IP Range*) yang akan diberikan secara otomatis ke komputer klien.

Buka file konfigurasi utamanya:
```bash
sudo nano etc/dhcp/dhcpd.conf
```
*(Catatan ringan: Terdapat skrip `etc/dhcp` pada perintah di atas, apabila Anda sedang tidak berada di *root directory*, mungkin Anda perlu menambahkan garis miring menjadi `/etc/dhcp/dhcpd.conf`).*

Di dalam file editor tersebut, cari blok pengaturan `A slightly different configuration`. **Matikan pagarnya** (hapus tanda `#` di depan perintah) dan ubah isinya.
Konfigurasinya cukup mudah: `domain-name-servers` diisi dengan IP server Anda, lalu `domain-name` diisi dengan nama domain kustom Anda (misal `rafa.com`). 

**PERHATIAN:** Jaga setiap indentasi (spasi dan formatnya) agar persis seperti di bawah ini untuk menghindari *error*:

```text
# A slightly different configuration for an internal subnet.
subnet 192.168.10.0 netmask 255.255.255.0 {
  range 192.168.10.5 192.168.10.100;
  option domain-name-servers 192.168.10.1;
  option domain-name "rafa.com";
  option subnet-mask 255.255.255.0;
  option routers 192.168.10.1;
  option broadcast-address 192.168.10.255;
  default-lease-time 600;
  max-lease-time 7200;
}
```

---

## 4. Menerapkan Konfigurasi dan Pengecekan
Setelah selesai disimpan, lakukan *restart* pada layanan DHCP untuk memuat konfigurasi baru, cek status agar dipastikan *running/active*, dan gunakan utilitas *lease list* untuk melihat komputer (klien) mana saja yang telah mendapatkan *IP Address*.

Jalankan perintah ini satu per satu:
```bash
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
dhcp-lease-list
```