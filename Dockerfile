# Multi-stage Dockerfile for Firebase Emulators
# Optimized for production with security best practices

# Build stage
FROM node:18-alpine AS builder

# Install Firebase CLI and dependencies
RUN npm install -g firebase-tools@latest && \
    npm cache clean --force

# Runtime stage
FROM node:18-alpine AS runtime

# Create non-root user for security
RUN addgroup -g 1001 -S firebase && \
    adduser -S firebase -u 1001 -G firebase

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init curl jq

# Copy Firebase CLI from builder stage
COPY --from=builder /usr/local/lib/node_modules/firebase-tools /usr/local/lib/node_modules/firebase-tools
COPY --from=builder /usr/local/bin/firebase /usr/local/bin/firebase

# Set working directory
WORKDIR /app

# Copy configuration and scripts
COPY --chown=firebase:firebase config/ ./config/
COPY --chown=firebase:firebase scripts/ ./scripts/
COPY --chown=firebase:firebase seed/ ./seed/

# Make scripts executable
RUN chmod +x ./scripts/*.sh

# Create directories for emulator data with proper permissions
RUN mkdir -p /app/data /app/logs && \
    chown -R firebase:firebase /app

# Switch to non-root user
USER firebase

# Expose Firebase emulator ports
# 5171: Auth, 5172: Firestore, 5174: Hosting, 5175: Storage, 5179: UI
EXPOSE 5171 5172 5174 5175 5179

# Environment variables
ENV FIREBASE_PROJECT_ID=demo-project
ENV FIREBASE_AUTH_PORT=5171
ENV FIREBASE_FIRESTORE_PORT=5172
ENV FIREBASE_HOSTING_PORT=5174
ENV FIREBASE_STORAGE_PORT=5175
ENV FIREBASE_UI_PORT=5179
ENV FIREBASE_EMULATOR_HUB_PORT=5170

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${FIREBASE_UI_PORT} || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Default command
CMD ["./scripts/start-emulators.sh"]