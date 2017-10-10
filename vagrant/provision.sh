#!/bin/bash

WAGTAIL_ROOT=/vagrant/wagtail
BAKERYDEMO_ROOT=/vagrant/bakerydemo
LIBS_ROOT=/vagrant/libs

VIRTUALENV_DIR=/home/vagrant/.virtualenvs/bakerydemo

PYTHON=$VIRTUALENV_DIR/bin/python
PIP=$VIRTUALENV_DIR/bin/pip

# bring up a vanilla bakerydemo instance using the current release version of wagtail
PROJECT_DIR=$BAKERYDEMO_ROOT $BAKERYDEMO_ROOT/vagrant/provision.sh bakerydemo

# install system-wide developer dependencies
apt-get update
apt-get install -y libenchant-dev ruby2.0
gem2.0 install scss_lint

#Update pip
su - vagrant -c "$PIP install -U pip"

# install additional dependencies (including developer-specific ones)
# of wagtail master

su - vagrant -c "cd $WAGTAIL_ROOT && $PIP install -e .[testing,docs] -U"

# install optional packages (so that the full test suite runs)
su - vagrant -c "$PIP install embedly elasticsearch django-sendfile"

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
