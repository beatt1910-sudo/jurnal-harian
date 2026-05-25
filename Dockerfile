# Gunakan image Nginx ringan
FROM nginx:alpine

# Hapus config bawaan Nginx
RUN rm -rf /usr/share/nginx/html/*

# Salin folder hasil build LOKAL (yang di-push ke GitHub) ke dalam server Nginx
COPY build/web /usr/share/nginx/html

# Railway secara dinamis menyuntikkan port melalui environment variable $PORT.
# Perintah di bawah ini akan mengganti port 80 (default nginx) menjadi $PORT sesaat sebelum server menyala.
CMD sed -i -e 's/listen  *80;/listen '"$PORT"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
