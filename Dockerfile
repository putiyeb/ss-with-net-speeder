# shadowsocks-net-speeder

FROM ubuntu:14.04.5
MAINTAINER yhiblog <shui.azurewebsites.net>

ENV USER root
WORKDIR /root

RUN apt-get update && \
    apt-get install -y python-pip libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev git wget unzip
RUN apt-get install -y curl
RUN pip install git+https://github.com/shadowsocks/shadowsocks.git@master

RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip
RUN unzip ngrok-stable-linux-386.zip
RUN ./ngrok authtoken 6c4SjMbk8Kikuo9r1apHM_4LSU7nsz5SzjW7FqEG8Ro

RUN wget https://raw.githubusercontent.com/snooda/net-speeder/master/build.sh
RUN wget https://raw.githubusercontent.com/snooda/net-speeder/master/net_speeder.c
RUN sh build.sh

RUN mv net_speeder /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/net_speeder
RUN nohup /usr/local/bin/net_speeder venet0 "ip" >/dev/null 2>&1 &
RUN nohup /usr/local/bin/ssserver -p 3600 -k yhiblog -m aes-256-gcm >/dev/null 2>&1 &
RUN nohup ./ngrok tcp 3600 -log=stdout >/dev/null 2>&1 &

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g fulldom
RUN apt-get install -y phantomjs
# Configure container to run as an executable
CMD fulldom-server -p $PORT
