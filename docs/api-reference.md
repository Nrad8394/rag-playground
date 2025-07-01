# 🔌 API Reference

Complete API documentation for the RAGFlow playground setup.

## Table of Contents

- [API Overview](#api-overview)
- [Authentication](#authentication)
- [Knowledge Bases](#knowledge-bases)
- [Documents](#documents)
- [Chat & RAG](#chat--rag)
- [Embeddings](#embeddings)
- [System](#system)
- [Error Handling](#error-handling)
- [Code Examples](#code-examples)

## API Overview

### Base URL

```
http://localhost:9380/api/v1
```

### Content Types

- **Request**: `application/json`
- **File Upload**: `multipart/form-data`
- **Response**: `application/json`

### Rate Limiting

- **Default**: 60 requests per minute
- **Burst**: 10 additional requests
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`

### API Health Check

```http
GET /health
```

**Response**:
```json
{
  "status": "ok",
  "version": "v0.19.1",
  "timestamp": "2025-07-01T12:00:00Z",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "elasticsearch": "healthy",
    "minio": "healthy"
  }
}
```

## Authentication

### Login

```http
POST /auth/login
```

**Request Body**:
```json
{
  "username": "admin",
  "password": "your_password"
}
```

**Response**:
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": "user-123",
    "username": "admin",
    "role": "admin"
  }
}
```

### Using Authentication

Include the token in the Authorization header:

```http
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

### Refresh Token

```http
POST /auth/refresh
```

**Headers**:
```http
Authorization: Bearer <current_token>
```

**Response**:
```json
{
  "access_token": "new_token_here",
  "expires_in": 3600
}
```

## Knowledge Bases

### List Knowledge Bases

```http
GET /knowledge-bases
```

**Query Parameters**:
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20)
- `search` (string): Search term

**Response**:
```json
{
  "data": [
    {
      "id": "kb-123",
      "name": "My Knowledge Base",
      "description": "Sample KB for testing",
      "created_at": "2025-07-01T10:00:00Z",
      "updated_at": "2025-07-01T12:00:00Z",
      "document_count": 15,
      "chunk_count": 342,
      "settings": {
        "chunk_size": 512,
        "chunk_overlap": 50,
        "embedding_model": "text-embedding-ada-002"
      }
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 20
}
```

### Create Knowledge Base

```http
POST /knowledge-bases
```

**Request Body**:
```json
{
  "name": "My New KB",
  "description": "Description of the knowledge base",
  "settings": {
    "chunk_size": 512,
    "chunk_overlap": 50,
    "embedding_model": "text-embedding-ada-002",
    "language": "en",
    "parser": "auto"
  }
}
```

**Response**:
```json
{
  "id": "kb-456",
  "name": "My New KB",
  "description": "Description of the knowledge base",
  "created_at": "2025-07-01T12:30:00Z",
  "settings": {
    "chunk_size": 512,
    "chunk_overlap": 50,
    "embedding_model": "text-embedding-ada-002",
    "language": "en",
    "parser": "auto"
  }
}
```

### Get Knowledge Base

```http
GET /knowledge-bases/{kb_id}
```

**Response**:
```json
{
  "id": "kb-123",
  "name": "My Knowledge Base",
  "description": "Sample KB for testing",
  "created_at": "2025-07-01T10:00:00Z",
  "updated_at": "2025-07-01T12:00:00Z",
  "document_count": 15,
  "chunk_count": 342,
  "settings": {
    "chunk_size": 512,
    "chunk_overlap": 50,
    "embedding_model": "text-embedding-ada-002"
  },
  "statistics": {
    "total_tokens": 156789,
    "average_chunk_size": 458,
    "languages": ["en", "es"],
    "file_types": [".pdf", ".docx", ".txt"]
  }
}
```

### Update Knowledge Base

```http
PATCH /knowledge-bases/{kb_id}
```

**Request Body**:
```json
{
  "name": "Updated KB Name",
  "description": "Updated description",
  "settings": {
    "chunk_size": 1024
  }
}
```

### Delete Knowledge Base

```http
DELETE /knowledge-bases/{kb_id}
```

**Response**:
```json
{
  "message": "Knowledge base deleted successfully",
  "deleted_documents": 15,
  "deleted_chunks": 342
}
```

## Documents

### List Documents

```http
GET /knowledge-bases/{kb_id}/documents
```

**Query Parameters**:
- `page` (int): Page number
- `limit` (int): Items per page
- `status` (string): Filter by status (`processing`, `completed`, `failed`)
- `file_type` (string): Filter by file type

**Response**:
```json
{
  "data": [
    {
      "id": "doc-789",
      "name": "sample.pdf",
      "size": 1048576,
      "type": "application/pdf",
      "status": "completed",
      "uploaded_at": "2025-07-01T11:00:00Z",
      "processed_at": "2025-07-01T11:05:00Z",
      "chunk_count": 23,
      "metadata": {
        "title": "Sample Document",
        "author": "John Doe",
        "pages": 10
      }
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 20
}
```

### Upload Document

```http
POST /knowledge-bases/{kb_id}/documents
```

**Content-Type**: `multipart/form-data`

**Form Data**:
- `file`: Document file
- `metadata` (optional): JSON string with document metadata

**Response**:
```json
{
  "id": "doc-890",
  "name": "uploaded_file.pdf",
  "size": 2097152,
  "type": "application/pdf",
  "status": "processing",
  "uploaded_at": "2025-07-01T13:00:00Z",
  "processing_job_id": "job-456"
}
```

### Get Document

```http
GET /documents/{doc_id}
```

**Response**:
```json
{
  "id": "doc-789",
  "name": "sample.pdf",
  "size": 1048576,
  "type": "application/pdf",
  "status": "completed",
  "uploaded_at": "2025-07-01T11:00:00Z",
  "processed_at": "2025-07-01T11:05:00Z",
  "chunk_count": 23,
  "knowledge_base_id": "kb-123",
  "metadata": {
    "title": "Sample Document",
    "author": "John Doe",
    "pages": 10,
    "language": "en"
  },
  "processing_info": {
    "duration": 300,
    "tokens_processed": 5420,
    "chunks_created": 23,
    "embeddings_generated": 23
  }
}
```

### Delete Document

```http
DELETE /documents/{doc_id}
```

**Response**:
```json
{
  "message": "Document deleted successfully",
  "deleted_chunks": 23
}
```

### Get Document Chunks

```http
GET /documents/{doc_id}/chunks
```

**Query Parameters**:
- `page` (int): Page number
- `limit` (int): Items per page

**Response**:
```json
{
  "data": [
    {
      "id": "chunk-001",
      "content": "This is the text content of the chunk...",
      "position": 0,
      "tokens": 128,
      "metadata": {
        "page": 1,
        "section": "Introduction"
      }
    }
  ],
  "total": 23,
  "page": 1,
  "limit": 10
}
```

## Chat & RAG

### Chat Completions

```http
POST /chat/completions
```

**Request Body**:
```json
{
  "messages": [
    {
      "role": "user",
      "content": "What are the main benefits of renewable energy?"
    }
  ],
  "knowledge_base_id": "kb-123",
  "model": "gpt-3.5-turbo",
  "max_tokens": 1024,
  "temperature": 0.1,
  "search_settings": {
    "top_k": 5,
    "similarity_threshold": 0.7,
    "hybrid_search": true
  }
}
```

**Response**:
```json
{
  "id": "chat-comp-123",
  "object": "chat.completion",
  "created": 1625097600,
  "model": "gpt-3.5-turbo",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Based on the documents, renewable energy offers several key benefits:\n\n1. Environmental Impact: Renewable energy sources produce minimal greenhouse gas emissions...",
        "sources": [
          {
            "document_id": "doc-789",
            "document_name": "renewable_energy_guide.pdf",
            "chunk_id": "chunk-001",
            "similarity_score": 0.95,
            "content": "Renewable energy sources such as solar, wind, and hydroelectric power..."
          }
        ]
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 256,
    "completion_tokens": 180,
    "total_tokens": 436,
    "cost": 0.00087
  }
}
```

### Streaming Chat

```http
POST /chat/completions
```

**Request Body**:
```json
{
  "messages": [
    {
      "role": "user", 
      "content": "Explain photosynthesis"
    }
  ],
  "knowledge_base_id": "kb-123",
  "stream": true
}
```

**Response** (Server-Sent Events):
```
data: {"id":"chat-123","choices":[{"delta":{"content":"Photosynthesis"}}]}

data: {"id":"chat-123","choices":[{"delta":{"content":" is the"}}]}

data: {"id":"chat-123","choices":[{"delta":{"content":" process"}}]}

data: [DONE]
```

### Search Knowledge Base

```http
POST /knowledge-bases/{kb_id}/search
```

**Request Body**:
```json
{
  "query": "renewable energy benefits",
  "top_k": 10,
  "similarity_threshold": 0.7,
  "filters": {
    "document_type": "pdf",
    "language": "en"
  }
}
```

**Response**:
```json
{
  "results": [
    {
      "chunk_id": "chunk-001",
      "document_id": "doc-789",
      "document_name": "renewable_energy_guide.pdf",
      "content": "Renewable energy sources offer numerous environmental and economic benefits...",
      "similarity_score": 0.95,
      "metadata": {
        "page": 3,
        "section": "Benefits"
      }
    }
  ],
  "total": 8,
  "query_embedding_time": 0.12,
  "search_time": 0.45
}
```

## Embeddings

### Generate Embeddings

```http
POST /embeddings
```

**Request Body**:
```json
{
  "input": [
    "Hello world",
    "How are you?"
  ],
  "model": "text-embedding-ada-002"
}
```

**Response**:
```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "index": 0,
      "embedding": [0.0023, -0.009, 0.015, ...]
    },
    {
      "object": "embedding", 
      "index": 1,
      "embedding": [0.008, -0.002, 0.019, ...]
    }
  ],
  "model": "text-embedding-ada-002",
  "usage": {
    "prompt_tokens": 6,
    "total_tokens": 6
  }
}
```

### Supported Embedding Models

```http
GET /models/embeddings
```

**Response**:
```json
{
  "data": [
    {
      "id": "text-embedding-ada-002",
      "object": "model",
      "owned_by": "openai",
      "dimensions": 1536,
      "max_input": 8191
    },
    {
      "id": "all-MiniLM-L6-v2",
      "object": "model", 
      "owned_by": "sentence-transformers",
      "dimensions": 384,
      "max_input": 256
    }
  ]
}
```

## System

### System Information

```http
GET /system/info
```

**Response**:
```json
{
  "version": "v0.19.1",
  "build": "2025.07.01-abc123",
  "services": {
    "database": {
      "type": "mysql",
      "version": "8.0",
      "status": "healthy"
    },
    "vector_db": {
      "type": "elasticsearch",
      "version": "8.11.0",
      "status": "healthy"
    },
    "cache": {
      "type": "redis",
      "version": "7.2",
      "status": "healthy"
    },
    "storage": {
      "type": "minio",
      "status": "healthy"
    }
  },
  "usage": {
    "total_knowledge_bases": 5,
    "total_documents": 150,
    "total_chunks": 5420,
    "total_tokens_processed": 2500000
  }
}
```

### System Metrics

```http
GET /system/metrics
```

**Response**:
```json
{
  "timestamp": "2025-07-01T13:00:00Z",
  "uptime": 86400,
  "memory": {
    "used": "4.2GB",
    "total": "16GB",
    "usage_percent": 26.25
  },
  "cpu": {
    "usage_percent": 45.2,
    "cores": 8
  },
  "storage": {
    "documents": "12.5GB",
    "vectors": "2.1GB",
    "total_used": "14.6GB",
    "total_available": "50GB"
  },
  "requests": {
    "total": 15420,
    "last_hour": 342,
    "average_response_time": 1.25
  }
}
```

### Configuration

```http
GET /system/config
```

**Response**:
```json
{
  "default_models": {
    "chat": "gpt-3.5-turbo",
    "embedding": "text-embedding-ada-002"
  },
  "limits": {
    "max_file_size": "100MB",
    "max_chunk_size": 2048,
    "max_tokens_per_request": 4096,
    "rate_limit": 60
  },
  "features": {
    "streaming": true,
    "hybrid_search": true,
    "multi_modal": false
  }
}
```

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "The request is invalid",
    "details": "Knowledge base ID is required",
    "timestamp": "2025-07-01T13:00:00Z",
    "request_id": "req-123456"
  }
}
```

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 413 | Payload Too Large | File too large |
| 422 | Unprocessable Entity | Validation errors |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily down |

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_REQUEST` | Request parameters are invalid |
| `MISSING_REQUIRED_FIELD` | Required field is missing |
| `RESOURCE_NOT_FOUND` | Requested resource doesn't exist |
| `DUPLICATE_RESOURCE` | Resource already exists |
| `AUTHENTICATION_FAILED` | Invalid credentials |
| `AUTHORIZATION_FAILED` | Insufficient permissions |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `FILE_TOO_LARGE` | Uploaded file exceeds size limit |
| `UNSUPPORTED_FILE_TYPE` | File type not supported |
| `PROCESSING_FAILED` | Document processing failed |
| `EXTERNAL_API_ERROR` | External service error |
| `QUOTA_EXCEEDED` | Usage quota exceeded |

## Code Examples

### Python Client

```python
import requests
import json

class RAGFlowClient:
    def __init__(self, base_url="http://localhost:9380/api/v1"):
        self.base_url = base_url
        self.token = None
    
    def login(self, username, password):
        response = requests.post(
            f"{self.base_url}/auth/login",
            json={"username": username, "password": password}
        )
        data = response.json()
        self.token = data["access_token"]
        return data
    
    def _headers(self):
        return {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }
    
    def create_knowledge_base(self, name, description="", settings=None):
        data = {
            "name": name,
            "description": description,
            "settings": settings or {}
        }
        response = requests.post(
            f"{self.base_url}/knowledge-bases",
            headers=self._headers(),
            json=data
        )
        return response.json()
    
    def upload_document(self, kb_id, file_path):
        with open(file_path, 'rb') as f:
            files = {"file": f}
            response = requests.post(
                f"{self.base_url}/knowledge-bases/{kb_id}/documents",
                headers={"Authorization": f"Bearer {self.token}"},
                files=files
            )
        return response.json()
    
    def chat(self, kb_id, message, model="gpt-3.5-turbo"):
        data = {
            "messages": [{"role": "user", "content": message}],
            "knowledge_base_id": kb_id,
            "model": model
        }
        response = requests.post(
            f"{self.base_url}/chat/completions",
            headers=self._headers(),
            json=data
        )
        return response.json()

# Usage example
client = RAGFlowClient()
client.login("admin", "password")

# Create knowledge base
kb = client.create_knowledge_base("My KB", "Test knowledge base")
kb_id = kb["id"]

# Upload document
doc = client.upload_document(kb_id, "document.pdf")

# Chat
response = client.chat(kb_id, "What is this document about?")
print(response["choices"][0]["message"]["content"])
```

### JavaScript Client

```javascript
class RAGFlowClient {
    constructor(baseUrl = 'http://localhost:9380/api/v1') {
        this.baseUrl = baseUrl;
        this.token = null;
    }
    
    async login(username, password) {
        const response = await fetch(`${this.baseUrl}/auth/login`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({username, password})
        });
        const data = await response.json();
        this.token = data.access_token;
        return data;
    }
    
    get headers() {
        return {
            'Authorization': `Bearer ${this.token}`,
            'Content-Type': 'application/json'
        };
    }
    
    async createKnowledgeBase(name, description = '', settings = {}) {
        const response = await fetch(`${this.baseUrl}/knowledge-bases`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify({name, description, settings})
        });
        return await response.json();
    }
    
    async uploadDocument(kbId, file) {
        const formData = new FormData();
        formData.append('file', file);
        
        const response = await fetch(`${this.baseUrl}/knowledge-bases/${kbId}/documents`, {
            method: 'POST',
            headers: {'Authorization': `Bearer ${this.token}`},
            body: formData
        });
        return await response.json();
    }
    
    async chat(kbId, message, model = 'gpt-3.5-turbo') {
        const response = await fetch(`${this.baseUrl}/chat/completions`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify({
                messages: [{role: 'user', content: message}],
                knowledge_base_id: kbId,
                model
            })
        });
        return await response.json();
    }
}

// Usage example
const client = new RAGFlowClient();
await client.login('admin', 'password');

const kb = await client.createKnowledgeBase('My KB');
const response = await client.chat(kb.id, 'Hello!');
console.log(response.choices[0].message.content);
```

### cURL Examples

```bash
# Login
curl -X POST http://localhost:9380/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'

# Create knowledge base
curl -X POST http://localhost:9380/api/v1/knowledge-bases \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "My KB", "description": "Test KB"}'

# Upload document
curl -X POST http://localhost:9380/api/v1/knowledge-bases/kb-123/documents \
  -H "Authorization: Bearer <token>" \
  -F "file=@document.pdf"

# Chat
curl -X POST http://localhost:9380/api/v1/chat/completions \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "What is AI?"}],
    "knowledge_base_id": "kb-123",
    "model": "gpt-3.5-turbo"
  }'
```

For more examples and detailed usage, see the [Getting Started Guide](getting-started.md).
