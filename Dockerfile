FROM node:22-alpine AS build

WORKDIR /app

# Copiar archivos de configuración de pnpm
# Copiar archivos de configuración
#COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY . .

RUN corepack enable

# Instalar dependencias
RUN pnpm install --frozen-lockfile


RUN pnpm run db:generate

# Compilar TypeScript
RUN pnpm build

# ETAPA DE PRODUCCÓN
FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

RUN corepack enable
# Copiar archivos de configuración
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
# Instalar solo dependencias de producción
RUN pnpm install --prod --frozen-lockfile

COPY . .
# Copiar código compilado
COPY --from=build /app/dist ./dist

# Crear directorio para la base de datos
RUN mkdir -p /app/data

CMD [ "pnpm", "run", "start" ]