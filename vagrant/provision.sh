#!/usr/bin/env bash

WAGTAIL_ROOT=/vagrant/wagtail
BAKERYDEMO_ROOT=/vagrant/bakerydemo
LIBS_ROOT=/vagrant/libs

VIRTUALENV_DIR=/home/vagrant/.virtualenvs/bakerydemo

PYTHON=$VIRTUALENV_DIR/bin/python
PIP=$VIRTUALENV_DIR/bin/pip

NODEJS_VERSION=22

BASHRC=/home/vagrant/.bashrc

# silence "dpkg-preconfigure: unable to re-open stdin" warnings
export DEBIAN_FRONTEND=noninteractive

# Update APT database
apt-get update -y

# useful tools
apt-get install -y vim git curl gettext build-essential ca-certificates gnupg
# Python 3
apt-get install -y python3 python3-dev python3-pip python3-venv python-is-python3
# PIL dependencies
apt-get install -y libjpeg-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev
# Redis and PostgreSQL
apt-get install -y redis-server postgresql libpq-dev
# libenchant (spellcheck library for docs)
apt-get install -y libenchant-dev

# Create pgsql superuser
PG_USER_EXISTS=$(
    su - postgres -c \
    "psql postgres -tAc \"SELECT 'yes' FROM pg_roles WHERE rolname='vagrant' LIMIT 1\""
)

if [[ "$PG_USER_EXISTS" != "yes" ]];
then
    su - postgres -c "createuser -s vagrant"
fi

pip3 install -U pip
pip install virtualenvwrapper

# Set up virtualenvwrapper in .bashrc
# just put these three values to .bashrc:
BASHRC_LINE_1="export WORKON_HOME=/home/vagrant/.virtualenvs"
BASHRC_LINE_2="export VIRTUALENVWRAPPER_PYTHON=python3"
BASHRC_LINE_VENV="source /usr/local/bin/virtualenvwrapper.sh"
NEEDS_UPDATE_BASHRC_VENV=no

# Prevent duplicate values in .bashrc from repeat provision
# "seq 1 2" is used just in case: if the number of lines will increase
for i in $(seq 1 2);
do
    eval "CURRENT_LINE=\$BASHRC_LINE_$i"
    LINE_EXISTS=$(cat $BASHRC | grep -q "^$CURRENT_LINE" && echo yes || echo no)
    if [[ "$LINE_EXISTS" == "no" ]];
    then
        echo $CURRENT_LINE >> $BASHRC
        NEEDS_UPDATE_BASHRC_VENV=yes
    fi
done

# Prevent a situation when "source" had called before env vars were provided
if [[ "$NEEDS_UPDATE_BASHRC_VENV" == "yes" ]];
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
su - vagrant -c "$PIP install embedly django-sendfile"

# install Node.js (for front-end asset building)
# as per instructions on https://github.com/nodesource/distributions
# prevent the warning "apt-key output should not be parsed"
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODEJS_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs

# set up our local checkouts of django-modelcluster and Willow
su - vagrant -c "cd $LIBS_ROOT/django-modelcluster && $PIP install -e ."
su - vagrant -c "cd $LIBS_ROOT/Willow && $PIP install -e ."

# Install node.js tooling
echo "Installing node.js tooling..."
su - vagrant -c "cd $WAGTAIL_ROOT && npm install --no-save && npm run build"

# run additional migrations in wagtail master
su - vagrant -c "$PYTHON $BAKERYDEMO_ROOT/manage.py migrate --noinput"

echo "Vagrant setup complete. You can now log in with: vagrant ssh"
