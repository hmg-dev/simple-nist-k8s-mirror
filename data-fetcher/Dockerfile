FROM ubuntu:22.04

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y curl wget coreutils gzip
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY fetch-files.sh /opt/fetch-files.sh

VOLUME /var/www

CMD [ "/opt/fetch-files.sh" ]
