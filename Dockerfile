ARG CRYSTAL_VERSION

FROM crystallang/crystal:${CRYSTAL_VERSION}

ARG GROUPNAME=docker
ARG USERNAME=docker
ARG UID
ARG GID
ARG RUNTIME_PACKAGES="git less"
ARG BUILD_PACKAGES="build-essential libreadline-dev"
ARG WORKSPACE_DIR=/workspace
ARG WORKSPACE_CONTAINER_DIR=/workspace-container

RUN set -x \
 && groupadd -g ${GID} ${GROUPNAME} \
 && useradd -u ${UID} -g ${GROUPNAME} -m ${USERNAME}

RUN set -x \
 && apt-get -y update \
 && apt-get -y upgrade \
 && apt-get -y install --no-install-recommends ${RUNTIME_PACKAGES} ${BUILD_PACKAGES}

RUN set -x \
 && mkdir -p ${WORKSPACE_DIR} \
 && chown -R ${UID}:${GID} ${WORKSPACE_DIR}
WORKDIR ${WORKSPACE_DIR}

RUN set -x \
 && mkdir -p ${WORKSPACE_CONTAINER_DIR} \
 && chown -R ${UID}:${GID} ${WORKSPACE_CONTAINER_DIR}

COPY --chown=${UID}:${GID} . .

USER ${UID}

RUN set -x \
 && shards install \
 && mv shard.lock ${WORKSPACE_CONTAINER_DIR}

ENV WORKSPACE_CONTAINER_DIR=${WORKSPACE_CONTAINER_DIR}
ENTRYPOINT ["/workspace/entrypoint.sh"]
