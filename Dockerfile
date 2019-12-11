FROM lsiobase/nginx:3.10

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache --upgrade \
	curl \
	git \
	grep \
	php7-apcu \
	php7-curl \
	php7-dom \
	php7-gd \
	php7-iconv \
	php7-intl \
	php7-ldap \
	php7-mcrypt \
	php7-mysqli \
	php7-mysqlnd \
	php7-pcntl \
	php7-pdo_mysql \
	php7-pdo_pgsql \
	php7-pgsql \
	php7-posix \
	tar && \
 echo "**** install software ****" && \
 mkdir -p \
	/var/www/html/ && \
	TT_RSS_VERSION=$(git ls-remote https://git.tt-rss.org/fox/tt-rss refs/heads/master \
		| cut -c 1-7) && \
 set -ex && \
 curl -o \
	/tmp/ttrss.tar.gz -L \
	"https://git.tt-rss.org/fox/tt-rss/archive/$TT_RSS_VERSION.tar.gz" && \
 set +ex && \
 tar xf \
 /tmp/ttrss.tar.gz -C \
	/var/www/html/ --strip-components=1 && \
 echo "**** link php7 to php ****" && \
 ln -sf /usr/bin/php7 /usr/bin/php && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
