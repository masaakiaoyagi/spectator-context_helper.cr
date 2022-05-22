#!/bin/sh

cleanup() {
  rm shard.lock
}
trap cleanup EXIT

ln -sf ${WORKSPACE_CONTAINER_DIR}/shard.lock .
$@
