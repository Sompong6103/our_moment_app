# ── Stage 1: Build ──
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY prisma ./prisma/
RUN npx prisma generate

COPY src ./src/
RUN npm run build

# ── Stage 2: Production ──
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/dist ./dist
COPY prisma ./prisma/

RUN mkdir -p uploads

EXPOSE 3000

CMD ["node", "dist/index.js"]

# docker build -t our-moment-backend .
# docker tag our-moment-backend:latest harbor.sm-developer.dev/muict/our-moment-backend:latest
# docker push harbor.sm-developer.dev/muict/our-moment-backend:latest
