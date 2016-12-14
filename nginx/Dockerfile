FROM alpine

RUN apk update && \
  apk add nginx && \
  echo "daemon off;" >> /etc/nginx/nginx.conf && \
  echo "pid /tmp/nginx.pid;" >> /etc/nginx/nginx.conf

CMD nginx
