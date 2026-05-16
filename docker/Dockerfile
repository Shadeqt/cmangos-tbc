ARG UBUNTU_VERSION=24.04

############################################################
# Skeleton: shared base for build and runtime stages
############################################################
FROM ubuntu:${UBUNTU_VERSION} AS skeleton

ARG TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -pv \
        /cmangos/build \
        /cmangos/src \
        /cmangos/dist/bin \
        /cmangos/dist/etc \
        /cmangos/dist/etc.ref \
        /cmangos/dist/data \
        /cmangos/dist/logs

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata ca-certificates \
    && ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /cmangos

############################################################
# Build: compile mangosd, realmd, and extractors
############################################################
FROM skeleton AS build

ARG CTYPE="RelWithDebInfo"
ARG CMAKE_EXTRA_OPTIONS=""

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential cmake clang ccache git pkg-config \
        libcurl4-openssl-dev libmysqlclient-dev libssl-dev zlib1g-dev \
        libboost-all-dev \
        default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

COPY CMakeLists.txt /cmangos/src/CMakeLists.txt
COPY cmake          /cmangos/src/cmake
COPY contrib        /cmangos/src/contrib
COPY dep            /cmangos/src/dep
COPY sql            /cmangos/src/sql
COPY src            /cmangos/src/src

ARG CACHEBUST=1

WORKDIR /cmangos/build

RUN --mount=type=cache,target=/ccache,sharing=locked \
    cmake /cmangos/src \
        -DCMAKE_BUILD_TYPE="$CTYPE" \
        -DCMAKE_INSTALL_PREFIX=/cmangos/dist \
        -DBUILD_EXTRACTORS=ON \
        -DBUILD_MODULES=ON \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_C_COMPILER_LAUNCHER=ccache \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
        ${CMAKE_EXTRA_OPTIONS} \
    && cmake --build . --config "$CTYPE" -j$(nproc) \
    && cmake --install . --config "$CTYPE"

############################################################
# Runtime: shared base for all running services
############################################################
FROM skeleton AS runtime

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG DOCKER_USER=cmangos

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcurl4t64 libmysqlclient21 libssl3t64 zlib1g \
        libboost-system1.83.0 libboost-filesystem1.83.0 libboost-thread1.83.0 \
        libboost-program-options1.83.0 libboost-iostreams1.83.0 libboost-regex1.83.0 \
        gettext-base default-mysql-client curl ca-certificates jq \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /cmangos/dist/bin /cmangos/dist/bin
COPY --from=build /cmangos/dist/etc /cmangos/dist/etc.ref

RUN (userdel -r ubuntu 2>/dev/null || true) \
    && (groupdel ubuntu 2>/dev/null || true) \
    && groupadd --gid "$GROUP_ID" "$DOCKER_USER" \
    && useradd -d /cmangos --uid "$USER_ID" --gid "$GROUP_ID" "$DOCKER_USER" \
    && chown -R "$DOCKER_USER:$DOCKER_USER" /cmangos

COPY --chown=$USER_ID:$GROUP_ID --chmod=755 \
    docker/entrypoint.sh /cmangos/entrypoint.sh

ENV PATH="/cmangos/dist/bin:$PATH"

USER $DOCKER_USER

ENTRYPOINT ["/cmangos/entrypoint.sh"]

############################################################
# mangosd: world server
############################################################
FROM runtime AS mangosd
WORKDIR /cmangos/dist
CMD ["mangosd", "-c", "/cmangos/dist/etc/mangosd.conf"]

############################################################
# realmd: auth server
############################################################
FROM runtime AS realmd
WORKDIR /cmangos/dist
CMD ["realmd", "-c", "/cmangos/dist/etc/realmd.conf"]

############################################################
# db-import: one-shot DB bootstrap
############################################################
FROM runtime AS db-import
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends pv pigz unzip \
    && rm -rf /var/lib/apt/lists/*
USER $DOCKER_USER

COPY --chown=$DOCKER_USER:$DOCKER_USER sql /cmangos/sql
COPY --chown=$DOCKER_USER:$DOCKER_USER src/modules /cmangos/modules
COPY --chown=$DOCKER_USER:$DOCKER_USER --chmod=755 \
    docker/db-import.sh /cmangos/db-import.sh

ENTRYPOINT ["/cmangos/db-import.sh"]

############################################################
# extractor: one-shot map/dbc/vmap/mmap generation
############################################################
FROM runtime AS extractor
WORKDIR /client
COPY --chown=$DOCKER_USER:$DOCKER_USER --chmod=755 \
    docker/extractor.sh /cmangos/extractor.sh

ENTRYPOINT ["/cmangos/extractor.sh"]
