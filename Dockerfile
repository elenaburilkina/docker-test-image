FROM debian:jessie

ENV NODE_VERSION=0.10.40
ENV NPM_VERSION=2.15.1

RUN apt-get update && \
    apt-get -y install ca-certificates curl g++ gcc git libX11-dev libffi-dev libnss3-tools locales make \
    netcat-traditional ruby ruby-dev sudo && \
    curl 'https://dl-ssl.google.com/linux/linux_signing_key.pub' | apt-key add - && \
    echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get -y install google-chrome-unstable postgresql-9.5 postgresql-contrib-9.5 postgresql-server-dev-9.5 && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'fi_FI.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    sed -i 's/md5/trust/' /etc/postgresql/9.5/main/pg_hba.conf && \
    pg_ctlcluster 9.5 main start && \
    sudo -u postgres psql -c 'CREATE USER digabi WITH SUPERUSER;' && \
    pg_ctlcluster 9.5 main stop && \
    adduser --system --uid 1001 digabi && \
    for key in 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D  ; \
    do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key";\
    done && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
    gpg --verify SHASUMS256.txt.asc && \
    grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c -  && \
    tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1  && \
    rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc  && \
    npm install -g npm@"$NPM_VERSION"  && \
    npm cache clear && \
    curl https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | sudo -u digabi bash && \
    sudo -u digabi bash -c '. /home/digabi/.nvm/nvm.sh && nvm install 6.11.1 && nvm install --lts 6.9.1 && nvm install 8.3.0' && \
    gem install fpm
