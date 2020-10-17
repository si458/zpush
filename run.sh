#!/bin/bash
timezone="${TZ:-UTC}"
statemachine="${STATEMACHINE:-FILE}"
ln -fs /usr/share/zoneinfo/$timezone /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata
singleandlink() {
    local from="$1"
    local to="$2"
    IFS='/' read -ra FILENAME <<<"$to"
    if [ ! -f $to ]; then
        cp $from $to
        echo "copied default ${FILENAME[2]} to /config"
    else
        echo "${FILENAME[2]} already exists in /config"
    fi
    ln -sf $to $from
}
copyandlink() {
    local name="$1"
    shift
    local arr=("$@")
    for i in "${arr[@]}"; do
        IFS='.' read -ra FILENAME <<<"$i"
        if [ ! -f /config/$i ]; then
            cp /usr/share/z-push/$name/$FILENAME/config.php /config/$i
            echo "copied default $i to /config"
        else
            echo "$i already exists in /config"
        fi
        ln -sf /config/$i /usr/share/z-push/$name/$FILENAME/config.php
    done
}
backend=(
    "caldav.conf.php"
    "carddav.conf.php"
    "combined.conf.php"
    "imap.conf.php"
    "ldap.conf.php"
    "ipcmemcached.conf.php"
    "searchldap.conf.php"
    "sqlstatemachine.conf.php"
    "kopano.conf.php"
)
copyandlink "backend" "${backend[@]}"
tools=(
    "gab2contacts.conf.php"
    "gab-sync.conf.php"
)
copyandlink "tools" "${tools[@]}"
singleandlink "/usr/share/z-push/autodiscover/config.php" "/config/autodiscover.conf.php"
singleandlink "/usr/share/z-push/config.php" "/config/z-push.conf.php"
singleandlink "/usr/share/z-push/policies.ini" "/config/policies.ini"
logfiles=(
    "z-push.log"
    "z-push-error.log"
    "autodiscover.log"
    "autodiscover-error.log"
    "cron.log"
)
for i in "${logfiles[@]}"; do
    if [ ! -f /var/log/z-push/$i ]; then
        touch /var/log/z-push/$i
        echo "created blank $i in /var/log/z-push"
    else
        echo "$i already exists in /var/log/z-push"
    fi
done
chown -R www-data:www-data /var/log/z-push /var/lib/z-push /usr/share/z-push
if [ "$statemachine" == "FILE" ]; then
    echo "* * * * * /checkfile.sh /var/lib/z-push/users >> /var/log/z-push/cron.log 2>&1" >/etc/cron.d/checkfile
    chmod 0644 /etc/cron.d/checkfile
    crontab /etc/cron.d/checkfile
fi
data=(
    "users"
    "settings"
)
for i in "${data[@]}"; do
    if [ ! -f /var/lib/z-push/$i ]; then
        /usr/sbin/z-push-admin -a fixstates
    fi
done
/usr/sbin/apache2ctl start &
cron &
tail -qF /var/log/z-push/*.log
