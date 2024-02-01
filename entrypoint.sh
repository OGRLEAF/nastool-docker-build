envsubst "\${NGINX_PORT}" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "以PUID=${PUID}，PGID=${PGID}的身份启动程序..."

# 更改 nt userid 和 groupid
groupmod -o -g "$PGID" app-user
usermod -o -u "$PUID" app-user

addgroup app-user root

chown app-user:app-user -R /nastool-lite/server
chown app-user:app-user -R $NATOOL_CONFIG_PATH

echo "Start nginx..."
nginx

echo "Start pm2-runtime..."
pm2-runtime ecosystem.config.js