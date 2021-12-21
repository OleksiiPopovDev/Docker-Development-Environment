# Docker Development Environment

<p align="center">
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/downloads/PopovAleksey/Docker-Development-Environment/total" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/license/PopovAleksey/Docker-Development-Environment" alt="License"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/languages/code-size/PopovAleksey/Docker-Development-Environment" alt="Code Size"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/github/v/release/PopovAleksey/Docker-Development-Environment" alt="Code Size"></a>
</p>

- Copy content bellow into <b>/Library/LaunchDaemons/com.docker_1270048_alias.plist</b>

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

- `sudo launchctl load /Library/LaunchDaemons/com.docker_127007_alias.plist`
