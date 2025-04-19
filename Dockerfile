ARG APP_NAME

################################################################################################
FROM node:20-slim AS base
################################################################################################

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG NODE_ENV

ENV HOME=/app
ENV BUILD_PATH=/app/build
ENV NODE_ENV=$NODE_ENV
ENV PATH=$HOME/node_modules/.bin:$PATH

WORKDIR $HOME

# Install make
RUN apt-get update && apt-get install -y make jq

################################################################################################
FROM base AS source
################################################################################################

ARG APP_NAME

COPY . $HOME

RUN <<EOF
if [ -d "node_modules" ]; then
  echo "node_modules exists. This should NOT happen."
  exit 1
fi
EOF

RUN <<EOF
npx --yes turbo prune "${APP_NAME}" --docker
EOF

################################################################################################
FROM base AS dependencies
################################################################################################

COPY --from=source $HOME/out/json $HOME

RUN npm ci --no-fund

# TODO: don't depend on dependencies in the build stage
################################################################################################
FROM dependencies AS build
################################################################################################

ARG APP_NAME

COPY --from=source $HOME/out/full $HOME

RUN <<EOF
# Install full dependencies so we can build the application
npm ci --include=dev --no-fund

# First run the build filtering for the app
npm run build --filter=$APP_NAME
APP_PATH=$(npm exec -c 'pwd' -w $APP_NAME)

# The copy the build to a known location so we can copy it in the production image
mkdir -p $BUILD_PATH
mv $APP_PATH/build $APP_PATH/package.json $BUILD_PATH
EOF

################################################################################################
FROM base AS development
################################################################################################

COPY --from=dependencies $HOME $HOME
COPY --from=source $HOME $HOME

CMD ["npm", "run", "dev"]

################################################################################################
FROM base AS production
################################################################################################

WORKDIR $BUILD_PATH

# TODO: don't depend on dependencies in the production stage
COPY --from=dependencies $HOME $BUILD_PATH
COPY --from=build $BUILD_PATH $BUILD_PATH

CMD ["npm", "run", "start"]
