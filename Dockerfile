FROM innovanon/void-base as builder

RUN sleep 91 \
 && xbps-install -Suy
RUN sleep 91 \
 && xbps-install   -y gettext gettext-devel gettext-libs gperf po4a texinfo zip

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

ENV CHOST=x86_64-linux-musl
ENV CC=$CHOST-gcc
ENV CXX=$CHOST-g++
ENV FC=$CHOST-gfortran
ENV NM=$CC-nm
ENV AR=$CC-ar
ENV RANLIB=$CC-ranlib
ENV STRIP=$CHOST-strip

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

ENV PREFIX=/usr/local
#ENV PREFIX=/opt/cpuminer
ENV CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
ENV CPATH="$PREFIX/incude:$CPATH"
ENV    C_INCLUDE_PATH="$PREFIX/include:$C_INCLUDE_PATH"
ENV OBJC_INCLUDE_PATH="$PREFIX/include:$OBJC_INCLUDE_PATH"

ENV LDFLAGS="-L$PREFIX/lib $LDFLAGS"
ENV    LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
ENV     LD_RUN_PATH="$PREFIX/lib:$LD_RUN_PATH"

ENV PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PKG_CONFIG_LIBDIR"
ENV PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PKG_CONFIG_LIBDIR:$PKG_CONFIG_PATH"

ARG ARCH=native
ENV ARCH="$ARCH"

ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# FDO
ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt  $CFLAGS"
ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt $LDFLAGS"

# Debug
ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"

RUN sleep 91                          \
 && git clone --depth=1 --recursive https://github.com/madler/zlib.git
RUN cd zlib                           \
 && ./configure --prefix=$PREFIX      \
      --const --static --64           \
 && make                              \
 && make install                      \
 && git reset --hard                  \
 && git clean -fdx                    \
 && git clean -fdx                    \
 && cd ..
RUN sleep 91                          \
 && curl --proxy $SOCKS_PROXY -o bzip2.tgz -L             \
  https://sourceforge.net/projects/bzip2/files/latest/download
RUN tar xf bzip2.tgz                  \
 && cd bzip2-*                        \
 && make                              \
 && make install                      \
 && cd ..                             \
 && rm -rf bzip2-*/
RUN sleep 91 \
 && git clone --depth=1 --recursive     \
      https://github.com/xz-mirror/xz.git
RUN cd                           xz     \
 && ./autogen.sh                        \
 && ./configure --prefix=$PREFIX        \
      --disable-shared --enable-static  \
 && make                                \
 && make install                        \
 && git reset --hard                    \
 && git clean -fdx                      \
 && git clean -fdx                      \
 && cd ..
RUN sleep 91                          \
 && git clone --depth=1 --recursive https://github.com/glennrp/libpng.git
RUN cd libpng                         \
 && autoreconf -fi                    \
 && ./configure --prefix=$PREFIX      \
      --enable-static                 \
      --disable-shared                \
 && make                              \
 && make install                      \
 && git reset --hard                  \
 && git clean -fdx                    \
 && git clean -fdx                    \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://github.com/libjpeg-turbo/libjpeg-turbo.git
RUN cd libjpeg-turbo                     \
 && mkdir -v build                       \
 && cd       build                       \
 && cmake -G'Unix Makefiles'             \
      -DCMAKE_BUILD_TYPE=Release         \
      -DCMAKE_C_FLAGS="$CFLAGS"          \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"      \
      -DCMAKE_FIND_ROOT_PATH=$PREFIX     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX     \
      ..                                 \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                              \
 && git clone --depth=1 --recursive       \
      https://github.com/SDL-mirror/SDL.git
RUN cd                            SDL     \
 && ./autogen.sh                          \
 && ./configure                           \
      --disable-shared --enable-static    \
 && make                                  \
 && make install                          \
 && git reset --hard                      \
 && git clean -fdx                        \
 && git clean -fdx                        \
 && cd ..

RUN sleep 91                                 \
 && git clone --depth=1 --recursive          \
      https://github.com/Doom-Utils/deutex.git
RUN cd                            deutex     \ 
 && chmod -v +x bootstrap                    \
 && ./bootstrap                              \
 && ./configure                              \
      --disable-shared --enable-static       \
 && make                                     \
 && make install                             \
 && git reset --hard                         \
 && git clean -fdx                           \
 && git clean -fdx                           \
 && cd ..
RUN sleep 91                                  \
 && git clone --depth=1 --recursive           \
      https://github.com/Doom-Utils/zennode.git
RUN cd                            zennode     \
 && sed -i                                    \
 -e 's/^DOCS=.*/DOCS=/'                       \
 -e '/	install -Dm 644 $(DOCS)/d'            \
 -e '/	for doc in $(DOCS)/d'                 \
 Makefile                                     \
 && make                                      \
 && make install                              \
 && git reset --hard                          \
 && git clean -fdx                            \
 && git clean -fdx                            \
 && cd ..
RUN sleep 91                                  \
 && git clone --depth=1 --recursive           \
      https://github.com/freedoom/freedoom.git
RUN cd                          freedoom      \
 && make                                      \
 && install -v wads /var/games/doom/          \
 && git reset --hard                          \
 && git clean -fdx                            \
 && git clean -fdx                            \
 && cd ..

RUN sleep 91                                  \
 && git clone --depth=1 --recursive           \
      https://github.com/doomtech/zandronum.git
RUN cd                          zandronum     \
 && mkdir -v build                            \
 && cd       build                            \
 && cmake .. -DCMAKE_BUILD_TYPE=Release       \
      -DSDL_LIBRARY=$PREFIX                   \
      -DSDL_INCLUDE_DIR=$PREFIX/include       \
 && make                                      \
 && make install                              \
 && cd ..                                     \
 && git reset --hard                          \
 && git clean -fdx                            \
 && git clean -fdx                            \
 && cd ..

# TODO
# && useradd -ms /bin/bash zandronum

# TODO -nightly ?
COPY --from=innovanon/abaddon /root/oblige/wads/* /var/games/doom/

FROM scratch as squash
COPY --from=builder / /
RUN chown -R tor:tor /var/lib/tor
SHELL ["/bin/bash", "-l", "-c"]

FROM squash as test
RUN sleep 91                        \
 && tor --verify-config             \
 && xbps-install -S

FROM squash as final
WORKDIR /root/
ENTRYPOINT ["/usr/local/bin/zandronum"]
#CMD        ["--batch", "latest.wad"]

