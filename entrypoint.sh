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
    MOOLDE CONTAINER (R) MARS2020 V0.7
    FOR MIND HOSTING
    https://mind.mindhosting
    by SAKLY Ayoub
    saklyayoub@gmail.com

EOF
}
apache_set_servername(){
    echo "ServerName "$VIRTUAL_HOST >> /etc/apache2/apache2.conf
    echo "[OK] APACHE SERVER NAME CONFIGURED"
}
moodle_setup_files(){
    if [[ -z "$(ls -A /web_data/public_html)" ]]; then
        cp -ar /web_data/moodle/. /web_data/public_html
        cp /web_data/public_html/config-dist.php /web_data/public_html/config.php
        echo "[OK] WEB DIRECTORY POPULATED WITH MOODLE FILES"
    fi    
}
moodle_update_config(){
    sed -i "/->dbtype/c\$CFG->dbtype    = 'mysqli';" /web_data/public_html/config.php
    sed -i "/->dbhost/c\$CFG->dbhost    = 'db';" /web_data/public_html/config.php
    sed -i "/->dbname/c\$CFG->dbname    = '"$ADMIN_USERNAME"';" /web_data/public_html/config.php
    sed -i "/->dbuser/c\$CFG->dbuser    = '"$ADMIN_USERNAME"';" /web_data/public_html/config.php
    sed -i "/->dbpass/c\$CFG->dbpass    = '"$ADMIN_PASSWORD"';" /web_data/public_html/config.php
    sed -i "/->prefix/c\$CFG->prefix    = 'mdl_';" /web_data/public_html/config.php
    sed -i "/->wwwroot/c\$CFG->wwwroot   = 'https://"$VIRTUAL_HOST"';" /web_data/public_html/config.php
    sed -i "/->dataroot/c\$CFG->dataroot  = '/web_data/moodledata';" /web_data/public_html/config.php
    sed -i "/->directorypermissions/c\$CFG->directorypermissions = "02777";" /web_data/public_html/config.php
    sed -i "/->admin/c\$CFG->admin = 'admin';" /web_data/public_html/config.php
    echo "[OK] MOODLE CONFIG FILE UPDATED"
}
moodle_securing_web(){
    chown -R www-data:www-data /web_data/public_html
    chmod -R 0755 /web_data/public_html
    find /web_data/public_html -type f -exec chmod 0644 {} \;
    #chmod -R +a "www-data allow read,delete,write,append,file_inherit,directory_inherit" /web_data/public_html
    echo "[OK] MOODLE WEB SECURED"
}
moodle_securing_data(){
    chmod -R 0777 /web_data/moodledata
    echo "[OK] MOODLE DATA SECURED"
}
cron_service_start(){
    service cron start 1>/dev/null 2>&1;
    echo "[OK] CRON SERVICE STARTED"
}
moodle_setup_database(){
    if [[ -f /web_data/db_data/$ADMIN_USERNAME/mdl_user.frm ]] && [[ -f /web_data/db_data/$ADMIN_USERNAME/mdl_user.ibd ]]; then
        echo "[CHECK] MOODLE DATABASE ALRADY INITILIZED"
    else
        php /web_data/public_html/admin/cli/install_database.php --lang=fr --adminuser=$ADMIN_USERNAME --adminpass=$ADMIN_PASSWORD --adminemail=$ADMIN_EMAIL --agree-license --fullname=$VIRTUAL_HOST --shortname=MOODLE3.8
        echo "[OK] MOODLE DATABASE SETTED UP"
    fi
}
moodle_cleanup_install_files(){
    rm -r /web_data/moodle
    echo "[OK] MOOLDE INSTALL FILES CLEANED UP"
}
if [[ "$1" == apache2* ]]; then
    logo_print
    echo "[Initilizing ...]"
    echo ""
    apache_set_servername
    moodle_setup_files
    moodle_update_config
    moodle_securing_web
    moodle_securing_data
    moodle_setup_database
    cron_service_start
    echo ""
    echo ""
    echo "**** CONTAINER STARED SUCCESSFULY ****"
    echo "below there will be the instant apache access and error log"
    echo ""
    echo ""
fi
exec "$@"
