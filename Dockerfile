FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

# upgrade
RUN apt-get update \
        && apt-get dist-upgrade -y \
        && apt-get autoremove -y \
        && rm -rf /var/lib/apt/lists/*

# gosu
ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove ca-certificates wget

# locale
RUN apt-get update \
    && apt-get install -y locales \
    && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres
RUN groupadd -r pgadmin --gid=998 && useradd -r -g pgadmin --uid=998 pgadmin

# libpg
ENV PG_MAJOR 9.6
ENV PG_VERSION 9.6~beta4-1.pgdg16.04+1

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

RUN apt-get update \
	&& apt-get install -y --no-install-recommends postgresql-server-dev-$PG_MAJOR=$PG_VERSION postgresql-client-$PG_MAJOR=$PG_VERSION \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update \
        && apt-get install -y --no-install-recommends ca-certificates wget expect \
        && apt-get install -y python-pip \
        && rm -rf /var/lib/apt/lists/* \
        && wget -O pgadmin4-1.0b3-py2-none-any.whl "https://ftp.postgresql.org/pub/pgadmin3/pgadmin4/v1.0-beta4/pip/pgadmin4-1.0b4-py2-none-any.whl" \
        && pip install pgadmin4-1.0b3-py2-none-any.whl \
        && rm pgadmin4-1.0b3-py2-none-any.whl \
        && ln -sf /home/pgadmin/.pgadmin/config_local.py  /usr/local/lib/python2.7/dist-packages/pgadmin4/config_local.py \
        && sed -i "s/DEFAULT_SERVER = 'localhost'/DEFAULT_SERVER = '0.0.0.0'/" /usr/local/lib/python2.7/dist-packages/pgadmin4/config.py

ENV PGADMIN_USER admin@pgadmin.org
ENV PGADMIN_PASSWORD pgadmin
VOLUME /home/pgadmin/.pgadmin

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5050
CMD ["/usr/bin/python", "/usr/local/lib/python2.7/dist-packages/pgadmin4/pgAdmin4.py"]
