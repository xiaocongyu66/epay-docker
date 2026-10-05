# Epay Docker 部署

这是 `maajiko/Epay` 的独立 Docker 打包版本。项目本身是传统 PHP 支付系统，Docker 配置只负责隔离运行环境和数据库，不改变支付业务代码。

## 安全要求

首次启动前必须修改 `docker/data/config.php` 和 `docker-compose.yml` 中的数据库密码。Epay 安装 SQL 默认创建管理员 `admin / 123456`，首次安装后必须立即修改管理员密码和支付密码，并启用 TOTP。

不要把 `9080` 直接暴露到公网。示例只绑定到服务器本机 `127.0.0.1:9080`，应由已有反向代理提供 HTTPS、域名和访问日志。

上传目录由 Apache 规则禁止执行 PHP；`includes` 和 `plugins` 目录禁止直接访问。数据库没有暴露宿主机端口，并且位于内部 Docker 网络。

## 启动

```bash
cp docker/data/config.php docker/data/config.local.php
# 编辑 docker/data/config.php，设置数据库密码
# 同步修改 docker-compose.yml 中 MYSQL_PASSWORD 和 MYSQL_ROOT_PASSWORD

docker compose build --no-cache
docker compose up -d
```

首次访问：

```text
http://127.0.0.1:9080/install/
```

安装完成后在容器内创建安装锁文件：

```bash
docker compose exec epay sh -c "printf '安装锁' > /var/www/html/install/install.lock"
```

然后立即：

1. 修改管理员密码和支付密码。
2. 启用管理员 TOTP。
3. 删除或阻断公网访问 `/install/`。
4. 配置真实支付回调域名和 HTTPS。
5. 备份 `docker/data/config.php`、数据库和上传 volume。

## 回滚

```bash
docker compose down
# 保留 docker/data/config.php 和数据库 volume，不执行 volume 删除
```

此配置尚未自动接入任何现有 `new-api` 网络或数据库。
