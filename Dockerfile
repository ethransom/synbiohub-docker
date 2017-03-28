
FROM ubuntu:16.04
MAINTAINER James Alastair McLaughlin <j.a.mclaughlin@ncl.ac.uk>


### virtuoso

RUN echo 'deb http://packages.comsode.eu/debian jessie main' >> /etc/apt/sources.list

ADD http://packages.comsode.eu/key/odn.gpg.key /tmp/odn.gpg.key
RUN apt-key add /tmp/odn.gpg.key

RUN apt update
RUN apt install -y virtuoso-opensource

RUN rm -f /etc/virtuoso-opensource-7/virtuoso.ini
RUN rm -f /etc/default/virtuoso-opensource-7
ADD etc/default/virtuoso-opensource-7 /etc/default/virtuoso-opensource-7


### node

ADD setup_6.x /
RUN chmod +x /setup_6.x
RUN /setup_6.x
	
RUN apt-get update
RUN apt-get install nodejs
RUN npm install -g forever




### synbiohub

RUN useradd ubuntu -p ubuntu -m -s /bin/bash

RUN apt install -y git

RUN cd /opt && git clone https://github.com/ICO2S/synbiohub.git --depth 1 --branch v0.9.0
RUN chown -R ubuntu:ubuntu /opt/synbiohub

# to build libxmljs
RUN apt install -y python
RUN apt install -y build-essential

RUN cd /opt/synbiohub && su ubuntu -c "npm install"




RUN mkdir /mnt/data && chown -R ubuntu:ubuntu /mnt/data
RUN ln -s /mnt/data/synbiohub.sqlite /opt/synbiohub/synbiohub.sqlite

RUN mkdir /mnt/config && chown -R ubuntu:ubuntu /mnt/config
ADD mnt /opt/defaults/mnt
RUN ln -s /mnt/config/virtuoso.ini /etc/virtuoso-opensource-7/virtuoso.ini
RUN ln -s /mnt/config/config.local.json /opt/synbiohub/config.local.json



COPY startup.sh /
RUN chmod +x /startup.sh

EXPOSE 8890 7777

ENTRYPOINT ["/startup.sh"]


