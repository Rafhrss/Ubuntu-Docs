#!/bin/bash
# Update sistem
sudo apt update && sudo apt upgrade -y

# Install Node.js & NPM untuk Next.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Git & Tools lainnya
sudo apt install -y git build-essential

# Verifikasi instalasi
node -v
npm -v