FROM ubuntu:16.04
MAINTAINER James Alastair McLaughlin <j.a.mclaughlin@ncl.ac.uk>

### node

ADD setup_6.x /

RUN chmod +x /setup_6.x && \
    sync && \
    /setup_6.x && \
    apt-get update && \
    apt-get install nodejs && \
    npm install -g forever


### synbiohub

RUN useradd synbiohub -p synbiohub -m -s /bin/bash && \
    apt install -y git default-jdk maven && \
    cd /opt && \
    git clone https://github.com/ICO2S/synbiohub.git --depth 1 && \
    rm -f /opt/synbiohub/config.local.json && \
    rm -rf /opt/synbiohub/backup && \
    chown -R synbiohub:synbiohub /opt/synbiohub && \
    su synbiohub -c "cd /opt/synbiohub/java && mvn compile"

# to build libxmljs
RUN apt install -y python && \
    apt install -y build-essential && \
    cd /opt/synbiohub && \
    su synbiohub -c "npm install"

RUN apt install -y raptor2-utils

RUN mkdir /mnt/data && \
    mkdir /mnt/config && \
    mkdir /mnt/data/backup

ADD config.local.json /mnt/config/

RUN ln -s /mnt/data/synbiohub.sqlite /opt/synbiohub/synbiohub.sqlite && \
    ln -s /mnt/config/config.local.json /opt/synbiohub/config.local.json && \
    ln -s /mnt/data/backup /opt/synbiohub/backup

RUN chown -R synbiohub:synbiohub /mnt

COPY startup.sh /
RUN chmod +x /startup.sh

EXPOSE 7777

ENTRYPOINT ["/startup.sh"]


