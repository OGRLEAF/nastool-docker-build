envsubst "\${NGINX_PORT}" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "以PUID=${PUID}，PGID=${PGID}的身份启动程序..."

# 更改 nt userid 和 groupid
echo "Configure app-user pid=$PGID uid=$PUID"
groupmod -o -g "$PGID" app-user
usermod -o -u "$PUID" app-user

adduser app-user root

echo "Migrating webdriver"
cp $(which chromedriver) $WEBDRIVER
chown app-user:app-user $WEBDRIVER
# chown app-user:app-user -R /nastool-lite/server
# chown app-user:app-user -R $NATOOL_CONFIG_PATH
echo "Ensure root permission"
# chown app-user:app-user -R /root

echo "Start nginx..."
nginx

echo "Start pm2-runtime..."
pm2-runtime ecosystem.config.js