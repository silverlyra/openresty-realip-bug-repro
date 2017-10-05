#!/usr/bin/env bash

set -e

fetch() {
    local package="$1"
    local version="$2"
    local base_url="$3"

    local product="$package-$version"
    local tarball="$product.tar.gz"

    [[ -f "$BASE/tmp/$tarball" ]] || \
        (cd "$BASE/tmp" && echo "Fetching $package" && curl -fsSL -O "$base_url/$tarball")
    [[ -d "$BASE/tmp/$product" ]] || \
        (cd "$BASE/tmp" && tar -xzf "$tarball")
}

build() {
    local package="$1"
    local version="$2"

    local product="$package-$version"

    rm -fr "$BASE/out/$product"

    cd "$BASE/tmp/$product"

    echo
    echo "-----------------------------------------"
    echo "Building $product"
    echo "-----------------------------------------"
    echo

    ./configure \
        --prefix="$BASE/out/$product" \
        --with-http_realip_module \
        --with-pcre="$BASE/tmp/pcre-$PCRE_V" \
        --with-openssl="$BASE/tmp/openssl-$OPENSSL_V"
    make -j"$(getconf _NPROCESSORS_ONLN)"
    make install
}

readonly BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=versions.sh
source "$BASE/versions.sh"

mkdir -p "$BASE/tmp" "$BASE/out"

fetch pcre "$PCRE_V" https://ftp.pcre.org/pub/pcre
fetch openssl "$OPENSSL_V" https://www.openssl.org/source
fetch nginx "$NGINX_V" https://nginx.org/download
fetch openresty "$OPENRESTY_V" https://openresty.org/download

build nginx "$NGINX_V"
build openresty "$OPENRESTY_V"
