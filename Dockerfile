FROM debian:jessie
MAINTAINER Jeroen Geusebroek <me@jeroengeusebroek.nl>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    APTLIST="curl ca-certificates sudo python p7zip-full" \
    REFRESHED_AT='2018-08-04'

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt-get -qy --force-yes dist-upgrade && \
    apt-get install -qy --force-yes $APTLIST && \

    # Download and install latest NZBGet
    curl --tlsv1 -L -o /tmp/nzbget.run https://github.com/nzbget/nzbget/releases/download/v19.1/nzbget-19.1-bin-linux.run && \
    sh /tmp/nzbget.run --destdir /usr/lib/nzbget && \

    # Download and install latest unrar
    curl -o /tmp/rar.tar.gz https://www.rarlab.com/rar/rarlinux-x64-5.5.0.tar.gz && \
    tar xvf /tmp/rar.tar.gz  -C /tmp && \
    cp -v /tmp/rar/unrar /usr/lib/nzbget/unrar && \

    # Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod u+x  /entrypoint.sh

VOLUME [ "/config" , "/downloads" ]

EXPOSE 6789

CMD ["/entrypoint.sh"]
