# 🐛 Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the RAGFlow playground setup.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Service Issues](#service-issues)
- [Configuration Problems](#configuration-problems)
- [Performance Issues](#performance-issues)
- [API Issues](#api-issues)
- [Data Issues](#data-issues)
- [Common Error Messages](#common-error-messages)
- [Advanced Debugging](#advanced-debugging)

## Quick Diagnostics

### Health Check Commands

Run these commands to quickly check system health:

```bash
# Check all services
docker-compose ps

# Check service logs
docker-compose logs --tail=50

# Check system resources
docker stats

# Test network connectivity
docker-compose exec ragflow ping es01
docker-compose exec ragflow ping mysql
docker-compose exec ragflow ping redis
docker-compose exec ragflow ping minio
```

### Service Status Check

```bash
# RAGFlow health
curl -f http://localhost:9380/health || echo "RAGFlow not responding"

# Elasticsearch health
curl -f http://localhost:1200/_cluster/health || echo "Elasticsearch not responding"

# MinIO health
curl -f http://localhost:9000/minio/health/live || echo "MinIO not responding"

# Redis health
docker-compose exec redis redis-cli ping || echo "Redis not responding"

# MySQL health
docker-compose exec mysql mysqladmin ping -h localhost || echo "MySQL not responding"
```

## Service Issues

### RAGFlow Service Issues

#### RAGFlow Won't Start

**Symptoms**: RAGFlow container keeps restarting or shows "Exited" status

**Diagnostic Commands**:
```bash
# Check RAGFlow logs
docker-compose logs ragflow

# Check resource usage
docker stats ragflow

# Check configuration
docker-compose exec ragflow cat /ragflow/conf/service_conf.yaml
```

**Common Causes & Solutions**:

1. **Missing configuration template**:
   ```bash
   # Check if template exists
   ls -la conf/service_conf.yaml.template
   
   # If missing, recreate it
   cp conf/service_conf.yaml conf/service_conf.yaml.template
   ```

2. **Database connection issues**:
   ```bash
   # Test MySQL connection
   docker-compose exec ragflow mysql -h mysql -u ragflow -pinfiniflow ragflow
   ```

3. **Insufficient memory**:
   ```bash
   # Check available memory
   free -h
   
   # Reduce memory usage in docker-compose.yml
   environment:
     - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
   ```

#### RAGFlow API Not Responding

**Symptoms**: API endpoint returns 502, 503, or connection refused

**Diagnostic Commands**:
```bash
# Check if RAGFlow is listening on correct port
docker-compose exec ragflow netstat -tlnp | grep 9380

# Check nginx configuration (if using)
docker-compose exec ragflow nginx -t

# Test internal API
docker-compose exec ragflow curl localhost:9380/health
```

**Solutions**:
1. Restart RAGFlow service: `docker-compose restart ragflow`
2. Check firewall rules: `sudo ufw status`
3. Verify port mapping in docker-compose.yml

### Database Issues

#### MySQL Connection Problems

**Symptoms**: "Can't connect to MySQL server" errors

**Diagnostic Commands**:
```bash
# Check MySQL status
docker-compose logs mysql

# Test connection
docker-compose exec mysql mysql -u root -pinfiniflow

# Check user privileges
docker-compose exec mysql mysql -u root -pinfiniflow -e "SELECT User, Host FROM mysql.user;"
```

**Solutions**:
1. **User doesn't exist**:
   ```sql
   CREATE USER 'ragflow'@'%' IDENTIFIED BY 'infiniflow';
   GRANT ALL PRIVILEGES ON ragflow.* TO 'ragflow'@'%';
   FLUSH PRIVILEGES;
   ```

2. **Database doesn't exist**:
   ```sql
   CREATE DATABASE ragflow CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. **Authentication plugin issue**:
   ```sql
   ALTER USER 'ragflow'@'%' IDENTIFIED WITH mysql_native_password BY 'infiniflow';
   ```

#### Redis Connection Problems

**Symptoms**: "Connection refused" or "AUTH failed" errors

**Diagnostic Commands**:
```bash
# Check Redis status
docker-compose logs redis

# Test connection without password
docker-compose exec redis redis-cli ping

# Test connection with password
docker-compose exec redis redis-cli -a infiniflow ping
```

**Solutions**:
1. **Wrong password**:
   ```bash
   # Check Redis configuration
   docker-compose exec redis cat /etc/redis/redis.conf | grep requirepass
   ```

2. **Redis not accepting connections**:
   ```bash
   # Check Redis binding
   docker-compose exec redis redis-cli CONFIG GET bind
   ```

### Elasticsearch Issues

#### Elasticsearch Won't Start

**Symptoms**: Elasticsearch container exits or shows unhealthy status

**Diagnostic Commands**:
```bash
# Check Elasticsearch logs
docker-compose logs elasticsearch

# Check Java heap size
docker-compose exec elasticsearch cat /proc/meminfo
```

**Common Errors & Solutions**:

1. **Out of memory**:
   ```yaml
   # Reduce memory in docker-compose.yml
   environment:
     - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
   ```

2. **Bootstrap checks failed**:
   ```bash
   # Increase virtual memory
   sudo sysctl -w vm.max_map_count=262144
   echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
   ```

3. **Port already in use**:
   ```bash
   # Find process using port 1200
   sudo lsof -i :1200
   
   # Kill process or change port
   sudo kill -9 <PID>
   ```

#### Elasticsearch Cluster Health Issues

**Symptoms**: Cluster status is red or yellow

**Diagnostic Commands**:
```bash
# Check cluster health
curl http://localhost:1200/_cluster/health?pretty

# Check node status
curl http://localhost:1200/_cat/nodes?v

# Check indices status
curl http://localhost:1200/_cat/indices?v
```

**Solutions**:
1. **Unassigned shards**:
   ```bash
   # For single-node setup, set replicas to 0
   curl -X PUT http://localhost:1200/_all/_settings -H "Content-Type: application/json" -d '{
     "index": {
       "number_of_replicas": 0
     }
   }'
   ```

### MinIO Issues

#### MinIO Access Problems

**Symptoms**: Can't access MinIO console or API

**Diagnostic Commands**:
```bash
# Check MinIO logs
docker-compose logs minio

# Test MinIO health
curl http://localhost:9000/minio/health/live

# Test console access
curl http://localhost:9001
```

**Solutions**:
1. **Wrong credentials**:
   ```bash
   # Check MinIO environment variables
   docker-compose exec minio env | grep MINIO_ROOT
   ```

2. **Port conflicts**:
   ```bash
   # Check ports
   sudo netstat -tlnp | grep -E ':(9000|9001)'
   ```

## Configuration Problems

### Environment Variable Issues

**Problem**: Services can't read environment variables

**Diagnostic Commands**:
```bash
# Check environment file
cat .env

# Check if variables are loaded
docker-compose config
```

**Solutions**:
1. **Missing .env file**:
   ```bash
   cp .env.example .env
   ```

2. **Syntax errors in .env**:
   ```bash
   # Check for spaces around = sign
   grep -n '.*\s=\s.*' .env
   ```

### Port Conflicts

**Problem**: Services can't bind to ports

**Diagnostic Commands**:
```bash
# Check port usage
sudo netstat -tlnp | grep -E ':(80|1200|5455|6379|9000|9001|9380|11434)'

# Find processes using specific port
sudo lsof -i :80
```

**Solutions**:
1. **Change ports in docker-compose.yml**:
   ```yaml
   ports:
     - "8080:80"  # Change external port
   ```

2. **Stop conflicting services**:
   ```bash
   sudo systemctl stop apache2  # If using port 80
   sudo systemctl stop nginx    # If using port 80
   ```

### Volume Mount Issues

**Problem**: Persistent data not working

**Diagnostic Commands**:
```bash
# Check volume mounts
docker-compose exec ragflow df -h

# Check volume permissions
docker-compose exec ragflow ls -la /ragflow
```

**Solutions**:
1. **Permission issues**:
   ```bash
   # Fix ownership
   sudo chown -R $USER:$USER ./conf
   sudo chmod -R 755 ./conf
   ```

2. **Volume not mounted**:
   ```bash
   # Recreate volumes
   docker-compose down -v
   docker-compose up -d
   ```

## Performance Issues

### Slow Response Times

**Symptoms**: API calls take too long to complete

**Diagnostic Commands**:
```bash
# Check resource usage
docker stats

# Check system load
top

# Check disk I/O
iostat -x 1
```

**Solutions**:
1. **Increase memory allocation**:
   ```yaml
   # In docker-compose.yml
   deploy:
     resources:
       limits:
         memory: 4G
   ```

2. **Optimize Elasticsearch**:
   ```bash
   # Disable swapping
   sudo swapoff -a
   
   # Increase file descriptors
   ulimit -n 65536
   ```

3. **Database optimization**:
   ```sql
   # Add indexes for frequent queries
   CREATE INDEX idx_document_id ON chunks(document_id);
   CREATE INDEX idx_embedding ON vectors(embedding);
   ```

### High Memory Usage

**Symptoms**: System running out of memory

**Diagnostic Commands**:
```bash
# Check memory usage by container
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Check system memory
free -h
```

**Solutions**:
1. **Reduce Elasticsearch heap**:
   ```yaml
   environment:
     - "ES_JAVA_OPTS=-Xms512m -Xmx1g"
   ```

2. **Limit container memory**:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 2G
   ```

3. **Enable swap** (if needed):
   ```bash
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

## API Issues

### Authentication Errors

**Symptoms**: 401 Unauthorized responses

**Diagnostic Commands**:
```bash
# Test API without authentication
curl http://localhost:9380/health

# Check authentication configuration
docker-compose exec ragflow cat /ragflow/conf/service_conf.yaml | grep -A 10 auth
```

**Solutions**:
1. **Get valid token**:
   ```bash
   # Login to get token
   curl -X POST http://localhost:9380/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username": "admin", "password": "password"}'
   ```

2. **Use token in requests**:
   ```bash
   curl -H "Authorization: Bearer <token>" \
     http://localhost:9380/api/v1/knowledge-bases
   ```

### Rate Limiting

**Symptoms**: 429 Too Many Requests

**Solutions**:
1. **Increase rate limits**:
   ```yaml
   # In service configuration
   rate_limit:
     requests_per_minute: 120
     burst_size: 20
   ```

2. **Implement backoff**:
   ```python
   import time
   import requests
   
   def api_call_with_retry(url, max_retries=3):
       for i in range(max_retries):
           response = requests.get(url)
           if response.status_code != 429:
               return response
           time.sleep(2 ** i)  # Exponential backoff
       return response
   ```

## Data Issues

### Document Upload Failures

**Symptoms**: Documents fail to process or upload

**Diagnostic Commands**:
```bash
# Check upload limits
docker-compose exec ragflow cat /ragflow/conf/service_conf.yaml | grep max_file_size

# Check MinIO storage
curl http://localhost:9001  # Access MinIO console
```

**Solutions**:
1. **Increase file size limit**:
   ```yaml
   # In service_conf.yaml.template
   document:
     max_file_size: 500MB
   ```

2. **Check file format support**:
   ```bash
   # List supported formats
   curl http://localhost:9380/api/v1/supported-formats
   ```

3. **Check disk space**:
   ```bash
   df -h
   docker system df
   ```

### Embedding Generation Issues

**Symptoms**: Documents uploaded but embeddings not generated

**Diagnostic Commands**:
```bash
# Check embedding service status
curl http://localhost:9380/api/v1/embedding/health

# Check processing queue
docker-compose logs ragflow | grep embedding
```

**Solutions**:
1. **Restart embedding workers**:
   ```bash
   docker-compose restart ragflow
   ```

2. **Check API keys**:
   ```bash
   # Verify OpenAI API key
   curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models
   ```

## Common Error Messages

### "service_conf.yaml.template: No such file or directory"

**Solution**:
```bash
# Create the template file
cat > conf/service_conf.yaml.template << 'EOF'
mysql:
  name: 'ragflow'
  user: 'ragflow'
  password: 'infiniflow'
  host: 'mysql'
  port: 3306

redis:
  host: 'redis'
  port: 6379
  password: 'infiniflow'

elasticsearch:
  hosts: 'es01:9200'
  name: 'ragflow'

minio:
  user: 'root'
  password: '12345678'
  host: 'minio:9000'
EOF
```

### "Connection refused" errors

**Solution**:
```bash
# Check if services are running
docker-compose ps

# Restart services in order
docker-compose up -d mysql redis elasticsearch minio
sleep 30
docker-compose up -d ragflow
```

### "Out of disk space" errors

**Solution**:
```bash
# Clean up Docker
docker system prune -a
docker volume prune

# Remove old containers
docker container prune

# Remove unused images
docker image prune -a
```

## Advanced Debugging

### Enable Debug Logging

```yaml
# In docker-compose.yml
ragflow:
  environment:
    - RAGFLOW_LOG_LEVEL=DEBUG
    - PYTHONPATH=/ragflow
    - RAGFLOW_DEBUG=true
```

### Container Shell Access

```bash
# Access RAGFlow container
docker-compose exec ragflow bash

# Access MySQL container
docker-compose exec mysql bash

# Access Elasticsearch container
docker-compose exec elasticsearch bash
```

### Network Debugging

```bash
# Check Docker networks
docker network ls

# Inspect network
docker network inspect rag-playground_ragflow_network

# Test connectivity between containers
docker-compose exec ragflow ping mysql
docker-compose exec ragflow nslookup es01
```

### Performance Profiling

```bash
# Monitor resource usage
docker stats

# Check slow queries (MySQL)
docker-compose exec mysql mysql -u ragflow -pinfiniflow ragflow -e "
SELECT query_time, lock_time, rows_sent, rows_examined, sql_text 
FROM mysql.slow_log 
ORDER BY query_time DESC 
LIMIT 10;"

# Check Elasticsearch performance
curl "http://localhost:1200/_cat/thread_pool/search?v&h=node_name,name,active,rejected,completed"
```

## Getting Additional Help

### Collect System Information

Run this script to collect diagnostic information:

```bash
#!/bin/bash
echo "=== System Information ===" > debug_info.txt
uname -a >> debug_info.txt
docker --version >> debug_info.txt
docker-compose --version >> debug_info.txt

echo -e "\n=== Docker Compose Status ===" >> debug_info.txt
docker-compose ps >> debug_info.txt

echo -e "\n=== Service Logs ===" >> debug_info.txt
docker-compose logs --tail=100 >> debug_info.txt

echo -e "\n=== Resource Usage ===" >> debug_info.txt
docker stats --no-stream >> debug_info.txt

echo -e "\n=== Disk Usage ===" >> debug_info.txt
df -h >> debug_info.txt

echo -e "\n=== Memory Usage ===" >> debug_info.txt
free -h >> debug_info.txt

echo "Debug information saved to debug_info.txt"
```

### Community Support

- 📧 **Issues**: [GitHub Issues](https://github.com/infiniflow/ragflow/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/infiniflow/ragflow/discussions)
- 📖 **Documentation**: [Official Docs](https://ragflow.io/docs/)
- 🔗 **Community**: [Discord/Slack Channel]

### Professional Support

For enterprise support, contact:
- 📧 Email: support@infiniflow.ai
- 🌐 Website: https://ragflow.io/support
- 📞 Phone: [Enterprise Support Number]

Remember to include your debug information and describe:
1. What you were trying to do
2. What happened instead
3. Steps to reproduce the issue
4. Your system configuration
