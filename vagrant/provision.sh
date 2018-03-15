#!/bin/bash

WAGTAIL_ROOT=/vagrant/wagtail
BAKERYDEMO_ROOT=/vagrant/bakerydemo
LIBS_ROOT=/vagrant/libs

VIRTUALENV_DIR=/home/ubuntu/.virtualenvs/bakerydemo

PYTHON=$VIRTUALENV_DIR/bin/python
PIP=$VIRTUALENV_DIR/bin/pip


# Update APT database
apt-get update -y

# useful tools
apt-get install -y vim git curl gettext build-essential
# Python 3
apt-get install -y python3 python3-dev python3-pip python3-venv
# PIL dependencies
apt-get install -y libjpeg-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev
# Redis and PostgreSQL
apt-get install -y redis-server postgresql libpq-dev
# libenchant (spellcheck library for docs)
apt-get install -y libenchant-dev
# Java for Elasticsearch
apt install -y openjdk-8-jre-headless

# Create pgsql superuser
su - postgres -c "createuser -s ubuntu"

pip3 install -U pip
pip install virtualenvwrapper

# Set up virtualenvwrapper in .bashrc
cat << EOF >> /home/ubuntu/.bashrc
export WORKON_HOME=/home/ubuntu/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=python3
source /usr/local/bin/virtualenvwrapper.sh
EOF


# bring up a PostgreSQL-enabled bakerydemo instance using the current release version of wagtail
PROJECT_DIR=$BAKERYDEMO_ROOT DEV_USER=ubuntu USE_POSTGRESQL=1 $BAKERYDEMO_ROOT/vagrant/provision.sh bakerydemo

# install additional dependencies (including developer-specific ones)
# of wagtail master

su - ubuntu -c "cd $WAGTAIL_ROOT && $PIP install -e .[testing,docs] -U"

# install optional packages (so that the full test suite runs)
su - ubuntu -c "$PIP install embedly \"elasticsearch>=5.0,<6.0\" django-sendfile"

# install Node.js (for front-end asset building)
# as per instructions on https://github.com/nodesource/distributions
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs

# set up our local checkouts of django-modelcluster and Willow
su - ubuntu -c "cd $LIBS_ROOT/django-modelcluster && $PYTHON setup.py develop"
su - ubuntu -c "cd $LIBS_ROOT/Willow && $PYTHON setup.py develop"

# Install node.js tooling
echo "Installing node.js tooling..."
su - ubuntu -c "cd $WAGTAIL_ROOT && npm install && npm run build"

# run additional migrations in wagtail master
su - ubuntu -c "$PYTHON $BAKERYDEMO_ROOT/manage.py migrate --noinput"

# Elasticsearch (disabled by default, as it's a resource hog)
echo "Downloading Elasticsearch..."
wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.3.deb
dpkg -i elasticsearch-5.3.3.deb
rm elasticsearch-5.3.3.deb
# reduce JVM heap size from 2g to 512m
sed -i 's/^\(-Xm[sx]\)2g$/\1512m/g' /etc/elasticsearch/jvm.options
# to enable:
# systemctl enable elasticsearch
# systemctl start elasticsearch

echo "Vagrant setup complete. You can now log in with: vagrant ssh"
