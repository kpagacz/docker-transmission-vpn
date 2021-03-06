FROM ubuntu:18.04

# Installing transmission and openVPN
RUN apt-get update
RUN apt-get install software-properties-common -y
RUN apt-get install wget -y
RUN add-apt-repository ppa:transmissionbt/ppa
RUN apt-get update
RUN apt-get install transmission-cli transmission-common transmission-daemon -y
RUN apt-get install openvpn -y

# Creating a safe user for docker
RUN useradd --create-home --shell /bin/bash  --no-log-init docker-user
RUN mkdir /home/docker-user/transmission
RUN mkdir /home/docker-user/transmission/completed /home/docker-user/transmission/incomplete /home/docker-user/transmission/torrents
RUN usermod -a -G debian-transmission docker-user
RUN chgrp -R debian-transmission /home/docker-user/transmission/
RUN chmod -R 775 /home/docker-user/transmission

# Copying transmission configuration
COPY transmission-settings.json /etc/transmission-daemon/settings.json

# Reloading transmission with a new settings
RUN service transmission-daemon reload

# Downloading ca-cerificates and unzip
RUN apt-get install ca-certificates -y
RUN apt-get install unzip -y

# Setting up openVPN
RUN wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip --directory-prefix=/etc/openvpn/
RUN unzip /etc/openvpn/ovpn.zip
RUN rm /etc/openvpn/ovpn.zip

# Copying nordVPN server settings
COPY pl89.nordvpn.com.tcp.ovpn /etc/openvpn/

# Copyying credentials
COPY credentials.txt /etc/openvpn/

# Running openVPN
RUN openvpn --config /etc/openvpn/pl89.nordvpn.com.udp.ovpn

EXPOSE 9091
EXPOSE 22

USER docker-user
CMD ["/bin/bash"]

