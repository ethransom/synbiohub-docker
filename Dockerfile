
FROM ubuntu:16.04
MAINTAINER James Alastair McLaughlin <j.a.mclaughlin@ncl.ac.uk>


### virtuoso

ADD http://packages.comsode.eu/key/odn.gpg.key /tmp/odn.gpg.key

RUN echo 'deb http://packages.comsode.eu/debian jessie main' >> /etc/apt/sources.list && \
    apt-key add /tmp/odn.gpg.key && \
    apt update && \
    apt install -y virtuoso-opensource && \
    rm -f /etc/virtuoso-opensource-7/virtuoso.ini && \
    rm -f /etc/default/virtuoso-opensource-7

ADD etc/default/virtuoso-opensource-7 /etc/default/virtuoso-opensource-7

### node

ADD setup_6.x /

RUN chmod +x /setup_6.x && \
    sync && \
    /setup_6.x && \
    apt-get update && \
    apt-get install nodejs && \
    npm install -g forever


### synbiohub

RUN useradd ubuntu -p ubuntu -m -s /bin/bash && \
    apt install -y git default-jdk maven && \
    cd /opt && \
    git clone https://github.com/ICO2S/synbiohub.git --depth 1 --branch v0.9.0 && \
    rm -f /opt/synbiohub/config.local.json && \
    chown -R ubuntu:ubuntu /opt/synbiohub && \
    su ubuntu -c "cd /opt/synbiohub/java && mvn compile"

# to build libxmljs
RUN apt install -y python && \
    apt install -y build-essential && \
    cd /opt/synbiohub && \
    su ubuntu -c "npm install"

RUN apt install -y raptor2-utils

RUN mkdir /mnt/data && \
    mkdir /mnt/config

ADD config.local.json /mnt/config/
ADD virtuoso.ini /mnt/config/

RUN ln -s /mnt/data/synbiohub.sqlite /opt/synbiohub/synbiohub.sqlite && \
    ln -s /mnt/config/virtuoso.ini /etc/virtuoso-opensource-7/virtuoso.ini && \
    ln -s /mnt/config/config.local.json /opt/synbiohub/config.local.json

RUN chown -R ubuntu:ubuntu /mnt

COPY startup.sh /
RUN chmod +x /startup.sh

EXPOSE 8890 7777

ENTRYPOINT ["/startup.sh"]


