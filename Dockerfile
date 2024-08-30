# Build stage
FROM node:alpine AS builder

# Build backend
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install
COPY backend ./
RUN npm run build

# Build frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend ./
RUN npm run build

# Production stage
FROM node:alpine

# Install nginx
RUN apk add --no-cache nginx

# Copy backend build
WORKDIR /app/backend
COPY --from=builder /app/backend/package*.json ./
COPY --from=builder /app/backend/dist ./dist
RUN npm ci --omit=dev --ignore-scripts

# Copy frontend build
WORKDIR /app/frontend
COPY --from=builder /app/frontend/package*.json ./
COPY --from=builder /app/frontend/.next ./.next
COPY --from=builder /app/frontend/public ./public
RUN npm ci --omit=dev --ignore-scripts

# Copy nginx configuration
COPY nginx/default.conf /etc/nginx/http.d/default.conf

# Start script
WORKDIR /app
COPY start-production.sh ./
RUN chmod +x start-production.sh

EXPOSE 80

CMD ["./start-production.sh"]