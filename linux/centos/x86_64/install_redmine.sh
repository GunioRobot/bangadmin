#!/bin/bash

## Script under constrution

#Install Redmine

yum install gcc glibc
wget ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7.tar.gz
tar -zxvf ruby-1.8.7.tar.gz
cd ruby-1.8.7
./configure
make
make install

#yum install ruby rubygems rubygem-rake

gem install rack -v=1.0.1

wget http://rubyforge.org/frs/download.php/71421/redmine-0.9.5.tar.gz
useradd redmine
cp redmine-0.9.5.tar.gz /home/redmine/
su - redmine
tar -zxvf redmine-0.9.5.tar.gz 
cd redmine-0.9.5



##TODO Run these queries
create database redmine character set utf8;
create user 'redmine'@'localhost' identified by 'my_password';
grant all privileges on redmine.* to 'redmine'@'localhost';

cp base.yml.example config/database.yml 
#TODO change values in the config file


RAILS_ENV=production rake config/initializers/session_store.rb







