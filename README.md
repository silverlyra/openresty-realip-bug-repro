[![build status](https://img.shields.io/travis/silverlyra/openresty-realip-bug-repro.svg)](https://travis-ci.org/silverlyra/openresty-realip-bug-repro)

This repository investigates an issue with [OpenResty](https://openresty.org/en/) and
[ngx_http_realip_module](http://nginx.org/en/docs/http/ngx_http_realip_module.html).

```sh
./build.sh
./test.sh

export NGINX_V=1.12.1
export OPENRESTY_V=1.11.2.4
./build.sh
./test.sh
```
