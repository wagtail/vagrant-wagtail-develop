#!/bin/bash

WAGTAIL_ROOT=/home/vagrant/wagtail
WAGTAILDEMO_ROOT=/home/vagrant/wagtaildemo
LIBS_ROOT=/home/vagrant/libs

VIRTUALENV_DIR=/home/vagrant/.virtualenvs/wagtaildemo

PYTHON=$VIRTUALENV_DIR/bin/python
PIP=$VIRTUALENV_DIR/bin/pip

# bring up a vanilla wagtaildemo instance using the current release version of wagtail
$WAGTAILDEMO_ROOT/vagrant/provision.sh

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

# run additional migrations in wagtail master
su - vagrant -c "$PYTHON $WAGTAILDEMO_ROOT/manage.py migrate --noinput"

# Install node.js tooling
echo "Installing node.js tooling..."
su - vagrant -c "cd $WAGTAIL_ROOT && npm install && npm run build"
