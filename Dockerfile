FROM ubuntu:20.04

LABEL maintainer="Nazmul Islam <naim.5221@gmail.com>"

ENV NGINX_VERSION 1.19.0
ENV MAXMIND_VERSION 1.6.0
ENV VTS_VERSION 0.1.18
ENV VTS_EXPORTER_VERSION 0.10.3
ENV OPENSSL_VERSION 1.1.1
ENV PCRE_VERSION 8.44
ENV ZLIB_VERSION 1.2.11

RUN mkdir -p /usr/src

RUN groupadd nginx \
	&& adduser --system --no-create-home --disabled-login --disabled-password --group nginx \
	\
	&& apt-get update \
	\
	# Bring in tzdata so users could set the timezones through the environment
	# variables
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y tzdata \
	&& ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
	&& dpkg-reconfigure --frontend noninteractive tzdata \
	&& apt-get install -y \
    gcc \
    curl \
    wget \
    libatomic-ops-dev \
    libxslt1.1 \
    libxslt1-dev \
    build-essential \
    git \
    tree \
    perl \
    libgd3 \
    libgd-dev \
    libgeoip1 \
    libgeoip-dev \
    libxml2 \
    libxml2-dev \
    software-properties-common \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libgeoip-dev \
    libgd-dev \
    google-perftools \
    libgoogle-perftools-dev \
    libperl-dev \
    geoip-bin \
	perl

WORKDIR /usr/src

RUN curl -fSL https://github.com/vozlt/nginx-module-vts/archive/v${VTS_VERSION}.tar.gz  -o nginx-module-vts-${VTS_VERSION}.tar.gz \
    && curl -fSL https://github.com/hnlq715/nginx-vts-exporter/releases/download/v${VTS_EXPORTER_VERSION}/nginx-vts-exporter-${VTS_EXPORTER_VERSION}.linux-amd64.tar.gz  -o nginx-vts-exporter-${VTS_EXPORTER_VERSION}.linux-amd64.tar.gz \
    && tar -zxC /usr/src -f nginx-module-vts-${VTS_VERSION}.tar.gz \
    && tar -zxC /usr/src -f nginx-vts-exporter-${VTS_EXPORTER_VERSION}.linux-amd64.tar.gz \
    && rm nginx-module-vts-${VTS_VERSION}.tar.gz nginx-vts-exporter-${VTS_EXPORTER_VERSION}.linux-amd64.tar.gz \
    && cp /usr/src/nginx-vts-exporter-${VTS_EXPORTER_VERSION}.linux-amd64/nginx-vts-exporter /usr/bin/nginx-vts-exporter

RUN wget https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz \
    && tar -zxf pcre-${PCRE_VERSION}.tar.gz \
	&& cd pcre-${PCRE_VERSION} \
	&& ./configure \
    && make \
	&& make install \
	&& cd .. \
	&& rm pcre-${PCRE_VERSION}.tar.gz 

RUN wget https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz \
	&& tar -zxf zlib-${ZLIB_VERSION}.tar.gz \
	&& cd zlib-${ZLIB_VERSION} \
	&& ./configure \
    && make \
	&& make install \
	&& cd .. \
	&& rm zlib-${ZLIB_VERSION}.tar.gz 

RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}g.tar.gz \
	&& tar -zxf openssl-${OPENSSL_VERSION}g.tar.gz \
	&& cd openssl-${OPENSSL_VERSION}g \
	&& ./Configure linux-x86_64 --prefix=/usr \
    && make \
	&& make install \
	&& cd .. \
	&& rm openssl-${OPENSSL_VERSION}g.tar.gz 

RUN wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
  && tar -zxC /usr/src -f nginx-$NGINX_VERSION.tar.gz \
  && rm nginx-$NGINX_VERSION.tar.gz 

COPY nginx_upstream_check_module /usr/src/nginx_upstream_check_module

WORKDIR /usr/src/nginx-$NGINX_VERSION 

RUN CONFIG=" \
    --prefix=/etc/nginx \
    --user=nginx \
    --group=nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-select_module \
    --with-poll_module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module \
    --with-http_geoip_module=dynamic \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_perl_module \
    --with-http_perl_module=dynamic \
    --with-mail \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_geoip_module=dynamic \
    --with-stream_ssl_preread_module \
    --with-google_perftools_module \
    --with-cpp_test_module \
    --with-compat \
    --with-pcre \
    --with-pcre-jit \
    --with-zlib-asm=CPU \
    --with-libatomic \
    --with-http_geoip_module=dynamic \
    --with-stream_geoip_module=dynamic \
    --with-pcre=/usr/src/pcre-${PCRE_VERSION} \
    --with-pcre-jit \
    --with-zlib=/usr/src/zlib-${ZLIB_VERSION} \
    --with-openssl=/usr/src/openssl-${OPENSSL_VERSION}g \
    --with-perl_modules_path=/usr/share/perl/5.26.1 \
    --add-module=/usr/src/nginx-module-vts-$VTS_VERSION \
    --add-module=/usr/src/nginx_upstream_check_module \
    --with-debug \
    --with-ld-opt='-Wl,-E' \
    " \
    && ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
    && git apply /usr/src/nginx_upstream_check_module/check_1.16.1+.patch \
    && ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
    && make install

WORKDIR /

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/cache/nginx/ && chown nginx:nginx /var/cache/nginx

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

