#!/bin/bash
set -e
echo "🚀 Deploying Nuxt Production Site..."

cd ~/projects/pardad-site
git checkout production
git pull origin production

npm ci
npm run build

sudo rsync -av --delete .output/public/ /var/www/pardad-group.com/public_html/

sudo chown -R www-data:www-data /var/www/pardad-group.com
echo "✅ Nuxt Production deployed successfully!"
