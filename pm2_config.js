module.exports = {
    apps: [
        {
            name: "nastool-lite-web",
            script: "HOSTNAME=127.0.0.1 PORT=$WEB_PORT node /nastool-lite/web/server.js",
            cwd: "/nastool-lite/web",
            env_production: {
                NODE_ENV: "production"
            },
            env_development: {
                NODE_ENV: "development"
            }
        }, 
        {
            name: "redis",
            script: "redis-server",
        }, 
        {
            name: "nastool-lite-api",
            script: "sudo -u app-user -E $PYTHON run.py",
            cwd: "/nastool-lite/server",
            env_production: {
            },
            env_development: {
            }
        }
    ]
}   