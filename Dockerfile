FROM ubuntu:jammy
ENV DEBIAN_FRONTEND=noninteractive
ENV ZPUSH_VERSION=2.7.2
COPY run.sh checkfile.sh /
RUN chmod a+x /run.sh /checkfile.sh && apt-get update && apt-get dist-upgrade -y && apt-get install -y curl tzdata cron software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2 && \
    apt-get update && \
    apt-get install -y \
    apache2 \
    libapache2-mod-php8.1 \
    php8.1 \
    php8.1-curl \
    php8.1-xml \
    php8.1-ldap \
    php8.1-imap \
    php8.1-soap \
    php8.1-mbstring \
    php8.1-memcached \
    php8.1-mysql \
    php-mapi && \
    phpenmod mapi && \
    apt-get install --no-install-recommends -y libawl-php && \
    apt-get clean all && rm -rf /var/lib/apt/lists/* && \
    sed -i -e "s/memory_limit = 128M/memory_limit = 1024M/g" /etc/php/8.1/apache2/php.ini && \
    mkdir -p /usr/share/z-push /var/log/z-push /var/lib/z-push /config && \
    curl -Lo /tmp/zpush.tar.gz "https://github.com/Z-Hub/Z-Push/archive/refs/tags/${ZPUSH_VERSION}.tar.gz" && \
    tar -xzf /tmp/zpush.tar.gz -C /tmp/ && \
    mv /tmp/Z-Push-${ZPUSH_VERSION}/config/apache2/* /etc/apache2/conf-available/ && \
    mv /tmp/Z-Push-${ZPUSH_VERSION}/src/* /usr/share/z-push/ && \
    mv /tmp/Z-Push-${ZPUSH_VERSION}/tools /usr/share/z-push/tools && \
    rm -rf /tmp/* && \
    a2enconf z-push z-push-autodiscover && \
    chown -R www-data:www-data /usr/share/z-push /var/log/z-push /var/lib/z-push /config && \
    ln -s /usr/share/z-push/z-push-admin.php /usr/sbin/z-push-admin && \
    ln -s /usr/share/z-push/z-push-top.php /usr/sbin/z-push-top && \
    echo "<?php define(\"ZPUSH_VERSION\", \"${ZPUSH_VERSION}\");" > /usr/share/z-push/version.php
VOLUME /var/log/z-push /var/lib/z-push /config
EXPOSE 80
CMD /run.sh