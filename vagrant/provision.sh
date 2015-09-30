#!/bin/bash

WAGTAIL_ROOT=/home/vagrant/wagtail
WAGTAILDEMO_ROOT=/home/vagrant/wagtaildemo
LIBS_ROOT=/home/vagrant/libs

VIRTUALENV_DIR=/home/vagrant/.virtualenvs/wagtaildemo
PY2_VIRTUALENV_DIR=/home/vagrant/.virtualenvs/wagtailpy2

PYTHON=$VIRTUALENV_DIR/bin/python
PYTHON2=$PY2_VIRTUALENV_DIR/bin/python
PIP=$VIRTUALENV_DIR/bin/pip
PY2_PIP=$PY2_VIRTUALENV_DIR/bin/pip

NODE_VERSION=v0.12.3

# bring up a vanilla wagtaildemo instance using the current release version of wagtail
$WAGTAILDEMO_ROOT/vagrant/provision.sh

# install additional dependencies of wagtail master
cd $WAGTAIL_ROOT
$PYTHON setup.py develop

# install developer-specific dependencies
apt-get install -y libenchant-dev
su - vagrant -c "$PIP install -r $WAGTAIL_ROOT/requirements-dev.txt"

# install optional packages (so that the full test suite runs)
su - vagrant -c "$PIP install embedly elasticsearch django-sendfile"

# install Node.js (for front-end asset building)
# as per instructions on https://nodesource.com/blog/nodejs-v012-iojs-and-the-nodesource-linux-repositories
curl -sL https://deb.nodesource.com/setup_0.12 | bash -
apt-get install -y nodejs

su - vagrant -c "cd $WAGTAIL_ROOT && npm install && npm run build"

# set up our local checkouts of django-modelcluster and Willow
cd $LIBS_ROOT/django-modelcluster
$PYTHON setup.py develop
cd $LIBS_ROOT/Willow
$PYTHON setup.py develop

# run additional migrations in wagtail master
su - vagrant -c "$PYTHON $WAGTAILDEMO_ROOT/manage.py migrate --noinput"

# also create a Python 2 environment
su - vagrant -c "/usr/local/bin/virtualenv $PY2_VIRTUALENV_DIR"
cd $WAGTAIL_ROOT
$PYTHON2 setup.py develop
su - vagrant -c "$PY2_PIP install -r $WAGTAIL_ROOT/requirements-dev.txt"
su - vagrant -c "$PY2_PIP install embedly elasticsearch django-sendfile"
cd $LIBS_ROOT/django-modelcluster
$PYTHON2 setup.py develop
cd $LIBS_ROOT/Willow
$PYTHON2 setup.py develop
