FROM multiarch/debian-debootstrap:i386-jessie
MAINTAINER sairuk

# ENVIRONMENT
ARG SRVUSER=gameserv
ARG SRVUID=1000
ARG SRVDIR=/tmp/tribes2/
ENV INSTDIR=/home/${SRVUSER}/.wine/drive_c/Dynamix/Tribes2/

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


# SCRIPT - server (default)
COPY _scripts/start-server ${INSTDIR}/start-server
RUN chmod +x ${INSTDIR}/start-server


# SCRIPT - custom (custom content / overrides)
COPY _custom/. ${INSTDIR}


# PERMISSIONS
RUN chown -R ${SRVUSER}: /home/${SRVUSER}


# PORTS
EXPOSE \
# -- tribes
666/tcp \
28000/udp 

USER ${SRVUSER}
WORKDIR ${INSTDIR}

CMD ["./start-server"]

