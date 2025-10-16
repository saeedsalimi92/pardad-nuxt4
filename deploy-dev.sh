#!/usr/bin/env bash
set -euo pipefail

# متغیرها — اگر خواستی تغییر بده
REPO_DIR="/home/ubuntu/projects/pardad-nuxt4"
BRANCH="dev"
SITE_PUBLIC="/var/www/dev.pardad-group.com/public_html"
PM2_NAME="dev-pardad"
NODE_APP="${REPO_DIR}/.output/server/index.mjs"
NPM_CMD="/home/ubuntu/.nvm/versions/node/v22.20.0/bin/npm"


echo "🚀 Deploy script started: $(date)"



# 🔧 لود کردن NVM و Node.js
echo "🔧 Loading NVM and Node.js..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # این nvm رو لود می‌کند
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# استفاده از نسخه پیش‌فرض Node.js
nvm use default


echo "🔑 Loading SSH keys..."
eval "$(ssh-agent -s)"
ssh-add /home/ubuntu/.ssh/id_ed25519 
# 1) برنچ و pull
cd "$REPO_DIR"
echo "🔁 Checkout branch $BRANCH"
git fetch --all --prune
git checkout "$BRANCH"
git reset --hard "origin/$BRANCH"
git pull origin "$BRANCH"

echo "📦 Installing dependencies (npm ci)..."
$NPM_CMD ci

echo "🏗️ Building project (npm run build)..."
$NPM_CMD run build

# 3) سینک فایل‌های public (استاتیک)
echo "📁 Syncing static files to $SITE_PUBLIC ..."
sudo mkdir -p "$SITE_PUBLIC"
sudo rsync -av --delete "${REPO_DIR}/.output/public/" "$SITE_PUBLIC/"

# 4) تنظیم مالکیت
echo "🔐 Setting ownership to www-data:www-data on $SITE_PUBLIC ..."
sudo chown -R www-data:www-data "$SITE_PUBLIC"

# 5) مدیریت pm2 برای سرور نود (Nuxt server)
if pm2 describe "$PM2_NAME" > /dev/null 2>&1; then
  echo "♻️ PM2 process '$PM2_NAME' exists — restarting..."
  pm2 restart "$PM2_NAME"
else
  echo "▶️ Starting PM2 process '$PM2_NAME' with $NODE_APP"
  pm2 start "$NODE_APP" --name "$PM2_NAME"
fi

# اطمینان از ذخیرهٔ pm2 برای startup
pm2 save || true

echo "✅ Deploy finished at: $(date)"

