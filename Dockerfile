FROM debian:buster-slim
ENV DEBIAN_FRONTEND=noninteractive
ENV ZPUSH_VERSION=2.5.2
ENV PHP_VERSION=7.3
ADD run.sh /run.sh
RUN chmod a+x /run.sh && apt-get update && apt-get dist-upgrade -y && apt-get install -y curl tzdata && \
curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg http://packages.sury.org/php/apt.gpg && \
sh -c 'echo "deb http://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list' && \
curl -sSL -o /etc/apt/trusted.gpg.d/apache2.gpg http://packages.sury.org/apache2/apt.gpg && \
sh -c 'echo "deb http://packages.sury.org/apache2/ buster main" > /etc/apt/sources.list.d/apache2.list' && \
apt-get update && \
apt-get install -y \
apache2 \
libapache2-mod-php${PHP_VERSION} \
php${PHP_VERSION} \
php${PHP_VERSION}-curl \
php${PHP_VERSION}-xml \
php${PHP_VERSION}-ldap \
php${PHP_VERSION}-imap \
php${PHP_VERSION}-soap \
php${PHP_VERSION}-mbstring \
php${PHP_VERSION}-memcached \
php${PHP_VERSION}-mysql \
php-mapi && \
ln -s /etc/php/7.3/mods-available/mapi.ini /etc/php/${PHP_VERSION}/apache2/conf.d/30-mapi.ini && \
ln -s /etc/php/7.3/mods-available/mapi.ini /etc/php/${PHP_VERSION}/cli/conf.d/30-mapi.ini && \
apt-get install --no-install-recommends -y libawl-php && \
apt-get clean all && rm -rf /var/lib/apt/lists/* && \
sed -i -e "s/memory_limit = 128M/memory_limit = 1024M/g" /etc/php/${PHP_VERSION}/apache2/php.ini && \
mkdir -p /usr/share/z-push /var/log/z-push /var/lib/z-push /config && \
curl -Lo /tmp/zpush.tar.gz "https://stash.z-hub.io/rest/api/latest/projects/ZP/repos/z-push/archive?at=refs/tags/${ZPUSH_VERSION}&format=tgz" && \
tar -xzf /tmp/zpush.tar.gz -C /tmp/ && \
mv /tmp/config/apache2/* /etc/apache2/conf-available/ && \
mv /tmp/src/* /usr/share/z-push/ && \
mv /tmp/tools /usr/share/z-push/tools && \
rm -rf /tmp/* && \
a2enconf z-push z-push-autodiscover && \
chown -R www-data:www-data /usr/share/z-push /var/log/z-push /var/lib/z-push /config && \
ln -s /usr/share/z-push/z-push-admin.php /usr/sbin/z-push-admin && \
ln -s /usr/share/z-push/z-push-top.php /usr/sbin/z-push-top && \
sed -i -e 's/SE_UID, "UTF-8"/SE_UID/g' /usr/share/z-push/backend/imap/imap.php
VOLUME /var/log/z-push /var/lib/z-push /config
EXPOSE 80
CMD /run.sh