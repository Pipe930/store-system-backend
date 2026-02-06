FROM node:22-alpine AS build

WORKDIR /app

# Copiar archivos de configuración de pnpm
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

RUN corepack enable

# Instalar dependencias
RUN pnpm install --frozen-lockfile

# Copiar código fuente y configuración de Prisma
COPY src ./src
COPY prisma ./prisma
COPY tsconfig.json prisma.config.ts nodemon.json ./

# Generar cliente de Prisma
RUN pnpm exec prisma generate

# Compilar TypeScript
RUN pnpm build

# Etapa de producción
FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080

RUN corepack enable

# Copiar archivos de configuración
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY prisma.config.ts ./

# Instalar solo dependencias de producción
RUN pnpm install --prod --frozen-lockfile

# Copiar Prisma schema y generar cliente
COPY prisma ./prisma
RUN pnpm exec prisma generate

# Copiar código compilado
COPY --from=build /app/dist ./dist

# Crear directorio para la base de datos
RUN mkdir -p /app/data

CMD [ "pnpm", "run", "start" ]