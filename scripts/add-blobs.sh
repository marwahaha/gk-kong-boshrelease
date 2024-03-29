#!/usr/bin/env bash

set -e

function configure() {
    OPENRESTY_VERSION=1.13.6.2
    OPENRESTY_SHA256=946e1958273032db43833982e2cec0766154a9b5cb8e67868944113208ff2942

    LUAROCKS_VERSION=3.0.4
    LUAROCKS_SHA256=1236a307ca5c556c4fed9fdbd35a7e0e80ccf063024becc8c3bf212f37ff0edf

    KONG_VERSION=0.14.1
    KONG_SHA256=945a90568838ffb7ee89e6816576a26aae0e860b5ff0a4c396f4299062eb0001


    NODEJS_VERSION=10.14.1
    NODEJS_SHA256=b97b355f3774adbeb4ffce52e275029e767ba9f317f9eb573175410b6255919f

    KONGA_VERSION=0.13.0
    KONGA_SHA256=b8b9dbef77f393855d284cb5456b0bc972b7ed2a882eca449e2b17ce8df4ecb0
}

function main() {
    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    readonly SCRIPT_DIR
    RELEASE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
    readonly RELEASE_DIR

    configure

    mkdir -p "${RELEASE_DIR}/tmp/blobs"
    pushd "${RELEASE_DIR}/tmp/blobs" > /dev/null

        local blob_file
        set -x

        blob_file="openresty-${OPENRESTY_VERSION}.tar.gz"
        add_blob "openresty" "${blob_file}" "openresty/${blob_file}"

        blob_file="luarocks-${LUAROCKS_VERSION}.tar.gz"
        add_blob "luarocks" "${blob_file}" "luarocks/${blob_file}"

        blob_file="kong-${KONG_VERSION}.tar.gz"
        add_blob "kong" "${blob_file}" "kong/${blob_file}"


        blob_file="node-v${NODEJS_VERSION}.tar.gz"
        add_blob "nodejs" "${blob_file}" "nodejs/${blob_file}"

        blob_file="konga-${KONGA_VERSION}.tar.gz"
        add_blob "konga" "${blob_file}" "konga/${blob_file}"

    popd > /dev/null
}

function add_blob() {
    local blob_name=$1
    local blob_file=$2
    local blob_path=$3

    if [[ ! -f "${blob_file}" ]]; then
        "download_${blob_name}"
    fi
    bosh add-blob --dir="${RELEASE_DIR}" "${blob_file}" "${blob_path}"
}

function download_openresty() {
    curl -fsSL "https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz" \
        -o "openresty-${OPENRESTY_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${OPENRESTY_SHA256}  openresty-${OPENRESTY_VERSION}.tar.gz"
}

function download_luarocks() {
    curl -fsSL "http://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz" \
        -o "luarocks-${LUAROCKS_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${LUAROCKS_SHA256}  luarocks-${LUAROCKS_VERSION}.tar.gz"
}

function download_kong() {
    curl -fsSL "https://github.com/Kong/kong/archive/${KONG_VERSION}.tar.gz" \
        -o "kong-${KONG_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${KONG_SHA256}  kong-${KONG_VERSION}.tar.gz"
}

function download_nodejs() {
    curl -fsSL "https://nodejs.org/download/release/latest-dubnium/node-v${NODEJS_VERSION}.tar.gz" \
        -o "node-v${NODEJS_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${NODEJS_SHA256}  node-v${NODEJS_VERSION}.tar.gz"
}

function download_konga() {
    curl -fsSL "https://github.com/pantsel/konga/archive/${KONGA_VERSION}.tar.gz" \
        -o "konga-${KONGA_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${KONGA_SHA256}  konga-${KONGA_VERSION}.tar.gz"
}

main "$@"
