#!/usr/bin/env bash

WAGTAIL_ROOT=/vagrant/wagtail
BAKERYDEMO_ROOT=/vagrant/bakerydemo
LIBS_ROOT=/vagrant/libs

VIRTUALENV_DIR=/home/vagrant/.virtualenvs/bakerydemo

PYTHON=$VIRTUALENV_DIR/bin/python
PIP=$VIRTUALENV_DIR/bin/pip

ELASTICSEARCH_VERSION=5.3.3
ELASTICSEARCH_REPO=https://artifacts.elastic.co/downloads/elasticsearch
ELASTICSEARCH_DEB="elasticsearch-${ELASTICSEARCH_VERSION}.deb"

BASHRC=/home/vagrant/.bashrc

# silence "dpkg-preconfigure: unable to re-open stdin" warnings
export DEBIAN_FRONTEND=noninteractive

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
apt-get install -y openjdk-8-jre-headless

# Create pgsql superuser
su - postgres -c "createuser -s vagrant"

pip3 install -U pip
pip install virtualenvwrapper

# Set up virtualenvwrapper in .bashrc
# just put these three values to .bashrc:
BASHRC_LINE_1="export WORKON_HOME=/home/vagrant/.virtualenvsv"
BASHRC_LINE_2="export VIRTUALENVWRAPPER_PYTHON=python3"
BASHRC_LINE_VENV="source /usr/local/bin/virtualenvwrapper.sh"
IS_NEED_UPDATE_BASHRC_VENV=no

for i in $(seq 1 2);
do
    eval "CURRENT_LINE=\$BASHRC_LINE_$i"
    IS_LINE_EXIST=$(cat $BASHRC | grep -q "^$CURRENT_LINE" && echo yes || echo no)
    if [[ "$IS_LINE_EXIST" == "no" ]];
    then
        echo $CURRENT_LINE >> $BASHRC
        IS_NEED_UPDATE_BASHRC_VENV=yes
    fi
done
# prevent situatuin when "source" had called before env vars were provided
if [[ "$IS_NEED_UPDATE_BASHRC_VENV" == "yes" ]];
then
	cat $BASHRC | grep -v "^$BASHRC_LINE_VENV" > "${BASHRC}.tmp" && mv ${BASHRC}.tmp $BASHRC
	echo $BASHRC_LINE_VENV >> $BASHRC
fi

# bring up a PostgreSQL-enabled bakerydemo instance using the current release version of wagtail
PROJECT_DIR=$BAKERYDEMO_ROOT DEV_USER=vagrant USE_POSTGRESQL=1 $BAKERYDEMO_ROOT/vagrant/provision.sh bakerydemo

# install additional dependencies (including developer-specific ones)
# of wagtail master

su - vagrant -c "cd $WAGTAIL_ROOT && $PIP install -e .[testing,docs] -U"

# install optional packages (so that the full test suite runs)
su - vagrant -c "$PIP install embedly \"elasticsearch>=5.0,<6.0\" django-sendfile"

# install Node.js (for front-end asset building)
# as per instructions on https://github.com/nodesource/distributions
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs

# set up our local checkouts of django-modelcluster and Willow
su - vagrant -c "cd $LIBS_ROOT/django-modelcluster && $PYTHON setup.py develop"
su - vagrant -c "cd $LIBS_ROOT/Willow && $PYTHON setup.py develop"

# Install node.js tooling
echo "Installing node.js tooling..."
su - vagrant -c "cd $WAGTAIL_ROOT && npm install && npm run build"

# run additional migrations in wagtail master
su - vagrant -c "$PYTHON $BAKERYDEMO_ROOT/manage.py migrate --noinput"

# Elasticsearch (disabled by default, as it's a resource hog)
echo "Downloading Elasticsearch..."
download_elasticsearch() {
    wget -q "${ELASTICSEARCH_REPO}/elasticsearch-${ELASTICSEARCH_VERSION}.deb"
}

download_elasticsearch

# A timid attempt to prevent issues with the "connection refused" error, etc...
if [ ! -f $ELASTICSEARCH_DEB ];
then
    # try again to download elasticsearch
    download_elasticsearch
fi

if [ ! -f $ELASTICSEARCH_DEB ];
then
    echo "CAN NOT INSTALL ElasticSearch, CAN NOT DOWNLOAD IT" >&2
else
    dpkg -i $ELASTICSEARCH_DEB
    rm $ELASTICSEARCH_DEB
    # reduce JVM heap size from 2g to 512m
    sed -i 's/^\(-Xm[sx]\)2g$/\1512m/g' /etc/elasticsearch/jvm.options
    # to enable:
    # systemctl enable elasticsearch
    # systemctl start elasticsearch
fi
echo "Vagrant setup complete. You can now log in with: vagrant ssh"
