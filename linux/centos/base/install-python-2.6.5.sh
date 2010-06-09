#!/bin/bash

# * Copyright (c) 2009, Sudheera Satyanarayana.
# *  All rights reserved.
# *
# * Redistribution and use in source and binary forms, with or without modification,
# * are permitted provided that the following conditions are met:
# *
# *   * Redistributions of source code must retain the above copyright notice,
# *     this list of conditions and the following disclaimer.
# *
# *   * Redistributions in binary form must reproduce the above copyright notice,
# *     this list of conditions and the following disclaimer in the documentation
# *     and/or other materials provided with the distribution.
# *
# *   * Neither the names of Sudheera Satyanarayana nor the names of the project
# *     contributors may be used to endorse or promote products derived from this
# *     software without specific prior written permission.
# *
# * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# * 
# /



# Install Python 2.6.5 on base CentOS 5.4 64 bit system

# Run this script as root

cd
yum update -y
yum install sqlite-devel.x86_64 -y
bzip2-devel readline-devel tcl-devel tk-devel 
yum groupinstall 'Development Tools' -y
yum install openssl-devel* zlib*.x86_64
rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm
mkdir download
cd download/
wget http://python.org/ftp/python/2.6.5/Python-2.6.5.tgz
tar -zxvf Python-2.6.5.tgz
cd Python-2.6.5
./configure --prefix=/opt/python2.6 --enable-shared
make
make altinstall
echo "/opt/python2.6/lib" >> /etc/ld.so.conf.d/opt-python2.6.conf
ldconfig


