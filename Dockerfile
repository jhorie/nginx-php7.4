FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="admin@mynober.nl"
LABEL version="0.1"
LABEL description="This is custom Docker Image for the PHP-FPM and Nginx Services."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update

RUN apt install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt update

RUN apt install -y nginx php7.4-fpm php7.4-soap php7.4-curl php7.4-cli php7.4 php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-zip php-imagick supervisor unzip git && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

# Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.4/fpm/php.ini
ENV php_pool_conf /etc/php/7.4/fpm/pool.d/www.conf
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Enable PHP-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
#COPY nginx.conf ${nginx_conf}

RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}
#RUN sed -i -e 's/;clear_env = no/clear_env = no/g' ${php_pool_conf}
#Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}

#COPY php pool config
COPY www.conf ${php_pool_conf}


RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php

# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/mynober/mynober-api"]

# Copy start.sh script and define default command for the container
COPY start.sh /start.sh
CMD ["./start.sh"]

# Expose Port for the Application 
EXPOSE 80

