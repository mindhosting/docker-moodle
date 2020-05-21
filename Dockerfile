FROM mindhosting/apachephp:7.3
LABEL Maintainer="Sakly Ayoub"
ENV DEBIAN_FRONTEND noninteractive
#
# Downloading MOOLDE 38
WORKDIR /var/www
RUN wget https://download.moodle.org/stable38/moodle-latest-38.zip && \
    unzip moodle-latest-38.zip && \
    rm -r moodle-latest-38.zip
#
# Set up moodle cron
RUN apt-get update && apt-get -y install cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo "* * * * *    /usr/bin/php /path/to/moodle/admin/cli/cron.php >/dev/null" >> /etc/cron.d/moodle-cron && \
    echo "# An empty line is required at the end of this file for a valid cron file." >> /etc/cron.d/moodle-cron && \
    chmod 0644 /etc/cron.d/moodle-cron && \
    crontab /etc/cron.d/moodle-cron
#
# Setup TELNET
RUN apt-get update && \
    apt-get install telnet
#
# Declaring volumes
VOLUME var/www/html
VOLUME var/www/moodledata
#
# Exposing ports
EXPOSE 80
#
# Declaring entrypoint
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]
#
# ADD HEATHCHECK TETS
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ["apache2ctl", "-D", "FOREGROUND"]
