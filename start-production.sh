#!/bin/sh
# Start the backend
cd /app/backend && npm run start:prod &

# Start the frontend
cd /app/frontend && npm run start &

# Start nginx
nginx -g 'daemon off;'