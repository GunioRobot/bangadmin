#!/bin/bash
# Install Python 2.7.2 alternatively
yum groupinstall "development tools" -y
yum install readline-devel openssl-devel gmp-devel ncurses-devel gdbm-devel zlib-devel expat-devel libGL-devel tk tix gcc-c++ libX11-devel glibc-devel bzip2 tar tcl-devel tk-devel pkgconfig tix-devel bzip2-devel sqlite-devel autoconf db4-devel libffi-devel valgrind-devel -y

mkdir tmp
cd tmp
wget http://python.org/ftp/python/2.7.2/Python-2.7.2.tgz
tar xvfz Python-2.7.2.tgz
cd Python-2.7.2
./configure --prefix=/opt/python2.7 --enable-shared
make
make altinstall
echo "/opt/python2.7/lib" >> /etc/ld.so.conf.d/opt-python2.7.conf
ldconfig
cd ..
cd ..
rm -rf tmp

