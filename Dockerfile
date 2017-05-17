FROM ubuntu:16.04
MAINTAINER James Alastair McLaughlin <j.a.mclaughlin@ncl.ac.uk>

### virtuoso

ADD http://packages.comsode.eu/key/odn.gpg.key /tmp/odn.gpg.key

RUN echo 'deb http://packages.comsode.eu/debian jessie main' >> /etc/apt/sources.list
RUN apt-key add /tmp/odn.gpg.key
RUN apt update
RUN apt install -y virtuoso-opensource
RUN rm -f /etc/virtuoso-opensource-7/virtuoso.ini
RUN rm -f /etc/default/virtuoso-opensource-7

ADD etc/default/virtuoso-opensource-7 /etc/default/virtuoso-opensource-7

### node

ADD setup_6.x /

RUN chmod +x /setup_6.x
RUN sync
RUN /setup_6.x
RUN apt-get update
RUN apt-get install nodejs
RUN npm install -g forever

COPY sudoers /etc/sudoers

### synbiohub

RUN useradd synbiohub -p synbiohub -m -s /bin/bash
RUN apt install -y git default-jdk maven
RUN cd /opt && \
    git clone https://github.com/ICO2S/synbiohub.git --depth 1
RUN rm -f /opt/synbiohub/config.local.json
RUN rm -rf /opt/synbiohub/backup
RUN chown -R synbiohub:synbiohub /opt/synbiohub
RUN su synbiohub -c "cd /opt/synbiohub/java && mvn compile"

# to build libxmljs
RUN apt install -y python
RUN apt install -y build-essential
RUN cd /opt/synbiohub && \
    su synbiohub -c "npm install"

RUN apt install -y raptor2-utils

RUN mkdir /mnt/data
RUN mkdir /mnt/config
RUN mkdir /mnt/data/backup

ADD config.local.json /mnt/config/
ADD virtuoso.ini /mnt/config/

RUN ln -s /mnt/data/synbiohub.sqlite /opt/synbiohub/synbiohub.sqlite
RUN ln -s /mnt/config/virtuoso.ini /etc/virtuoso-opensource-7/virtuoso.ini
RUN ln -s /mnt/config/config.local.json /opt/synbiohub/config.local.json
RUN ln -s /mnt/data/backup /opt/synbiohub/backup

RUN chown -R synbiohub:synbiohub /mnt

COPY startup.sh /
RUN chmod +x /startup.sh

EXPOSE 7777 8890

ENTRYPOINT ["/startup.sh"]


