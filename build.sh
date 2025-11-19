#!/bin/bash
set -e
cd /repo
git fetch origin main
git reset --hard origin/main
hugo --destination /var/www/hugo-public
echo "Build completed at $(date)"