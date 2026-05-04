# Configuration Network Interface

```bash
sudo nano /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
      dhcp6: true
    enp0s8:
      addresses:
      - 192.168.50.10/24
      nameservers:
        search: [umkt.com]
        addresses: [8.8.8.8, 1.1.1.1]
```

# Configuration Open SSH Server
```bash
sudo adduser haris
sudo usermod -aG sudo haris
su - haris
sudo whoami

sudo apt install openssh-server
sudo nano /etc/ssh/sshd_config
Cari PermitRootLogin, ubah menjadi: PermitRootLogin no
sudo systemctl restart ssh
ssh haris@IP_UBUNTU -p 2222

Izinkan Port SSH Baru (2222):
sudo ufw allow 2222/tcp
sudo ufw enable
sudo ufw status

digunakan kalau ssh mu error
sudo systemctl stop ssh.socket
sudo systemctl disable ssh.socket
sudo systemctl restart ssh
```


# Hardening Server Lanjutan (Akses SSH & Fail2Ban)

```bash
ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys	= paste public key
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
sudo nano /etc/ssh/sshd_config	= ubah jadi PasswordAuthentication no

sudo apt update && sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local		= modif ini:
port    = <PORT_CUSTOM_ANDA>
maxretry = 3
bantime = 10m



sudo apt install nginx -y
sudo ufw allow 'Nginx Full'
sudo ufw status
sudo apt install mysql-server -y
sudo mysql_secure_installation
sudo apt install php-fpm php-mysql -y


```




