# Hugo Webhook Build System

A containerized webhook listener that automatically builds and deploys Hugo sites when changes are pushed to the main branch of a GitHub repository.

## Overview

This system consists of:
- **webhook-listener.py**: Flask app that receives GitHub webhooks
- **build.sh**: Script that pulls latest changes and builds the Hugo site
- **Dockerfile**: Container setup with Hugo and Python

## Setup

### 1. Setup Environment Variables

```bash
cp .env.example .env
# Edit .env and set your WEBHOOK_SECRET
```

### 2. Deploy with Docker Compose (Recommended)

```bash
docker-compose up -d
```

### 3. Configure GitHub Webhook

1. Go to your GitHub repository → Settings → Webhooks
2. Click "Add webhook"
3. Set Payload URL: `http://your-server:8080/webhook`
4. Content type: `application/json`
5. Secret: Same as your `WEBHOOK_SECRET`
6. Select "Just the push event"
7. Ensure "Active" is checked

## Repository Setup

Since this setup uses Docker named volumes, you need to clone your Hugo repository into the container's volume. After starting the service:

```bash
# Start the service first
docker-compose up -d

# Clone your Hugo repository into the container's repo volume
docker-compose exec hugo-webhook git clone https://github.com/borum-by/hjemmeside.git /repo
```

## Volume Management

This setup uses Docker named volumes for better portability:

- `hugo-repo` - Contains your Hugo repository
- `hugo-public` - Contains the built Hugo site output

### Accessing Volume Data

To access files in the volumes:
```bash
# Access the repository volume
docker-compose exec hugo-webhook bash -c "ls -la /repo"

# Access the public volume  
docker-compose exec hugo-webhook bash -c "ls -la /var/www/hugo-public"
```

## How It Works

1. GitHub sends a webhook when code is pushed to the main branch
2. The Flask app validates the webhook signature for security
3. If valid and the push is to the main branch, it triggers the build script
4. The build script:
   - Fetches the latest changes from GitHub
   - Resets to the latest main branch state
   - Builds the Hugo site to `/var/www/hugo-public`
   - Logs the completion time

## Security Features

- **HMAC Signature Validation**: Verifies webhooks are from GitHub using your secret
- **Branch Filtering**: Only builds on pushes to the main branch
- **Container Isolation**: Runs in a containerized environment

## Monitoring

Check container logs to monitor webhook activity and builds:

```bash
docker-compose logs -f hugo-webhook
```

## Docker Compose Commands

```bash
# Start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# Check service status
docker-compose ps
```
