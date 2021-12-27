# Docker Development Environment 

<p align="center">
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/downloads/PopovAleksey/Docker-Development-Environment/total" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/license/PopovAleksey/Docker-Development-Environment" alt="License"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/languages/code-size/PopovAleksey/Docker-Development-Environment" alt="Code Size"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/v/release/PopovAleksey/Docker-Development-Environment" alt="Code Size"></a>
</p>

## How use it

1. Add to your repository directory **docker** with two files:
   1. database.db
    ```sql
    CREATE USER '{USER_NAME}'@'%' IDENTIFIED BY '{PASSWORD}';
    
    CREATE DATABASE IF NOT EXISTS {DATABASE_NAME};
    
    GRANT ALL PRIVILEGES ON {DATABASE_NAME}.* TO '{USER_NAME}'@'%';
    
    FLUSH PRIVILEGES;
    ```
   2. nginx.conf

    ```apacheconf
    server {
        listen       80;
        server_name  {LOCAL_DOMAIN};
    
        charset utf-8;
        access_log  /var/log/nginx/{PROJECT_NAME}.access.log  main;
        error_log /var/log/nginx/{PROJECT_NAME}.error.log;
    
        root   /var/www/{PROJECT_FOLDER}/public;
        index  index.php index.html index.htm;
    
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
    
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass   php:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
    
        location ~ /\.ht {
            deny  all;
        }
    }
    ```

2. <span style="color:orange">If you are use MacOS!</span>

   1. Copy content bellow into **/Library/LaunchDaemons/com.docker_1270048_alias.plist**

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.docker_1270048_alias</string>
        <key>ProgramArguments</key>
        <array>
            <string>ifconfig</string>
            <string>lo0</string>
            <string>alias</string>
            <string>127.0.0.48</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
    ```
   2. Run command: `sudo launchctl load /Library/LaunchDaemons/com.docker_1270048_alias.plist`


3. Add to **/etc/hosts** local domain of your project
`127.0.0.48 {LOCAL_DOMAIN}`
4. Add your repository to **.repositories** file.
5. Run installation command `sh worker.sh install`.
6. Follow step-by-step installation

---

## Commands of worker.sh
| Command                  | Description                                                                    |
|--------------------------|--------------------------------------------------------------------------------|
| `sh worker.sh install`   | Installation new project to Container                                          |
| `sh worker.sh uninstall` | Reinstall project from Container                                               |
| `sh worker.sh bash`      | Enter to Bash of Container                                                     |
| `sh worker.sh start`     | Start Docker Containers                                                        |
| `sh worker.sh stop`      | Stop Docker Containers                                                         |
| `sh worker.sh up`        | Build and up Containers                                                        |
| `sh worker.sh down`      | Remove Containers                                                              |
| `sh worker.sh rebuild`   | Remove, build and up Containers with refreshing database, migrations and seeds |



```dockerfile
  
ARG DOCKER_USERNAME
ARG DOCKER_PASSWORD
ARG DOCKER_UID
ARG SENTRY_SECRET_KEY
ARG SENTRY_POSTGRES_HOST
ARG SENTRY_POSTGRES_PORT
ARG SENTRY_DB_NAME
ARG SENTRY_DB_USER
ARG SENTRY_DB_PASSWORD
ARG SENTRY_REDIS_HOST
ARG SENTRY_REDIS_PORT
```