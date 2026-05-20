# Stage 1: Build aplikasi Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

# Unduh dependencies dan build versi web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Sajikan web menggunakan Nginx
FROM nginx:alpine

# Salin hasil build flutter ke folder publik nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Railway secara dinamis menyuntikkan port melalui environment variable $PORT.
# Perintah di bawah ini akan mengganti port 80 (default nginx) menjadi $PORT sesaat sebelum server menyala.
CMD sed -i -e 's/listen  *80;/listen '"$PORT"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
