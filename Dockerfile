FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build --if-present

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Update Alpine packages + upgrade npm to latest to fix bundled vulnerabilities
RUN apk update && \
    apk upgrade && \
    rm -rf /var/cache/apk/* && \
    npm install -g npm@latest && \
    npm cache clean --force

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package*.json ./

EXPOSE 3001
CMD ["node", "src/index.js"]
