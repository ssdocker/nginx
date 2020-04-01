FROM nginx
ADD ./dist /etc/nginx
ENTRYPOINT ["bash", "-c", "/etc/nginx/start.sh && nginx -g 'daemon off;'"]
