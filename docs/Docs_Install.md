# Panduan Instalasi Ubuntu Server Versi 26

Berikut adalah catatan langkah-langkah dan konfigurasi penting pada saat melakukan instalasi Ubuntu Server versi 26.

## 1. Konfigurasi Jaringan (Saat Instalasi)
Pada tahap instalasi yang meminta konfigurasi jaringan (*Network Configuration*), atur IP secara manual dengan parameter berikut:
- **Subnet:** `192.168.10.0/24` *(Catatan: Sesuaikan dengan subnet Host-Only di VirtualBox kamu)*
- **Address:** `192.168.10.1`

## 2. Konfigurasi Penyimpanan (Storage)
Pada tahap pembagian partisi atau penyimpanan (*Storage*):
- Setelah konfigurasi *storage* selesai dan kamu memilih **Done**, jika muncul jendela notifikasi, silakan klik **"Continue"**.

## 3. Instalasi OpenSSH
Pada tahap pemilihan perangkat lunak (*Software Selection*):
- Pastikan opsi **OpenSSH server** dalam keadaan **dicentang** agar server nantinya dapat diakses secara *remote*.

---

## 4. Penyesuaian Netplan (Pasca Instalasi)
Setelah OS selesai diinstal dan kamu berhasil masuk (*login*) ke server, kamu perlu menyesuaikan file konfigurasi jaringan (Netplan). 

*(Tips: Gunakan tombol `Tab` pada keyboard saat mengetik perintah di bawah agar sisa nama filenya terisi secara otomatis)*

```bash
sudo nano /etc/netplan/000-net.yaml
```

Di dalam file tersebut, tambahkan parameter berikut (khususnya pada bagian *bridged adapter*) untuk mematikan IPv6 dan Router Advertisement:

```yaml
dhcp6: false
accept-ra: false
```