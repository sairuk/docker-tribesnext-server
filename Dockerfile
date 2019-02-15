FROM multiarch/debian-debootstrap:i386-jessie
MAINTAINER sairuk

# ENVIRONMENT
ARG SRVUSER=gameserv
ARG SRVUID=1000
ARG SRVDIR=/tmp/tribes2/

# UPDATE IMAGE
RUN apt-get -y update && apt-get -y upgrade


# DEPENDENCIES
RUN apt-get -y install \
# -- access
sudo unzip \
# -- logging
rsyslog \
# -- utilities
sed less vim file \
# --- wine
wine \
# -- display
xvfb


# CLEAN IMAGE
RUN apt-get -y clean && apt-get -y autoremove


# ENV
# -- shutup installers
ENV DEBIAN_FRONTEND noninteractive


# USER
# -- add the user, expose datastore
RUN useradd -m -s /bin/bash -u ${SRVUID} ${SRVUSER}
# -- temporarily steal ownership
RUN chown -R root: /home/${SRVUSER}


# SCRIPT - installer
COPY _scripts/tribesnext-server-installer ${SRVDIR}
RUN chmod +x ${SRVDIR}/tribesnext-server-installer
RUN ${SRVDIR}/tribesnext-server-installer


# SCRIPT - server
COPY _scripts/start-server /home/${SRVUSER}/start-server
RUN chmod +x /home/${SRVUSER}/start-server


# SCRIPT - custom
COPY _custom/Classic/. /home/${SRVUSER}/.wine/drive_c/Dynamix/Tribes2/GameData/Classic/
COPY _custom/base/. /home/${SRVUSER}/.wine/drive_c/Dynamix/Tribes2/GameData/base/


# PERMISSIONS
RUN chown -R ${SRVUSER}: /home/${SRVUSER}


# PORTS
EXPOSE \
# -- tribes
666/tcp \
28000/udp 

USER ${SRVUSER}
WORKDIR /home/${SRVUSER}

CMD ["./start-server"]

