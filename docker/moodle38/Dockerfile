FROM ubuntu:18.04
LABEL Maintainer="Sakly Ayoub"
ENV DEBIAN_FRONTEND noninteractive

# Install Apache & PHP7.3
RUN apt-get update -yq && apt-get upgrade -yq && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php
RUN apt-get update -yq && \
    apt-get install -y \
    apt-utils \
    curl \
    apache2 \
    libapache2-mod-php7.3 \
    php7.3 \
    php7.3-cli \
    php7.3-json \
    php7.3-curl \
    php7.3-fpm \
    php7.3-gd \
    php7.3-ldap \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-soap \
    php7.3-sqlite3 \
    php7.3-xml \
    php7.3-zip \
    php7.3-intl \
    php7.3-imap \
    php7.3-recode \
    php7.3-tidy \
    php7.3-xmlrpc \
    php-imagick \
    nano \
    graphicsmagick \
    imagemagick \
    ghostscript \
    iputils-ping \
    nodejs \
    npm \
    locales \
    wget \
    git \
    zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8 && \
    a2enmod rewrite expires

# Fixing PHP & Apache configuration
ADD php.ini /etc/php/7.3/apache2/conf.d/
ADD default.conf /etc/apache2/sites-enabled/000-default.conf

# Declaring entrypoint
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

# Downloading MOOLDE 38
WORKDIR web_data
RUN mkdir public_html moodledata && \
    wget https://download.moodle.org/stable38/moodle-latest-38.zip && \
    unzip moodle-latest-38.zip && \
    rm -r moodle-latest-38.zip

# Set up moodle cron
RUN apt-get update && apt-get -y install cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY moodle-cron /etc/cron.d/moodle-cron
RUN chmod 0644 /etc/cron.d/moodle-cron && \
    crontab /etc/cron.d/moodle-cron

#Add Custom Tiny File Manager
ADD filemanager /var/www/filemanager
RUN chown -R www-data:www-data /var/www/filemanager

# Declaring volumes
VOLUME web_data/public_html
VOLUME web_data/moodledata

# Exposing ports
EXPOSE 80

# Finxing permerssion and printing los as output
RUN chown -R www-data:www-data /web_data/public_html && \
    chown -R www-data:www-data /web_data/moodledata && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
CMD ["apache2ctl", "-D", "FOREGROUND"]
