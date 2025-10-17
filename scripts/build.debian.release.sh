#!/bin/bash
set -xe

# 安装系统依赖
sudo apt update
sudo apt install -y gcc g++ build-essential linux-headers cmake make autoconf automake libtool python3 python3-pip
sudo apt install -y libssl-dev zlib1g-dev librapidjson-dev libpcre2-dev libyaml-cpp-dev libcurl4-openssl-dev pkg-config

# 编译 curl（如果需要特定版本）
git clone https://github.com/curl/curl --depth=1 --branch curl-8_6_0
cd curl
cmake -DCURL_USE_OPENSSL=ON -DHTTP_ONLY=ON -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_USE_LIBSSH2=OFF -DBUILD_CURL_EXE=OFF . > /dev/null
make install -j$(nproc) > /dev/null
cd ..

# 编译 yaml-cpp
git clone https://github.com/jbeder/yaml-cpp --depth=1
cd yaml-cpp
cmake -DCMAKE_BUILD_TYPE=Release -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF . > /dev/null
make install -j$(nproc) > /dev/null
cd ..

# 编译 QuickJS
git clone --no-checkout https://github.com/ftk/quickjspp.git
cd quickjspp
git fetch origin 0c00c48895919fc02da3f191a2da06addeb07f09
git checkout 0c00c48895919fc02da3f191a2da06addeb07f09
cmake -DCMAKE_BUILD_TYPE=Release .
make quickjs -j$(nproc) > /dev/null
sudo install -d /usr/local/lib/quickjs/
sudo install -m644 quickjs/libquickjs.a /usr/local/lib/quickjs/
sudo install -d /usr/local/include/quickjs/
sudo install -m644 quickjs/quickjs.h quickjs/quickjs-libc.h /usr/local/include/quickjs/
sudo install -m644 quickjspp.hpp /usr/local/include/
cd ..

# 编译 LibCron
git clone https://github.com/PerMalmberg/libcron --depth=1
cd libcron
git submodule update --init
cmake -DCMAKE_BUILD_TYPE=Release .
make libcron install -j$(nproc)
cd ..

# 安装 toml11
git clone https://github.com/ToruNiina/toml11 --branch="v4.3.0" --depth=1
cd toml11
cmake -DCMAKE_CXX_STANDARD=11 .
make install -j$(nproc)
cd ..

# 设置 pkg-config 路径
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

# 编译主程序
cmake -DCMAKE_BUILD_TYPE=Release .
make -j$(nproc)
rm subconverter

# 链接最终可执行文件（Debian 版本，使用 OpenSSL 而不是 mbedTLS）
g++ -o base/subconverter $(find CMakeFiles/subconverter.dir/src/ -name "*.o") \
    -static \
    -lpcre2-8 \
    -lyaml-cpp \
    -L/usr/lib/x86_64-linux-gnu \
    -lcurl \
    -lssl \
    -lcrypto \
    -lz \
    -l:quickjs/libquickjs.a \
    -llibcron \
    -lpthread \
    -O3 \
    -s

# 更新规则
python3 -m ensurepip
python3 -m pip install gitpython
python3 scripts/update_rules.py -c scripts/rules_config.conf

# 设置权限
cd base
chmod +rx subconverter
chmod +r ./*
cd ..
mv base subconverter

# 创建发布包
PACKAGE_NAME="subconverter_debian_$(date +%Y%m%d)_$(uname -m)"
tar czf "${PACKAGE_NAME}.tar.gz" subconverter/

echo "Build completed! Package: ${PACKAGE_NAME}.tar.gz"

set +xe