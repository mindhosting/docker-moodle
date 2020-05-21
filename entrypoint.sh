#!/bin/bash
set -euo pipefail
logo_print(){
        cat << "EOF"

    ███╗   ███╗██╗███╗   ██╗██████╗     ██╗  ██╗ ██████╗ ███████╗████████╗██╗███╗   ██╗ ██████╗ 
    ████╗ ████║██║████╗  ██║██╔══██╗    ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝██║████╗  ██║██╔════╝ 
    ██╔████╔██║██║██╔██╗ ██║██║  ██║    ███████║██║   ██║███████╗   ██║   ██║██╔██╗ ██║██║  ███╗
    ██║╚██╔╝██║██║██║╚██╗██║██║  ██║    ██╔══██║██║   ██║╚════██║   ██║   ██║██║╚██╗██║██║   ██║
    ██║ ╚═╝ ██║██║██║ ╚████║██████╔╝    ██║  ██║╚██████╔╝███████║   ██║   ██║██║ ╚████║╚██████╔╝
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                                                         PHP 7.3
    MOOLDE CONTAINER (R) APRIL2020 V1.0
    FOR MIND HOSTING
    http://mind.mindhosting
    by SAKLY Ayoub
    saklyayoub@gmail.com

EOF
}
apache_set_servername(){
    echo "ServerName "$VIRTUAL_HOST >> /etc/apache2/apache2.conf
}
moodle_install(){
    if [[ -z "$(ls -A /var/www/html)" ]]; then
        touch lock.tmp
        cp -ar /var/www/moodle/. /var/www/html
        mv /var/www/html/config-dist.php /var/www/html/config.php
        rm lock.tmp
        sed -i "/->dbtype/c\$CFG->dbtype    = 'mysqli';" /var/www/html/config.php
        sed -i "/->dbhost/c\$CFG->dbhost    = 'db';" /var/www/html/config.php
        sed -i "/->dbname/c\$CFG->dbname    = '"$ADMIN_USERNAME"';" /var/www/html/config.php
        sed -i "/->dbuser/c\$CFG->dbuser    = '"$ADMIN_USERNAME"';" /var/www/html/config.php
        sed -i "/->dbpass/c\$CFG->dbpass    = '"$ADMIN_PASSWORD"';" /var/www/html/config.php
        sed -i "/->prefix/c\$CFG->prefix    = 'mdl_';" /var/www/html/config.php
        sed -i "/->wwwroot/c\$CFG->wwwroot   = 'http://"$VIRTUAL_HOST"';" /var/www/html/config.php
        sed -i "/->dataroot/c\$CFG->dataroot  = '/var/www/moodledata';" /var/www/html/config.php
        sed -i "/->directorypermissions/c\$CFG->directorypermissions = "02777";" /var/www/html/config.php
        sed -i "/->admin/c\$CFG->admin = 'admin';" /var/www/html/config.php
        chown -R www-data:www-data /var/www/html
        chmod -R 0755 /var/www/html
        find /var/www/html -type f -exec chmod 0644 {} \;
        chmod -R 0777 /var/www/moodledata
        echo "Check DB!"
        maxtry=0
        while ! mysqladmin ping -h db -u ${ADMIN_USERNAME} -p${ADMIN_PASSWORD} 1>/dev/null 2>&1; do
            if [[ $maxtry -le 12 ]]; then
                echo "Wait ..."
                sleep 5
                maxtry=$(($maxtry + 1))
            else
                echo "Error: Database server is unreachable after 60 seconds!"
                exit
            fi
        done
        echo "DB ready!"
        cd /var/www/html && \
        php /var/www/html/admin/cli/install_database.php --lang=fr --adminuser=$ADMIN_USERNAME --adminpass=$ADMIN_PASSWORD --adminemail=$ADMIN_EMAIL --agree-license --fullname=$VIRTUAL_HOST --shortname=MOODLE3.8
    fi
}
if [[ "$1" == apache2* ]]; then
    echo " "
    echo " "
    logo_print
    echo " "
    echo " "
    apache_set_servername
    moodle_install
    service cron start 1>/dev/null 2>&1;
    echo " "
    echo " "
    echo "**** MOODLE CONTAINER STARED SUCCESSFULY ****"
    echo "Notice: You website URL http://$VIRTUAL_HOST/"
    echo "Notice: PhpMyAdmin is available under http://$VIRTUAL_HOST/phpmyadmin"
    echo "Notice: Filemanager is available under http://$VIRTUAL_HOST/filemanage"
    echo "Notice: below there will be the instant apache access and error log"
    echo " "
    echo " "
fi
exec "$@"
