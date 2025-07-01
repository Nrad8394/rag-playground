# 🤖 LLM Integration Guide

This guide covers integrating different Large Language Model (LLM) providers with RAGFlow.

## Table of Contents

- [Supported Providers](#supported-providers)
- [OpenAI Integration](#openai-integration)
- [Ollama (Local LLMs)](#ollama-local-llms)
- [HuggingFace Integration](#huggingface-integration)
- [Azure OpenAI](#azure-openai)
- [Anthropic Claude](#anthropic-claude)
- [Custom LLM Providers](#custom-llm-providers)
- [Performance Optimization](#performance-optimization)
- [Cost Management](#cost-management)

## Supported Providers

| Provider | Type | Models | Embedding Support | Local Hosting |
|----------|------|--------|------------------|---------------|
| **OpenAI** | Commercial | GPT-3.5, GPT-4 | ✅ text-embedding-ada-002 | ❌ |
| **Ollama** | Open Source | Llama2, CodeLlama, Mistral | ✅ Various models | ✅ |
| **HuggingFace** | Mixed | Thousands of models | ✅ sentence-transformers | ❌/✅ |
| **Azure OpenAI** | Commercial | GPT-3.5, GPT-4 | ✅ text-embedding-ada-002 | ❌ |
| **Anthropic** | Commercial | Claude-2, Claude Instant | ❌ | ❌ |
| **Cohere** | Commercial | Command, Generate | ✅ embed-english-v2.0 | ❌ |

## OpenAI Integration

### Setup

1. **Get API Key**: Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. **Add to Environment**:

```bash
# In .env file
OPENAI_API_KEY=sk-your-key-here
```

3. **Configure in RAGFlow**:

```yaml
# In conf/service_conf.yaml.template
llm_providers:
  openai:
    api_key: ${OPENAI_API_KEY}
    api_base: https://api.openai.com/v1
    default_model: gpt-3.5-turbo
    models:
      gpt-3.5-turbo:
        max_tokens: 4096
        temperature: 0.1
        cost_per_1k_tokens: 0.002
      gpt-4:
        max_tokens: 8192
        temperature: 0.1
        cost_per_1k_tokens: 0.03
        
embedding_providers:
  openai:
    api_key: ${OPENAI_API_KEY}
    api_base: https://api.openai.com/v1
    models:
      text-embedding-ada-002:
        dimensions: 1536
        max_input: 8191
        cost_per_1k_tokens: 0.0001
```

### Available Models

#### Chat Models

| Model | Max Tokens | Cost (per 1K tokens) | Use Case |
|-------|------------|---------------------|----------|
| `gpt-3.5-turbo` | 4,096 | $0.002 | General chat, fast responses |
| `gpt-3.5-turbo-16k` | 16,384 | $0.004 | Longer contexts |
| `gpt-4` | 8,192 | $0.03 | Complex reasoning |
| `gpt-4-32k` | 32,768 | $0.06 | Very long contexts |

#### Embedding Models

| Model | Dimensions | Max Input | Cost (per 1K tokens) |
|-------|------------|-----------|---------------------|
| `text-embedding-ada-002` | 1,536 | 8,191 | $0.0001 |

### Usage Examples

```python
# Using OpenAI with RAGFlow API
import requests

def chat_with_openai(message, kb_id):
    response = requests.post(
        "http://localhost:9380/api/v1/chat/completions",
        headers={"Authorization": "Bearer <token>"},
        json={
            "messages": [{"role": "user", "content": message}],
            "knowledge_base_id": kb_id,
            "model": "gpt-3.5-turbo",
            "max_tokens": 1024,
            "temperature": 0.1
        }
    )
    return response.json()
```

## Ollama (Local LLMs)

### Setup

1. **Ensure Ollama Service is Running**:

```bash
# Check if Ollama container is running
docker-compose ps ollama

# If not running, start it
docker-compose up -d ollama
```

2. **Pull Models**:

```bash
# Pull Llama2 (7B parameters)
docker exec ragflow_ollama ollama pull llama2

# Pull Code Llama (for code generation)
docker exec ragflow_ollama ollama pull codellama

# Pull Mistral (faster, smaller model)
docker exec ragflow_ollama ollama pull mistral

# List available models
docker exec ragflow_ollama ollama list
```

3. **Configure in RAGFlow**:

```yaml
# In conf/service_conf.yaml.template
llm_providers:
  ollama:
    api_base: http://ollama:11434
    default_model: llama2
    models:
      llama2:
        context_length: 4096
        temperature: 0.1
        top_p: 0.9
      codellama:
        context_length: 16384
        temperature: 0.1
        top_p: 0.95
      mistral:
        context_length: 8192
        temperature: 0.1
        top_p: 0.9

embedding_providers:
  ollama:
    api_base: http://ollama:11434
    models:
      nomic-embed-text:
        dimensions: 768
        max_input: 2048
```

### Available Models

#### Chat Models

| Model | Size | Parameters | Memory Required | Use Case |
|-------|------|------------|----------------|----------|
| `llama2` | 3.8GB | 7B | 8GB RAM | General purpose |
| `llama2:13b` | 7.3GB | 13B | 16GB RAM | Better quality |
| `llama2:70b` | 39GB | 70B | 64GB RAM | Highest quality |
| `codellama` | 3.8GB | 7B | 8GB RAM | Code generation |
| `mistral` | 4.1GB | 7B | 8GB RAM | Fast, efficient |
| `neural-chat` | 4.1GB | 7B | 8GB RAM | Conversation |

#### Embedding Models

| Model | Size | Dimensions | Use Case |
|-------|------|------------|----------|
| `nomic-embed-text` | 274MB | 768 | General embeddings |
| `all-minilm` | 23MB | 384 | Fast, lightweight |

### Custom Model Configuration

```bash
# Create a custom model with specific parameters
docker exec ragflow_ollama ollama create mymodel -f - << 'EOF'
FROM llama2

# Set custom parameters
PARAMETER temperature 0.1
PARAMETER top_p 0.9
PARAMETER top_k 40

# Custom system prompt
SYSTEM """
You are a helpful assistant specialized in answering questions based on provided context. 
Always cite your sources and be concise in your responses.
"""
EOF
```

### Usage Examples

```python
# Using Ollama with RAGFlow
def chat_with_ollama(message, kb_id):
    response = requests.post(
        "http://localhost:9380/api/v1/chat/completions",
        headers={"Authorization": "Bearer <token>"},
        json={
            "messages": [{"role": "user", "content": message}],
            "knowledge_base_id": kb_id,
            "model": "llama2",
            "provider": "ollama",
            "max_tokens": 1024,
            "temperature": 0.1
        }
    )
    return response.json()

# Direct Ollama API call
def direct_ollama_call(prompt):
    response = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "llama2",
            "prompt": prompt,
            "stream": False
        }
    )
    return response.json()
```

## HuggingFace Integration

### Setup

1. **Get API Token**: Visit [HuggingFace Tokens](https://huggingface.co/settings/tokens)
2. **Add to Environment**:

```bash
# In .env file
HUGGINGFACE_API_KEY=hf_your-token-here
```

3. **Configure in RAGFlow**:

```yaml
# In conf/service_conf.yaml.template
llm_providers:
  huggingface:
    api_key: ${HUGGINGFACE_API_KEY}
    api_base: https://api-inference.huggingface.co
    default_model: microsoft/DialoGPT-medium
    models:
      microsoft/DialoGPT-medium:
        max_length: 1000
        temperature: 0.7
        top_p: 0.9
      facebook/blenderbot-400M-distill:
        max_length: 128
        temperature: 0.7
      bigscience/bloom-560m:
        max_length: 1024
        temperature: 0.8

embedding_providers:
  huggingface:
    api_key: ${HUGGINGFACE_API_KEY}
    api_base: https://api-inference.huggingface.co
    models:
      sentence-transformers/all-MiniLM-L6-v2:
        dimensions: 384
        max_input: 256
      sentence-transformers/all-mpnet-base-v2:
        dimensions: 768
        max_input: 384
```

### Popular Models

#### Chat Models

| Model | Size | Use Case |
|-------|------|----------|
| `microsoft/DialoGPT-medium` | 350M | Conversational AI |
| `facebook/blenderbot-400M-distill` | 400M | Open-domain chat |
| `bigscience/bloom-560m` | 560M | Multilingual text generation |
| `EleutherAI/gpt-j-6B` | 6B | High-quality text generation |

#### Embedding Models

| Model | Dimensions | Performance |
|-------|------------|-------------|
| `sentence-transformers/all-MiniLM-L6-v2` | 384 | Fast, good quality |
| `sentence-transformers/all-mpnet-base-v2` | 768 | High quality |
| `sentence-transformers/multi-qa-mpnet-base-dot-v1` | 768 | QA optimized |

### Self-Hosted HuggingFace

```bash
# Run HuggingFace Transformers locally
docker run -d \
  --name huggingface-api \
  -p 8080:80 \
  -e MODEL_ID=microsoft/DialoGPT-medium \
  -e NUM_WORKERS=1 \
  huggingface/text-generation-inference
```

## Azure OpenAI

### Setup

1. **Create Azure OpenAI Resource**
2. **Get Credentials**:
   - API Key
   - Endpoint URL
   - Deployment names

3. **Configure in RAGFlow**:

```yaml
# In conf/service_conf.yaml.template
llm_providers:
  azure_openai:
    api_key: ${AZURE_OPENAI_API_KEY}
    api_base: https://your-resource.openai.azure.com/
    api_version: "2023-05-15"
    deployment_name: gpt-35-turbo
    models:
      gpt-35-turbo:
        deployment_name: gpt-35-turbo
        max_tokens: 4096
        temperature: 0.1
      gpt-4:
        deployment_name: gpt-4
        max_tokens: 8192
        temperature: 0.1

embedding_providers:
  azure_openai:
    api_key: ${AZURE_OPENAI_API_KEY}
    api_base: https://your-resource.openai.azure.com/
    api_version: "2023-05-15"
    models:
      text-embedding-ada-002:
        deployment_name: text-embedding-ada-002
        dimensions: 1536
```

### Environment Variables

```bash
# In .env file
AZURE_OPENAI_API_KEY=your-azure-key
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_VERSION=2023-05-15
```

## Anthropic Claude

### Setup

1. **Get API Key**: Visit [Anthropic Console](https://console.anthropic.com/)
2. **Configure in RAGFlow**:

```yaml
# In conf/service_conf.yaml.template
llm_providers:
  anthropic:
    api_key: ${ANTHROPIC_API_KEY}
    api_base: https://api.anthropic.com
    default_model: claude-2
    models:
      claude-2:
        max_tokens: 100000
        temperature: 0.1
      claude-instant-1:
        max_tokens: 100000
        temperature: 0.1
```

### Environment Variables

```bash
# In .env file
ANTHROPIC_API_KEY=sk-ant-your-key
```

### Usage Notes

- Claude has a much larger context window (100K tokens)
- Excellent for complex reasoning and long documents
- No embedding model available (use OpenAI or alternatives)

## Custom LLM Providers

### Adding a New Provider

1. **Create Provider Configuration**:

```yaml
# In conf/service_conf.yaml.template
llm_providers:
  custom_provider:
    api_key: ${CUSTOM_API_KEY}
    api_base: https://your-api-endpoint.com
    default_model: your-model-name
    headers:
      Custom-Header: value
    models:
      your-model-name:
        max_tokens: 2048
        temperature: 0.1
```

2. **API Compatibility**: Ensure your provider supports OpenAI-compatible API format:

```json
{
  "model": "your-model",
  "messages": [
    {"role": "user", "content": "Hello"}
  ],
  "max_tokens": 1024,
  "temperature": 0.1
}
```

### Local Model Deployment

```bash
# Example: Deploy local model with vLLM
docker run -d \
  --name local-llm \
  --gpus all \
  -p 8080:8000 \
  vllm/vllm-openai:latest \
  --model meta-llama/Llama-2-7b-chat-hf \
  --tensor-parallel-size 1
```

## Performance Optimization

### Model Selection Guidelines

| Use Case | Recommended Models | Priority |
|----------|-------------------|----------|
| **Fast Q&A** | GPT-3.5-turbo, Mistral | Speed |
| **Complex Reasoning** | GPT-4, Claude-2 | Quality |
| **Code Generation** | CodeLlama, GPT-4 | Specialized |
| **Low Cost** | Ollama models | Cost |
| **Privacy** | Local Ollama | Security |

### Caching Strategies

```yaml
# In conf/service_conf.yaml.template
cache:
  enabled: true
  ttl: 3600  # 1 hour
  max_size: 1000
  strategies:
    - embedding_cache
    - response_cache
    - similarity_cache
```

### Batch Processing

```python
# Process multiple documents efficiently
def batch_embed_documents(documents, batch_size=32):
    embeddings = []
    for i in range(0, len(documents), batch_size):
        batch = documents[i:i+batch_size]
        batch_embeddings = generate_embeddings(batch)
        embeddings.extend(batch_embeddings)
    return embeddings
```

### Request Optimization

```yaml
# Optimize request parameters
optimization:
  connection_pooling: true
  request_timeout: 30
  retry_attempts: 3
  concurrent_requests: 10
```

## Cost Management

### Cost Tracking

```python
# Track token usage and costs
def track_costs(response):
    usage = response.get('usage', {})
    prompt_tokens = usage.get('prompt_tokens', 0)
    completion_tokens = usage.get('completion_tokens', 0)
    
    # OpenAI pricing (example)
    prompt_cost = prompt_tokens * 0.002 / 1000
    completion_cost = completion_tokens * 0.002 / 1000
    total_cost = prompt_cost + completion_cost
    
    return {
        'prompt_tokens': prompt_tokens,
        'completion_tokens': completion_tokens,
        'total_cost': total_cost
    }
```

### Cost Optimization Strategies

1. **Use Appropriate Models**:
   - GPT-3.5-turbo for simple queries
   - GPT-4 only for complex reasoning
   - Local models for development

2. **Optimize Prompt Length**:
   - Use relevant context only
   - Implement smart chunking
   - Cache frequent queries

3. **Implement Rate Limiting**:
   ```yaml
   rate_limits:
     per_user: 100/hour
     per_api_key: 1000/hour
     burst_allowance: 10
   ```

4. **Monitor Usage**:
   ```bash
   # Check usage statistics
   curl http://localhost:9380/api/v1/usage/stats
   ```

### Budget Alerts

```yaml
# Set up budget monitoring
budget:
  monthly_limit: 100.00  # USD
  alerts:
    - threshold: 50%
      action: email
    - threshold: 80%
      action: email_and_slack
    - threshold: 100%
      action: disable_api
```

## Troubleshooting

### Common Issues

1. **API Key Invalid**:
   ```bash
   # Test API key
   curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models
   ```

2. **Model Not Available**:
   ```bash
   # List available models
   curl http://localhost:9380/api/v1/models
   ```

3. **Rate Limit Exceeded**:
   ```python
   # Implement exponential backoff
   import time
   import random
   
   def api_call_with_retry(func, max_retries=3):
       for attempt in range(max_retries):
           try:
               return func()
           except RateLimitError:
               wait_time = (2 ** attempt) + random.uniform(0, 1)
               time.sleep(wait_time)
       raise Exception("Max retries exceeded")
   ```

4. **Ollama Connection Issues**:
   ```bash
   # Check Ollama health
   docker exec ragflow_ollama ollama list
   
   # Test connectivity from RAGFlow
   docker exec ragflow curl http://ollama:11434/api/tags
   ```

### Performance Issues

1. **Slow Responses**:
   - Check model size and complexity
   - Optimize prompt length
   - Use faster models for simple queries

2. **High Memory Usage**:
   - Reduce batch sizes
   - Use smaller models
   - Implement model swapping

3. **Connection Timeouts**:
   - Increase timeout values
   - Implement retry logic
   - Use connection pooling

For more detailed troubleshooting, see the [Troubleshooting Guide](troubleshooting.md).
