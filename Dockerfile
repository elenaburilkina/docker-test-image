FROM debian:jessie

ENV NODE_VERSION=0.10.40
ENV NPM_VERSION=2.15.1

RUN sed -i 's/httpredir.debian.org/192.168.2.49/' /etc/apt/sources.list
RUN apt-get update && apt-get -y install curl ca-certificates sudo locales make ruby ruby-dev libnss3-tools git libffi-dev gcc && rm -rf /var/lib/apt/lists/*
RUN echo 'fi_FI.UTF-8 UTF-8' > /etc/locale.gen
RUN locale-gen
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get -y install postgresql-9.5 postgresql-contrib-9.5 && rm -rf /var/lib/apt/lists/*
RUN sed -i 's/md5/trust/' /etc/postgresql/9.5/main/pg_hba.conf
RUN pg_ctlcluster 9.5 main start && \
  sudo -u postgres psql -c 'CREATE USER digabi WITH SUPERUSER;' && \
  pg_ctlcluster 9.5 main stop
RUN adduser --system --uid 1001 digabi
RUN for key in 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D  ; \
  do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key";\
  done
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
  curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
  gpg --verify SHASUMS256.txt.asc && \
  grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c -  && \
  tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1  && \
  rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc  && \
  npm install -g npm@"$NPM_VERSION"  && \
  npm cache clear
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.30.1/install.sh | sudo -u digabi bash
RUN sudo -u digabi bash -c '. /home/digabi/.nvm/nvm.sh && nvm install 4.4.4 && nvm install 4.2.1 && nvm install 6.2.0'
RUN gem install fpm
