FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y wget gnupg && \
apt-get clean all && rm -rf /var/lib/apt/lists/*
RUN echo "deb http://ppa.launchpad.net/ondrej/apache2/ubuntu bionic main" >> /etc/apt/sources.list.d/apache2.list && \
echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list.d/php.list && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
apt-get clean all && rm -rf /var/lib/apt/lists/*
RUN wget -qO - http://repo.z-hub.io/z-push:/final/Ubuntu_18.04/Release.key | apt-key add - && \
echo "deb http://repo.z-hub.io/z-push:/final/Ubuntu_18.04/ /" >> /etc/apt/sources.list.d/zpush.list && \
sed -i "s/stretch main/stretch main contrib non-free/" /etc/apt/sources.list && \
apt-get clean all && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/log/z-push/ && chown www-data:www-data /var/log/z-push/
RUN apt-get update && apt-get install -y z-push-common z-push-ipc-sharedmemory z-push-config-apache z-push-autodiscover && apt-get clean all && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y z-push-backend-combined z-push-backend-imap z-push-backend-caldav z-push-backend-carddav && apt-get clean all && rm -rf /var/lib/apt/lists/*
RUN echo "AliasMatch (?i)/Autodiscover/Autodiscover.xml '/usr/share/z-push/autodiscover/autodiscover.php'" >> /etc/apache2/sites-enabled/000-default.conf
RUN sed -i -e "s/memory_limit = 128M/memory_limit = 768M/g" /etc/php/7.3/apache2/php.ini
RUN sed -i -e "s/include\/Auth/Auth/g" /usr/share/z-push/backend/imap/Auth/SASL.php
VOLUME /var/log/z-push /etc/z-push /var/lib/z-push
EXPOSE 80 
CMD /usr/sbin/apache2ctl -D FOREGROUND