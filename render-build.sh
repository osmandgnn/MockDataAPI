#!/bin/bash
# Render.com build script for MockServer
# This script prepares the MockServer configuration for deployment

echo "🚀 Starting Render.com MockServer build..."

# Create config directory if not exists
mkdir -p /opt/render/project/src/config

# Copy initialization config
cp config/mockserver-initialization.json /opt/render/project/src/config/

echo "✅ MockServer configuration prepared"
echo "📁 Config location: /opt/render/project/src/config/mockserver-initialization.json"
