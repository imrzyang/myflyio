FROM alpine:latest

# 安装必要工具：nginx, bash, curl, unzip
RUN apk add --no-cache nginx bash curl unzip

# 下载并安装 Xray
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip && \
    mv xray /usr/local/bin/ && \
    rm -rf xray.zip

# 准备 Nginx 运行目录和伪装网页
RUN mkdir -p /etc/xray /var/www/html /run/nginx
RUN echo '<html><head><title>Success</title></head><body><h1>Server is running</h1><p>System Check: OK</p></body></html>' > /var/www/html/index.html

# 将配置文件放入镜像
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

# 赋予执行权限
RUN chmod +x /entrypoint.sh

# Fly.io 内部监听端口
EXPOSE 8080

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
