# Node version
FROM node:18-alpine as build

RUN apk update
RUN apk --no-cache --virtual build-dependencies add \
  jpeg-dev \
  cairo-dev \
  giflib-dev \
  pango-dev \
  python3 \
  make \
  g++


# Set the working directory
WORKDIR /app

# Add the source code to app
COPY . /app

# Install all the dependencies
RUN yarn install --frozen-lockfile

# Generate the build of the application
RUN yarn build

# Production image, copy all the files and run next
FROM nginx:1.23.2-alpine AS production
# WORKDIR /app

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Copy the build output to replace the default nginx contents.
# COPY --from=build /app/next.config.js ./
COPY --from=build /app/out /usr/share/nginx/html/
# COPY --from=build --chown=nextjs:nodejs /app/.next ./.next
# COPY --from=build /app/node_modules ./node_modules
# COPY --from=build /app/package.json ./package.json

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx","-g","daemon off;"]