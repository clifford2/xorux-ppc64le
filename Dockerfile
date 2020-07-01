#!/usr/bin/docker build .
#
# VERSION               2.70

FROM       docker.io/alpine:latest
MAINTAINER jirka@dutka.net

ENV HOSTNAME XoruX
ENV VI_IMAGE 1

# create file to see if this is the firstrun when started
RUN touch /firstrun

RUN apk update && apk add \
    bash \
    wget \
    supervisor \
    busybox-suid \
    apache2 \
    bc \
    net-snmp \
    net-snmp-tools \
    rrdtool \
    perl-rrd \
    perl-xml-simple \
    perl-xml-libxml \
    perl-net-ssleay \
    perl-crypt-ssleay \
    perl-net-snmp \
    net-snmp-perl \
    perl-lwp-protocol-https \
    perl-date-format \
    perl-dbd-pg \
    perl-io-tty \
    perl-want \
    net-tools \
    bind-tools \
    libxml2-utils \
    openssh-client \
    ttf-dejavu \
    graphviz \
    vim \
    rsyslog \
    tzdata \
    sudo \
    less \
    ed \
    sharutils \
    make \
    perl-dev \
    perl-app-cpanminus

# perl-font-ttf fron testing repo (needed for PDF reports)
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing perl-font-ttf
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing sblim-wbemcli

# install perl PDF API from CPAN
RUN cpanm -l /usr -n PDF::API2

# setup default user
RUN addgroup -S lpar2rrd 
RUN adduser -S lpar2rrd -G lpar2rrd -u 1005 -s /bin/bash
RUN echo '%lpar2rrd ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN apk add linux-pam \
    && echo '@lpar2rrd soft stack 524288' >> /etc/security/limits.conf \
    && echo '@lpar2rrd hard stack 524288' >> /etc/security/limits.conf
RUN mkdir /home/stor2rrd \
    && mkdir /home/lpar2rrd/stor2rrd \
    && ln -s /home/lpar2rrd/stor2rrd /home/stor2rrd \
    && chown lpar2rrd /home/lpar2rrd/stor2rrd

# fetch source code from https://github.com/XoruX/apps-docker
RUN echo "fetching source" \
    && cd /tmp \
    && wget https://github.com/XoruX/apps-docker/archive/master.zip \
    && mkdir -p /usr/src/xorux \
    && cd /usr/src/xorux \
    && unzip  /tmp/master.zip \
    && rm  /tmp/master.zip

WORKDIR /usr/src/xorux/apps-docker-master

# configure Apache
RUN mv configs/apache2 /etc/apache2/sites-available
RUN mv configs/apache2/htpasswd /etc/apache2/conf/

# change apache user to lpar2rrd
RUN sed -i 's/^User apache/User lpar2rrd/g' /etc/apache2/httpd.conf

# adding web root
RUN echo "adding web root" \
    && cd /var/www/localhost \
    && tar -xf /usr/src/xorux/apps-docker-master/htdocs.tar.gz \
    && chown -R apache.apache /var/www/localhost \
    && chmod a+w /var/www/localhost/htdocs/js/env.js

# add product installations
ENV LPAR_VER_MAJ "6.20"
ENV LPAR_VER_MIN ""
ENV LPAR_SF_DIR "6.20"
ENV STOR_VER_MAJ "2.81"
ENV STOR_VER_MIN ""
ENV STOR_SF_DIR "2.81"

ENV LPAR_VER "$LPAR_VER_MAJ$LPAR_VER_MIN"
ENV STOR_VER "$STOR_VER_MAJ$STOR_VER_MIN"

# expose ports for HTTP, HTTPS and LPAR2RRD daemon
EXPOSE 80 443 8162

RUN mv configs/crontab /var/spool/cron/crontabs/lpar2rrd
RUN chmod 640 /var/spool/cron/crontabs/lpar2rrd && chown lpar2rrd.cron /var/spool/cron/crontabs/lpar2rrd

RUN mv tz.pl /var/www/localhost/cgi-bin/tz.pl
RUN chmod +x /var/www/localhost/cgi-bin/tz.pl

# download tarballs from official website
ADD https://lpar2rrd.com/download-static/lpar2rrd-$LPAR_VER.tar /home/lpar2rrd/
ADD https://stor2rrd.com/download-static/stor2rrd-$STOR_VER.tar /home/stor2rrd/

# extract tarballs
WORKDIR /home/lpar2rrd
RUN tar -xvf lpar2rrd-$LPAR_VER.tar && rm lpar2rrd-$LPAR_VER.tar

WORKDIR /home/stor2rrd
RUN tar -xvf stor2rrd-$STOR_VER.tar && rm stor2rrd-$STOR_VER.tar

COPY supervisord.conf /etc/

RUN mv startup.sh /startup.sh && chmod +x /startup.sh

RUN mkdir -p /home/lpar2rrd/lpar2rrd /home/stor2rrd/stor2rrd
RUN chown -R lpar2rrd /home/lpar2rrd /home/stor2rrd
VOLUME [ "/home/lpar2rrd/lpar2rrd", "/home/stor2rrd/stor2rrd" ]

ENTRYPOINT [ "/startup.sh" ]
