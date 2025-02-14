FROM alpine:3 AS build

# install dependencies
RUN apk add build-base cmake libpng-dev jpeg-dev mesa-dev sqlite-dev libogg-dev libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev gmp-dev jsoncpp-dev luajit-dev zstd-dev gettext sdl2-dev

# download and extract engine source
RUN wget https://github.com/luanti-org/luanti/archive/master.tar.gz && tar -xf master.tar.gz && mv luanti-master ./luanti && rm master.tar.gz

# build
WORKDIR /luanti
RUN CXX=g++ cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE -DCMAKE_BUILD_TYPE=Release
RUN make -j $(nproc)


FROM alpine:3

# install dependencies
RUN apk add libpng-dev jpeg-dev mesa-dev sqlite-dev libogg-dev libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev gmp-dev jsoncpp-dev luajit-dev zstd-dev gettext sdl2-dev

COPY --from=build /luanti/bin /luanti/bin
COPY --from=build /luanti/builtin /luanti/builtin
COPY --from=build /luanti/lib /luanti/lib
COPY --from=build /luanti/games /luanti/games
COPY --from=build /luanti/mods /luanti/mods
COPY --from=build /luanti/textures /luanti/textures
COPY --from=build /luanti/worlds /luanti/worlds

# make symlinks to the server executable in /usr/local/bin
RUN ln -s /luanti/bin/luantiserver /usr/local/bin/luanti \
    && ln -s /luanti/bin/luantiserver /usr/local/bin/luantiserver
WORKDIR /luanti

EXPOSE 30000
