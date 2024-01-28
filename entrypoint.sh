envsubst "\${NGINX_PORT}" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "以PUID=${PUID}，PGID=${PGID}的身份启动程序..."

# 更改 nt userid 和 groupid
groupmod -o -g "$PGID" app-user
usermod -o -u "$PUID" app-user

addgroup app-user root

nginx


pm2-runtime ecosystem.config.js