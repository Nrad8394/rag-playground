#!/bin/bash

# RAGFlow Setup Script
echo "Setting up RAGFlow environment..."

# Check if running on Windows (Git Bash/WSL)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Windows environment detected"
    # For Windows, we'll use Docker's internal networking instead of hosts file
    echo "Using Docker networking - no hosts file modification needed"
else
    # Linux/macOS
    echo "Adding RAGFlow hosts to /etc/hosts..."
    
    # Check if entries already exist
    if ! grep -q "es01 infinity mysql minio redis" /etc/hosts; then
        echo "127.0.0.1 es01 infinity mysql minio redis" | sudo tee -a /etc/hosts
        echo "Hosts entries added successfully"
    else
        echo "Hosts entries already exist"
    fi
fi

# Create necessary directories
mkdir -p ./conf
mkdir -p ./data

echo "Setup complete! You can now run: docker-compose up -d"
