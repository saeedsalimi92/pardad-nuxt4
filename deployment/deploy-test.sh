#!/bin/bash
set -e
echo "🚀 Deploying Nuxt Dev Site..."

cd ~/projects/pardad-site
git checkout test
git pull origin test

npm ci
npm run build

sudo rsync -av --delete .output/public/ /var/www/test.pardad-group.com/public_html/

sudo chown -R www-data:www-data /var/www/test.pardad-group.com
echo "✅ Nuxt Dev deployed successfully!"
