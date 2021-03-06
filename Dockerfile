ARG ALPINE_VER="3.13"
FROM alpine:${ALPINE_VER} as fetch-stage

############## fetch stage ##############

# install fetch packages
RUN \
	apk add --no-cache \
		bash \
		curl \
		git

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# set workdir
WORKDIR /var/www/html

# fetch version file
RUN \
	set -ex \
	&& curl -o \
	/tmp/version.txt -L \
	"https://raw.githubusercontent.com/sparklyballs/versioning/master/version.txt"

# fetch source code
# hadolint ignore=SC1091
RUN \
	. /tmp/version.txt \
	&& set -ex \
	&& git clone --tags --progress --depth=1 https://git.tt-rss.org/fox/tt-rss /var/www/html \
	&& git checkout -b "$TTRSS_RELEASE" 

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:${ALPINE_VER}

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache --upgrade \
	curl \
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
 echo "**** link php7 to php ****" && \
 ln -sf /usr/bin/php7 /usr/bin/php && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/*

# add artifacts from fetch stage
COPY --from=fetch-stage /var/www/html /var/www/html

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
