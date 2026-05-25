# Stage 1: Build Flutter Web
FROM ubuntu:22.04 AS build-env

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        wget \
        unzip \
        xz-utils \
        python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter (stable, shallow clone for speed)
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch stable /flutter

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-cache Flutter web artifacts
RUN flutter config --enable-web
RUN flutter precache --web

WORKDIR /app

# Copy source code
COPY . .

# Get dependencies and build
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build-env /app/build/web /usr/share/nginx/html

# Railway injects PORT environment variable
CMD sed -i -e 's/listen  *80;/listen '$PORT';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
