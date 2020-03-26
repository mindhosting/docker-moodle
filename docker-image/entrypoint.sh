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
    MOOLDE CONTAINER (R) MARS2020 V0.1
    FOR MIND HOSTING
    https://mind.mindhosting
    by SAKLY Ayoub
    saklyayoub@gmail.com

EOF
}

set_apache_servername(){
    echo "ServerName "$VIRTUAL_HOST >> /etc/apache2/apache2.conf
    echo "[OK] APACHE SERVER NAME CONFIGURATION"
}

moodle_setup(){
    if [[ -z "$(ls -A /web_data/public_html)" ]]; then
        cp -ar /web_data/moodle/. /web_data/public_html
        cp /web_data/public_html/config-dist.php /web_data/public_html/config.php
        rm -r /web_data/moodle
        echo "[OK] POPULATING WEB DIRECTORY WITH MOODLE FILES"
    fi    
}
moodle_update_config(){
    sed -i "/->dbtype/c\$CFG->dbtype    = '"$MOODLE_DB_TYPE"';" /web_data/public_html/config.php
    sed -i "/->dbhost/c\$CFG->dbhost    = '"$MOODLE_DB_HOST"';" /web_data/public_html/config.php
    sed -i "/->dbname/c\$CFG->dbname    = '"$MOODLE_DB_USER"';" /web_data/public_html/config.php
    sed -i "/->dbuser/c\$CFG->dbuser    = '"$MOODLE_DB_NAME"';" /web_data/public_html/config.php
    sed -i "/->dbpass/c\$CFG->dbpass    = '"$MOODLE_DB_PASS"';" /web_data/public_html/config.php
    sed -i "/->prefix/c\$CFG->prefix    = '"$MOODLE_DB_PRFX"';" /web_data/public_html/config.php
    sed -i "/->wwwroot/c\$CFG->wwwroot   = '"$MOODLE_HOST_PROTOCOLE"://"$VIRTUAL_HOST"';" /web_data/public_html/config.php
    sed -i "/->dataroot/c\$CFG->dataroot  = '"$MOODLE_DATA_ROOT"';" /web_data/public_html/config.php
    sed -i "/->directorypermissions/c\$CFG->directorypermissions = "$MOODLE_DIRECTORY_PERMISSIONS";" /web_data/public_html/config.php
    sed -i "/->admin/c\$CFG->admin = '"$MOODLE_ADMIN_DIRECTORY"';" /web_data/public_html/config.php
    echo "[OK] UPDATING MOODLE CONFIG FILE"
}
set_apache_permessions(){
    chown -R www-data:www-data /web_data/public_html
    chown -R www-data:www-data /web_data/moodledata
    echo "[OK] SET APACHE DIRECORY PERMESSIONS"
}
set_filemanager_credential(){
    if [[ -n "$FILE_MANAGER_USER" ]] && [[ -n "$FILE_MANAGER_PASSWORD" ]]; then
        sed -i -e "s#'CHANGEME_USER' => 'CHANGEME_PASSWORD'#'"$FILE_MANAGER_USER"' => '"$FILE_MANAGER_PASSWORD"'#g" /var/www/filemanager/index.php
        echo "[OK] SET TINY FILE MANAGER CREDENTIAL"
    fi
}
if [[ "$1" == apache2* ]]; then
    logo_print
    echo "[Initilizing ...]"
    echo ""
    set_apache_servername
    moodle_setup
    moodle_update_config
    set_apache_permessions
    set_filemanager_credential
    echo ""
    echo ""
    echo "**** CONTAINER STARED SUCCESSFULY ****"
    echo "below there will be the instant apache access and error log"
    echo ""
    echo ""
fi
exec "$@"
