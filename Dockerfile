# Stage 1: Build the Flutter web app
FROM debian:latest AS build-env

# Install dependencies for Flutter
RUN apt-get update && \
    apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 psmisc && \
    apt-get clean

# Clone Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Set working directory
WORKDIR /app

# Copy the source code
COPY . .

# Build the web app
RUN flutter pub get
RUN flutter build web

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Remove default nginx config
RUN rm -rf /usr/share/nginx/html/*

# Copy the build output from Stage 1
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Railway dynamically injects the port through $PORT
CMD sed -i -e 's/listen  *80;/listen '"$PORT"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
