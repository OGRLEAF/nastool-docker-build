module.exports = {
    apps: [
        {
            name: "nastool-lite-web",
            script: "PORT=$WEB_PORT node .next/standalone/server.js",
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
            script: "sudo -u app-user -E python run.py",
            cwd: "/nastool-lite/server",
            env_production: {
            },
            env_development: {
            }
        }
    ]
}