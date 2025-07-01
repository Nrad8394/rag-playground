# ⚙️ Configuration Guide

This guide covers all configuration options for the RAGFlow playground setup.

## Table of Contents

- [Environment Configuration](#environment-configuration)
- [Service Configuration](#service-configuration)
- [RAGFlow Configuration](#ragflow-configuration)
- [Database Configuration](#database-configuration)
- [Storage Configuration](#storage-configuration)
- [LLM Configuration](#llm-configuration)
- [Security Configuration](#security-configuration)

## Environment Configuration

### Environment File Setup

Copy the example environment file:

```bash
cp .env.example .env
```

### Key Environment Variables

```bash
# RAGFlow Configuration
RAGFLOW_IMAGE=infiniflow/ragflow:v0.19.1-slim
RAGFLOW_VERSION=v0.19.1-slim
TZ=Asia/Shanghai

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

# Elasticsearch Configuration
ES_JAVA_OPTS=-Xms1g -Xmx1g

# Optional: External API Keys
OPENAI_API_KEY=your_openai_api_key_here
HUGGINGFACE_API_KEY=your_huggingface_api_key_here
COHERE_API_KEY=your_cohere_api_key_here
```

### Custom Environment Variables

Add custom variables for your specific needs:

```bash
# Custom RAGFlow settings
RAGFLOW_LOG_LEVEL=INFO
RAGFLOW_DEBUG=false
RAGFLOW_WORKERS=4

# Custom resource limits
ELASTICSEARCH_MEMORY=2g
MYSQL_MEMORY=1g
REDIS_MEMORY=512m

# Custom networking
RAGFLOW_NETWORK=ragflow_network
RAGFLOW_SUBNET=172.20.0.0/16
```

## Service Configuration

### Docker Compose Override

Create `docker-compose.override.yml` for local customizations:

```yaml
version: '3.8'

services:
  ragflow:
    environment:
      - RAGFLOW_LOG_LEVEL=DEBUG
    volumes:
      - ./logs:/ragflow/logs
  
  mysql:
    environment:
      - MYSQL_SLOW_QUERY_LOG=1
    volumes:
      - ./mysql-logs:/var/log/mysql
      
  elasticsearch:
    environment:
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"  # Increase memory
```

### Resource Limits

Set resource constraints:

```yaml
services:
  ragflow:
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G
          
  elasticsearch:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
```

### Network Configuration

Custom network settings:

```yaml
networks:
  ragflow_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
```

## RAGFlow Configuration

### Service Configuration Template

The main RAGFlow configuration is in `conf/service_conf.yaml.template`:

```yaml
# Database settings
mysql:
  name: 'ragflow'
  user: 'ragflow'
  password: 'infiniflow'
  host: 'mysql'
  port: 3306
  max_connections: 100
  charset: 'utf8mb4'

# Redis settings
redis:
  host: 'redis'
  port: 6379
  password: 'infiniflow'
  db: 0
  max_connections: 100

# Elasticsearch settings
elasticsearch:
  hosts: 'es01:9200'
  name: 'ragflow'
  index_prefix: 'ragflow_'
  max_result_window: 10000

# MinIO settings
minio:
  user: 'root'
  password: '12345678'
  host: 'minio:9000'
  secure: false
  bucket: 'ragflow'

# LLM settings
llm:
  default_model: 'gpt-3.5-turbo'
  api_key: 'your_api_key_here'
  api_base: 'https://api.openai.com/v1'
  max_tokens: 1024
  temperature: 0.1
  timeout: 30

# Embedding settings
embedding:
  default_model: 'text-embedding-ada-002'
  api_key: 'your_api_key_here'
  api_base: 'https://api.openai.com/v1'
  batch_size: 32
  timeout: 30

# Chat settings
chat:
  max_tokens: 1024
  temperature: 0.1
  top_p: 1.0
  frequency_penalty: 0.0
  presence_penalty: 0.0
  max_history: 10

# Document processing
document:
  max_file_size: 100MB
  supported_formats:
    - pdf
    - docx
    - txt
    - md
    - html
  chunk_size: 512
  chunk_overlap: 50

# Search settings
search:
  top_k: 10
  similarity_threshold: 0.7
  hybrid_search: true
  boost_title: 1.5
  boost_content: 1.0
```

### Advanced RAGFlow Settings

Create `conf/advanced.yaml` for advanced configurations:

```yaml
# Performance settings
performance:
  worker_processes: 4
  max_requests_per_worker: 1000
  request_timeout: 300
  keep_alive_timeout: 2

# Logging settings
logging:
  level: INFO
  format: '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
  file: '/ragflow/logs/ragflow.log'
  max_size: 100MB
  backup_count: 5

# Security settings
security:
  secret_key: 'your-secret-key-here'
  token_expiry: 3600
  max_login_attempts: 5
  session_timeout: 1800

# Cache settings
cache:
  ttl: 3600
  max_size: 1000
  eviction_policy: 'lru'

# Rate limiting
rate_limit:
  requests_per_minute: 60
  burst_size: 10
  enabled: true
```

## Database Configuration

### MySQL Optimization

Create `conf/mysql.cnf`:

```ini
[mysqld]
# Basic settings
port = 3306
socket = /var/run/mysqld/mysqld.sock
datadir = /var/lib/mysql

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# InnoDB settings
innodb_buffer_pool_size = 2G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1

# Connection settings
max_connections = 200
max_connect_errors = 1000
wait_timeout = 28800
interactive_timeout = 28800

# Query cache
query_cache_type = 1
query_cache_size = 128M
query_cache_limit = 2M

# Logging
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

Add to docker-compose.yml:

```yaml
mysql:
  volumes:
    - ./conf/mysql.cnf:/etc/mysql/conf.d/custom.cnf
```

### Redis Optimization

Create `conf/redis.conf`:

```conf
# Memory management
maxmemory 1gb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000

# Network
timeout 300
tcp-keepalive 300

# Logging
loglevel notice
logfile ""

# Performance
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
```

## Storage Configuration

### MinIO Configuration

Create `conf/minio.env`:

```bash
# Server settings
MINIO_BROWSER=on
MINIO_DOMAIN=localhost
MINIO_SERVER_URL=http://localhost:9000
MINIO_BROWSER_REDIRECT_URL=http://localhost:9001

# Console settings
MINIO_PROMETHEUS_AUTH_TYPE=public

# Regional settings
MINIO_REGION_NAME=us-east-1

# Compression
MINIO_COMPRESS=on
MINIO_COMPRESS_EXTENSIONS=.txt,.log,.csv,.json,.xml

# Cache settings
MINIO_CACHE=on
MINIO_CACHE_DRIVES=/tmp/cache
MINIO_CACHE_EXCLUDE="*.pdf,*.mp4"
MINIO_CACHE_QUOTA=80
MINIO_CACHE_AFTER=0
MINIO_CACHE_WATERMARK_LOW=70
MINIO_CACHE_WATERMARK_HIGH=90
```

### Elasticsearch Configuration

Create `conf/elasticsearch.yml`:

```yaml
# Cluster settings
cluster.name: ragflow-es
node.name: es01
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node

# Memory settings
bootstrap.memory_lock: false
indices.memory.index_buffer_size: 10%
indices.memory.min_index_buffer_size: 48mb

# Index settings
index.number_of_shards: 1
index.number_of_replicas: 0
index.max_result_window: 10000

# Search settings
search.max_buckets: 65536
indices.query.bool.max_clause_count: 4096

# Logging
logger.level: INFO
```

## LLM Configuration

### OpenAI Configuration

```yaml
llm_providers:
  openai:
    api_key: ${OPENAI_API_KEY}
    api_base: https://api.openai.com/v1
    models:
      gpt-4:
        max_tokens: 4096
        temperature: 0.1
        cost_per_1k_tokens: 0.03
      gpt-3.5-turbo:
        max_tokens: 4096
        temperature: 0.1
        cost_per_1k_tokens: 0.002
    default_model: gpt-3.5-turbo
```

### Ollama Configuration

```yaml
llm_providers:
  ollama:
    api_base: http://ollama:11434
    models:
      llama2:
        context_length: 4096
        temperature: 0.1
      codellama:
        context_length: 16384
        temperature: 0.1
    default_model: llama2
```

### HuggingFace Configuration

```yaml
llm_providers:
  huggingface:
    api_key: ${HUGGINGFACE_API_KEY}
    api_base: https://api-inference.huggingface.co
    models:
      microsoft/DialoGPT-medium:
        max_length: 1000
        temperature: 0.7
      facebook/blenderbot-400M-distill:
        max_length: 128
        temperature: 0.7
```

## Security Configuration

### SSL/TLS Setup

Create `conf/nginx.conf` for HTTPS:

```nginx
server {
    listen 443 ssl http2;
    server_name localhost;
    
    ssl_certificate /etc/ssl/certs/ragflow.crt;
    ssl_certificate_key /etc/ssl/private/ragflow.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    location / {
        proxy_pass http://ragflow:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Authentication Configuration

```yaml
authentication:
  method: local  # local, oauth, ldap
  session_timeout: 1800
  password_policy:
    min_length: 8
    require_uppercase: true
    require_lowercase: true
    require_numbers: true
    require_special: true
  
  oauth:
    providers:
      google:
        client_id: your_google_client_id
        client_secret: your_google_client_secret
        redirect_uri: http://localhost/auth/google/callback
      
  ldap:
    server: ldap://your-ldap-server:389
    bind_dn: cn=admin,dc=example,dc=com
    bind_password: admin_password
    user_base: ou=users,dc=example,dc=com
```

## Monitoring Configuration

### Logging Configuration

```yaml
logging:
  loggers:
    ragflow:
      level: INFO
      handlers: [console, file]
      propagate: false
    
    elasticsearch:
      level: WARN
      handlers: [console]
      propagate: false
      
    mysql:
      level: ERROR
      handlers: [file]
      propagate: false
  
  handlers:
    console:
      class: logging.StreamHandler
      formatter: standard
      stream: ext://sys.stdout
      
    file:
      class: logging.handlers.RotatingFileHandler
      filename: /ragflow/logs/ragflow.log
      maxBytes: 104857600  # 100MB
      backupCount: 5
      formatter: standard
  
  formatters:
    standard:
      format: '%(asctime)s [%(levelname)s] %(name)s: %(message)s'
```

### Health Check Configuration

```yaml
health_checks:
  enabled: true
  interval: 30
  timeout: 10
  retries: 3
  
  endpoints:
    - name: database
      url: mysql://ragflow:infiniflow@mysql:3306/ragflow
      type: mysql
    
    - name: cache
      url: redis://redis:6379/0
      type: redis
      auth: infiniflow
    
    - name: search
      url: http://es01:9200/_cluster/health
      type: http
    
    - name: storage
      url: http://minio:9000/minio/health/live
      type: http
```

## Backup Configuration

### Database Backup

Create `scripts/backup.sh`:

```bash
#!/bin/bash

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# MySQL backup
docker exec ragflow_mysql mysqldump -u ragflow -pinfiniflow ragflow > $BACKUP_DIR/mysql_backup_$DATE.sql

# Redis backup
docker exec ragflow_redis redis-cli --rdb - > $BACKUP_DIR/redis_backup_$DATE.rdb

# MinIO backup
docker exec ragflow_minio mc mirror minio/ragflow $BACKUP_DIR/minio_backup_$DATE/

echo "Backup completed: $DATE"
```

Add to crontab:

```bash
# Daily backup at 2 AM
0 2 * * * /path/to/rag-playground/scripts/backup.sh
```

## Next Steps

- 🚀 [Getting Started Guide](getting-started.md)
- 🔌 [API Reference](api-reference.md)
- 🤖 [LLM Integration](llm-integration.md)
- 🐛 [Troubleshooting](troubleshooting.md)
