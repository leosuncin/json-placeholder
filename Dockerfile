ARG NODE_VERSION=22-slim

FROM node:${NODE_VERSION} AS dependencies

ENV PNPM_HOME="/var/cache/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

WORKDIR /app

RUN --mount=type=cache,id=pnpm-store,target=/var/cache/pnpm/store\
    --mount=type=bind,source=package.json,target=/app/package.json\
    --mount=type=bind,source=pnpm-lock.yaml,target=/app/pnpm-lock.yaml\
    corepack enable &&\
    pnpm install --frozen-lockfile

COPY --chown=node:node . /app/

RUN pnpm compile && cp db.json dist

FROM gcr.io/distroless/nodejs22-debian12:nonroot

WORKDIR /home/nonroot/app

COPY --from=dependencies --chown=nonroot:nonroot /app/dist /home/nonroot/app

EXPOSE 3000

CMD ["index.js", "db.json"]
