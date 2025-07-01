# 🚀 RAGFlow Playground

A complete Docker Compose setup for **RAGFlow** - an open-source RAG (Retrieval-Augmented Generation) engine. This playground provides everything you need to test, develop, and experiment with RAG workflows.

![RAGFlow](https://img.shields.io/badge/RAGFlow-v0.19.1-blue)
![Docker](https://img.shields.io/badge/Docker-Required-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## 📋 Table of Contents

- [What's Included](#whats-included)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Service Access Points](#service-access-points)
- [Configuration](#configuration)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 What's Included

| Service | Description | Port | Status |
|---------|-------------|------|--------|
| **RAGFlow** | Main RAG engine with web interface | 80, 9380 | ✅ Ready |
| **MySQL** | Database for RAGFlow data storage | 5455 | ✅ Ready |
| **Redis** | Caching and session management | 6379 | ✅ Ready |
| **Elasticsearch** | Vector search and document indexing | 1200, 9300 | ✅ Ready |
| **MinIO** | Object storage for documents | 9000, 9001 | ✅ Ready |
| **Ollama** | Optional local LLM inference | 11434 | 🔧 Optional |

## 📋 Prerequisites

- **CPU**: ≥ 4 cores
- **RAM**: ≥ 16 GB
- **Disk**: ≥ 50 GB free space
- **Docker**: ≥ 24.0.0
- **Docker Compose**: ≥ v2.26.1

## 🚀 Quick Start

### 1. Clone and Start

```bash
# Clone the repository
git clone <your-repo-url>
cd rag-playground

# Start all services
docker-compose up -d

# Check service status
docker-compose ps
```

### 2. Wait for Services

```bash
# Monitor RAGFlow startup
docker-compose logs -f ragflow

# Wait for this message: "RAGFlow is ready!"
```

### 3. Access RAGFlow

- 🌐 **Web Interface**: http://localhost
- 🔌 **API Endpoint**: http://localhost:9380
- 📊 **MinIO Console**: http://localhost:9001

## 🔗 Service Access Points

### Primary Services
- **RAGFlow Web UI**: http://localhost
- **RAGFlow API**: http://localhost:9380

### Supporting Services
- **Elasticsearch**: http://localhost:1200
- **MinIO Console**: http://localhost:9001 (root/12345678)
- **MySQL**: localhost:5455 (ragflow/infiniflow)
- **Redis**: localhost:6379 (password: infiniflow)
- **Ollama API**: http://localhost:11434 (if enabled)

## ⚙️ Configuration

### Default Credentials

| Service | Username | Password | Database/Bucket |
|---------|----------|----------|-----------------|
| MySQL | `ragflow` | `infiniflow` | `ragflow` |
| Redis | - | `infiniflow` | - |
| MinIO | `root` | `12345678` | - |

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

### Service Configuration

Edit `conf/service_conf.yaml.template` to customize RAGFlow settings:
- Database connections
- LLM API configurations
- Chat parameters
- Storage settings

## 📚 Documentation

Detailed documentation is available in the `docs/` folder:

- 📖 [Installation Guide](docs/installation.md)
- 🔧 [Configuration Guide](docs/configuration.md)
- 🚀 [Getting Started](docs/getting-started.md)
- 🐛 [Troubleshooting](docs/troubleshooting.md)
- 🔌 [API Reference](docs/api-reference.md)
- 🤖 [LLM Integration](docs/llm-integration.md)

## 🛠️ Common Operations

### Managing Services

```bash
# Stop all services
docker-compose down

# Remove all data (careful!)
docker-compose down -v

# View logs for specific service
docker-compose logs [service_name]

# Restart a specific service
docker-compose restart [service_name]

# Scale Ollama (if needed)
docker-compose up -d --scale ollama=2
```

### Health Checks

```bash
# Check all service health
docker-compose ps

# Check RAGFlow health
curl http://localhost:9380/health

# Check Elasticsearch
curl http://localhost:1200/_cluster/health

# Check MinIO
curl http://localhost:9000/minio/health/live
```

## 🐛 Troubleshooting

### Quick Fixes

1. **Services not starting**: Check Docker resources (CPU/RAM)
2. **Port conflicts**: Ensure ports are available
3. **Permission issues**: Check Docker permissions

### Common Issues

| Issue | Solution |
|-------|----------|
| RAGFlow won't start | Check logs: `docker-compose logs ragflow` |
| Missing template file | Ensure `conf/service_conf.yaml.template` exists |
| Port 80 in use | Change to different port in docker-compose.yml |
| Out of memory | Increase Docker memory limit |

See [Troubleshooting Guide](docs/troubleshooting.md) for detailed solutions.

## 🤖 Using Local LLMs

### With Ollama

```bash
# Pull a model
docker exec ragflow_ollama ollama pull llama2

# List available models
docker exec ragflow_ollama ollama list

# Configure RAGFlow to use: http://ollama:11434
```

### With External APIs

Set environment variables in `.env`:
```bash
OPENAI_API_KEY=your_key_here
HUGGINGFACE_API_KEY=your_key_here
```

## 🧪 Development

### Building Custom Images

```bash
# Build RAGFlow from source
git clone https://github.com/infiniflow/ragflow.git
cd ragflow
docker build -t ragflow:custom .

# Update docker-compose.yml to use custom image
```

### Adding New Services

Edit `docker-compose.yml` to add additional services like:
- Vector databases (Pinecone, Chroma, etc.)
- Monitoring tools (Grafana, Prometheus)
- Additional LLM providers

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [RAGFlow Official Documentation](https://ragflow.io/docs/)
- [RAGFlow GitHub Repository](https://github.com/infiniflow/ragflow)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 💬 Support

- 📧 Issues: [GitHub Issues](https://github.com/your-repo/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/your-repo/discussions)
- 📖 Documentation: [docs/](docs/)

---

⭐ **Star this repository if you find it helpful!** ⭐