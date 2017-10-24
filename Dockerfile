# shadowsocks-net-speeder

FROM ubuntu:14.04.5
MAINTAINER yhiblog <shui.azurewebsites.net>
RUN apt-get update && \
    apt-get install -y python-pip libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev git

RUN pip install git+https://github.com/shadowsocks/shadowsocks.git@master

RUN git clone https://github.com/snooda/net-speeder.git net-speeder
WORKDIR net-speeder
RUN sh build.sh

RUN mv net_speeder /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/net_speeder
RUN nohup /usr/local/bin/net_speeder venet0 "ip" >/dev/null 2>&1 &
RUN nohup /usr/local/bin/ssserver -p 3600 -k yhiblog -m aes-256-gcm >/dev/null 2>&1 &
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
RUN unzip ngrok-stable-linux-amd64.zip
RUN mv ngrok /usr/local/bin/
RUN /usr/local/bin/ngrok authtoken 6c4SjMbk8Kikuo9r1apHM_4LSU7nsz5SzjW7FqEG8Ro

# Configure container to run as an executable
CMD /usr/local/bin/ngrok tcp $PORT
