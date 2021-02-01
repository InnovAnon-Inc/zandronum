FROM innovanon/void-base as builder

#RUN for k in $(seq 3) ; do \
#      sleep 91             \
#   && xbps-install -Suy    \
#   || continue             \
#    ; exit 0               \
#   ; done                  \
# && exit 2
#RUN for k in $(seq 3) ; do                                                                   \
#      sleep 91                                                                               \
#   && xbps-install   -y gettext gettext-devel gettext-libs gperf pkg-config po4a texinfo zip \
#   || continue                                                                               \
#    ; exit 0                                                                                 \
#  ; done                                                                                     \
# && exit 2
COPY ./update.sh ./
RUN  ./update.sh

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
 && cd ..                             \
 && ldconfig
RUN sleep 91                          \
 && curl --proxy $SOCKS_PROXY -o bzip2.tgz -L             \
  https://sourceforge.net/projects/bzip2/files/latest/download
RUN tar xf bzip2.tgz                  \
 && cd bzip2-*                        \
 && make                              \
 && make PREFIX=$PREFIX install       \
 && cd ..                             \
 && rm -rf bzip2-*/                   \
 && ldconfig
RUN sleep 91 \
 && git clone --depth=1 --recursive     \
      https://github.com/xz-mirror/xz.git
RUN cd                           xz     \
 && ./autogen.sh                        \
 && ./configure --help                  \
 && ./configure --prefix=$PREFIX        \
      --disable-shared --enable-static  \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                \
 && make install                        \
 && git reset --hard                    \
 && git clean -fdx                      \
 && git clean -fdx                      \
 && cd ..                               \
 && ldconfig
RUN sleep 91                          \
 && git clone --depth=1 --recursive https://github.com/glennrp/libpng.git
# TODO
RUN cd libpng                         \
 && autoreconf -fi                    \
 && ./configure --help                \
 && ./configure --prefix=$PREFIX      \
      --enable-static                 \
      --disable-shared                \
      --with-zlib-prefix=$PREFIX      \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                              \
 && make install                      \
 && git reset --hard                  \
 && git clean -fdx                    \
 && git clean -fdx                    \
 && cd ..                             \
 && ldconfig
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
 && cd ..                                \
 && ldconfig
RUN sleep 91                              \
 && git clone --depth=1 --recursive       \
      https://github.com/SDL-mirror/SDL.git
RUN cd                            SDL     \
 && ./autogen.sh                          \
 && ./configure --help                    \
 && ./configure --prefix=$PREFIX          \
      --disable-shared --enable-static    \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                  \
 && make install                          \
 && git reset --hard                      \
 && git clean -fdx                        \
 && git clean -fdx                        \
 && cd ..                                 \
 && ldconfig

RUN sleep 91                                 \
 && git clone --depth=1 --recursive          \
      https://github.com/Doom-Utils/deutex.git
# TODO
RUN cd                            deutex     \ 
 && chmod -v +x bootstrap                    \
 && ./bootstrap                              \
 && ./configure --help                       \
 && ./configure --prefix=$PREFIX             \
      --disable-shared --enable-static       \
      --disable-man                          \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
        LIBS='-lz -lpng'                     \
 && make                                     \
 && make install                             \
 && git reset --hard                         \
 && git clean -fdx                           \
 && git clean -fdx                           \
 && cd ..                                    \
 && ldconfig
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
 && make PREFIX=$PREFIX install               \
 && git reset --hard                          \
 && git clean -fdx                            \
 && git clean -fdx                            \
 && cd ..                                     \
 && ldconfig
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
 && cmake                                     \
      -DCMAKE_BUILD_TYPE=Release         \
      -DCMAKE_C_FLAGS="$CFLAGS"          \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"      \
      -DCMAKE_FIND_ROOT_PATH=$PREFIX     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX     \
      -DSDL_LIBRARY=$PREFIX                   \
      -DSDL_INCLUDE_DIR=$PREFIX/include       \
      ..                                      \
 && make                                      \
 && make install                              \
 && cd ..                                     \
 && git reset --hard                          \
 && git clean -fdx                            \
 && git clean -fdx                            \
 && cd ..

COPY    ./rainbow_blood.zip ./
RUN unzip        rainbow_blood.zip   \
 && mkdir -v     rainbow_blood       \
 && cd           rainbow_blood       \
 && unzip -o '../rainbow blood.pk3'  \
 && rm -v     ../rainbow_blood.zip   \
             '../rainbow blood.pk3'  \
 && zip -q -Z bzip2 -9               \
         -r /var/games/doom/rainbow_blood.pk3 . \
 && cd      /tmp                     \
 && rm -rf                  ./rainbow_blood

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

