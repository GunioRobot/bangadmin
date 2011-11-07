#!/bin/bash
yum groupinstall "development tools" -y
yum install sqlite-devel bzip2-devel readline-devel tcl-devel tk-devel -y
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

