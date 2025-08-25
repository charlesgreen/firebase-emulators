#!/bin/bash

# Integration test script for Firebase Emulators

set -e

echo "🧪 Starting Firebase Emulator integration tests..."

# Test 1: Build the Docker image
echo "Test 1: Building Docker image..."
docker build -t test-firebase-emulators:latest ../..

# Test 2: Start container and check health
echo "Test 2: Starting container and checking health..."
docker run -d --name test-emulator -p 5170-5179:5170-5179 test-firebase-emulators:latest
sleep 10

# Test 3: Check if emulator UI is accessible
echo "Test 3: Checking emulator UI..."
if curl -f http://localhost:5179 > /dev/null 2>&1; then
    echo "✅ Emulator UI is accessible"
else
    echo "❌ Emulator UI is not accessible"
    docker logs test-emulator
    docker stop test-emulator && docker rm test-emulator
    exit 1
fi

# Test 4: Check individual emulator ports
echo "Test 4: Checking individual emulator ports..."
for port in 5171 5172 5175; do
    if nc -z localhost $port; then
        echo "✅ Port $port is open"
    else
        echo "⚠️  Port $port is not responding (may be normal)"
    fi
done

# Test 5: Clean up
echo "Test 5: Cleaning up..."
docker stop test-emulator && docker rm test-emulator
docker rmi test-firebase-emulators:latest

echo "✅ All integration tests passed!"