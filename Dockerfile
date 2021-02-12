#FROM innovanon/void-base as builder
#FROM innovanon/void-base-pgo as builder
FROM innovanon/doom-base as builder
USER root

## TODO
#      #shared -Wl,--version-script=openssl.ld -Wl,-Bsymbolic-functions -fPIC      \
COPY ./openssl.ld /tmp/openssl.ld
 #&& apt install libssl1.0                                                        \
RUN sleep 127                                                                    \
 && curl -L --proxy $SOCKS_PROXY --retry 5              -o openssl-1.0.0t.tar.gz \
                  https://www.openssl.org/source/old/1.0.0/openssl-1.0.0t.tar.gz \
 && tar xf                                                 openssl-1.0.0t.tar.gz \
 && rm -v                                                  openssl-1.0.0t.tar.gz \
 && cd                                                     openssl-1.0.0t        \
 && mv -v /tmp/openssl.ld .                                                      \
 && ./config --prefix=/usr/                                                      \
         --openssldir=/usr/openssl                                               \
 && make                                                                         \
 && make install                                                                 \
 && ldconfig                                                                     \
 && cd ..                                                                        \
 && rm -rf                                                 openssl-1.0.0t        \
                                            /usr/local/ssl/man                   \
 \
 && apt update                                                                   \
 && apt install software-properties-common                                       \
 && curl -L --proxy $SOCKS_PROXY --retry 5 http://debian.drdteam.org/drdteam.gpg \
  | apt-key add -                                                                \
 && add-apt-repository 'deb http://debian.drdteam.org/ stable multiverse'        \
 && apt update                                                                   \
 && useradd -ms $(command -v bash) zandronum
COPY --from=innovanon/freedoom /var/games/doom/* $HOME/.config/zandronum/
#COPY --from=innovanon/abaddon  /opt/wads/latest.wad $HOME/.config/zandronum/
COPY --from=innovanon/abaddon:latest  /opt/wads/*       $HOME/.config/zandronum/

FROM scratch as squash
COPY --from=builder / /
RUN chown -R debian-tor:debian-tor /var/lib/tor
SHELL ["/bin/bash", "-l", "-c"]

FROM squash as test
RUN sleep 127                       \
 && tor --verify-config             \
 && apt update

FROM squash as final

