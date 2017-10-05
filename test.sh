#!/usr/bin/env bash

set -e

readonly BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=versions.sh
source "$BASE/versions.sh"

readonly CASES=("nginx-$NGINX" "openresty-$OPENRESTY")

mkdir -p "$BASE/results"

for c in "${CASES[@]}"; do
    echo "-----------------------------------------"
    echo "Testing $c"
    echo

    cd "$BASE/out/$c"
    [[ -x ./sbin/nginx ]] || cd nginx # openresty is laid out differently

    [[ ! -f logs/access.log ]] || rm logs/access.log

    ./sbin/nginx -c "$BASE/conf/nginx.conf" -p "$(pwd)"
    sleep 1

    curl -fsS http://localhost:6467/ > /dev/null
    curl -fsS -H 'X-Forwarded-For: 99.42.76.203' http://localhost:6467/ > /dev/null
    curl -fsS -H 'X-Forwarded-For: 2604:2000:820a:e300:9c69:243d:c915:e6b3' http://localhost:6467/ > /dev/null

    kill "$(cat logs/nginx.pid)"

    cut -f 2 logs/access.log > "$BASE/results/$c"
    if diff -u "$BASE/expected.txt" "$BASE/results/$c"; then
        echo OK
        echo
    else
        echo
        echo "$c failed; unexpected \$remote_addr for at least one request"
        echo
        echo 'access.log:'
        cat logs/access.log
        exit 1
    fi
done
