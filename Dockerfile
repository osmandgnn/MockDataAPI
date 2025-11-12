# MockServer Dockerfile for Cloud Deployment
# Optimized for Render.com, Railway.app, and Fly.io

FROM mockserver/mockserver:5.15.0

# Set environment variables
ENV MOCKSERVER_LOG_LEVEL=INFO \
    MOCKSERVER_ENABLE_CORS_FOR_API=true \
    MOCKSERVER_ENABLE_CORS_FOR_ALL_RESPONSES=true

# Copy configuration files
COPY config/mockserver-initialization.json /config/mockserver-initialization.json
COPY js-templates/ /js-templates/

# Set initialization path
ENV MOCKSERVER_INITIALIZATION_JSON_PATH=/config/mockserver-initialization.json

# Expose port
EXPOSE 1080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:1080/mockserver/status || exit 1

# Entry point is inherited from base image
# CMD is inherited from base image
