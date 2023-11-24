# Use a base image with build tools
FROM debian:buster

# Install dependencies required for compiling Nginx and the module
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    wget

# Set the Nginx version to compile
ARG NGINX_VERSION=1.21.0

# Download and decompress Nginx
RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar -xzvf nginx-$NGINX_VERSION.tar.gz && \
    rm nginx-$NGINX_VERSION.tar.gz

# Copy in the ngx_http_redis module
COPY ./ngx_http_redis-0.3.9 /ngx_http_redis-0.3.9/

# Compile Nginx with ngx_http_redis module
RUN cd nginx-$NGINX_VERSION && \
    ./configure --with-compat --add-dynamic-module=/ngx_http_redis-0.3.9 && \
    make && \
    make install

# Copy the Nginx configuration file
COPY nginx.conf /usr/local/nginx/conf/nginx.conf

# Load the ngx_http_redis module in the Nginx configuration
RUN echo 'load_module modules/ngx_http_redis_module.so;' > /usr/local/nginx/conf/modules.conf

# Set the working directory to Nginx
WORKDIR /usr/local/nginx

# Expose the port Nginx is running on
EXPOSE 80

# Start Nginx
CMD ["sbin/nginx", "-g", "daemon off;"]
