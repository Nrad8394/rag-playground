# 📦 Installation Guide

This guide will walk you through setting up the RAGFlow playground step by step.

## Table of Contents

- [System Requirements](#system-requirements)
- [Docker Installation](#docker-installation)
- [Project Setup](#project-setup)
- [Service Configuration](#service-configuration)
- [First Run](#first-run)
- [Verification](#verification)

## System Requirements

### Minimum Requirements

| Resource | Minimum | Recommended | Notes |
|----------|---------|-------------|-------|
| **CPU** | 4 cores | 8+ cores | More cores = better performance |
| **RAM** | 16 GB | 32+ GB | RAG operations are memory intensive |
| **Storage** | 50 GB | 100+ GB | For models and document storage |
| **Network** | Stable internet | High bandwidth | For downloading models |

### Operating System Support

- ✅ **Linux** (Ubuntu 20.04+, CentOS 8+, etc.)
- ✅ **macOS** (10.15+, including Apple Silicon)
- ✅ **Windows** (10/11 with WSL2)

## Docker Installation

### Linux (Ubuntu/Debian)

```bash
# Update package index
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### macOS

```bash
# Install Docker Desktop
# Download from: https://docs.docker.com/desktop/mac/install/

# Or use Homebrew
brew install --cask docker

# Verify installation
docker --version
docker-compose --version
```

### Windows

1. **Enable WSL2**:
   ```powershell
   wsl --install
   ```

2. **Install Docker Desktop**:
   - Download from: https://docs.docker.com/desktop/windows/install/
   - Enable WSL2 integration

3. **Verify in PowerShell**:
   ```powershell
   docker --version
   docker-compose --version
   ```

## Project Setup

### 1. Clone Repository

```bash
# Clone the repository
git clone <your-repository-url>
cd rag-playground

# Or download and extract ZIP
# wget <download-url>
# unzip rag-playground.zip && cd rag-playground
```

### 2. Directory Structure

After cloning, you should see:

```
rag-playground/
├── docker-compose.yml          # Main service definitions
├── .env.example               # Environment template
├── .gitignore                 # Git ignore rules
├── README.md                  # Main documentation
├── conf/                      # RAGFlow configuration
│   └── service_conf.yaml.template
└── docs/                      # Documentation
    ├── installation.md
    ├── configuration.md
    └── ...
```

### 3. Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables (optional)
nano .env  # or vim, code, etc.
```

### 4. Configuration Files

The configuration files should already be in place:

```bash
# Verify configuration exists
ls -la conf/
# Should show: service_conf.yaml.template

# Check Docker Compose config
docker-compose config
```

## Service Configuration

### Environment Variables

Key variables in `.env`:

```bash
# RAGFlow Configuration
RAGFLOW_IMAGE=infiniflow/ragflow:v0.19.1-slim
RAGFLOW_VERSION=v0.19.1-slim

# Database Configuration
MYSQL_ROOT_PASSWORD=infiniflow
MYSQL_DATABASE=ragflow
MYSQL_USER=ragflow
MYSQL_PASSWORD=infiniflow

# Redis Configuration
REDIS_PASSWORD=infiniflow

# MinIO Configuration
MINIO_ROOT_USER=root
MINIO_ROOT_PASSWORD=12345678
```

### Port Configuration

Default ports used:

| Service | External Port | Internal Port | Purpose |
|---------|---------------|---------------|---------|
| RAGFlow Web | 80 | 80 | Web interface |
| RAGFlow API | 9380 | 9380 | REST API |
| MySQL | 5455 | 3306 | Database |
| Redis | 6379 | 6379 | Cache |
| Elasticsearch | 1200 | 9200 | Search engine |
| MinIO | 9000, 9001 | 9000, 9001 | Object storage |
| Ollama | 11434 | 11434 | Local LLM |

### Customizing Ports

If you need to change ports (due to conflicts):

```yaml
# In docker-compose.yml
services:
  ragflow:
    ports:
      - "8080:80"      # Change web port to 8080
      - "9380:9380"    # Keep API port same
```

## First Run

### 1. Start Services

```bash
# Start all services in background
docker-compose up -d

# Or start with logs visible
docker-compose up
```

### 2. Monitor Startup

```bash
# Check service status
docker-compose ps

# Monitor RAGFlow logs
docker-compose logs -f ragflow

# Monitor all services
docker-compose logs -f
```

### 3. Wait for Readiness

Services start in this order:
1. **MySQL** (takes ~30-60 seconds)
2. **Redis** (takes ~10-20 seconds)
3. **Elasticsearch** (takes ~60-120 seconds)
4. **MinIO** (takes ~10-20 seconds)
5. **RAGFlow** (takes ~2-5 minutes)

Look for these readiness indicators:

```bash
# MySQL ready
docker-compose logs mysql | grep "ready for connections"

# Redis ready
docker-compose logs redis | grep "Ready to accept connections"

# Elasticsearch ready
curl http://localhost:1200/_cluster/health

# RAGFlow ready
curl http://localhost:9380/health
```

## Verification

### 1. Service Health Checks

```bash
# Check all services are running
docker-compose ps

# Should show all services as "Up" and "healthy"
```

### 2. Web Interface

1. Open browser to: http://localhost
2. You should see the RAGFlow login/setup page
3. Create an account or log in

### 3. API Health

```bash
# Test API endpoint
curl http://localhost:9380/health

# Should return: {"status": "ok"}
```

### 4. Database Connection

```bash
# Connect to MySQL
docker exec -it ragflow_mysql mysql -u ragflow -pinfiniflow ragflow

# Should connect successfully
# Type 'exit' to disconnect
```

### 5. Storage Access

1. Open MinIO console: http://localhost:9001
2. Login with: `root` / `12345678`
3. You should see the MinIO dashboard

## Troubleshooting Installation

### Common Issues

#### Port Conflicts

```bash
# Check what's using a port
netstat -tulpn | grep :80
# or
lsof -i :80

# Kill process using port
sudo kill -9 <PID>
```

#### Docker Permission Issues

```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Fix permission on Docker socket
sudo chmod 666 /var/run/docker.sock
```

#### Out of Disk Space

```bash
# Clean up Docker
docker system prune -a

# Remove unused volumes
docker volume prune

# Check disk usage
df -h
```

#### Memory Issues

```bash
# Check memory usage
free -h

# Reduce Elasticsearch memory
# Edit docker-compose.yml:
environment:
  - "ES_JAVA_OPTS=-Xms512m -Xmx512m"  # Reduce from 1g
```

### Getting Help

If you encounter issues:

1. Check [Troubleshooting Guide](troubleshooting.md)
2. Review Docker logs: `docker-compose logs`
3. Verify system requirements
4. Check official RAGFlow documentation
5. Open an issue on GitHub

## Next Steps

After successful installation:

1. 📖 Read the [Configuration Guide](configuration.md)
2. 🚀 Follow the [Getting Started Guide](getting-started.md)
3. 🔌 Explore the [API Reference](api-reference.md)
4. 🤖 Set up [LLM Integration](llm-integration.md)
