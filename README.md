vagrant-wagtail-develop
=======================

A script to painlessly set up a Vagrant environment for development of Wagtail.

Features
--------
* Checkouts of Wagtail, wagtaildemo, django-modelcluster and Willow ready to develop against
* Node.js / npm toolchain for front-end asset building
* Optional packages installed (PostgreSQL, ElasticSearch, Embedly, Sphinx...)
* Virtualenvs for Python 2 and 3

Setup
-----

Clone this repo, and run:

    ./setup.sh

(On platforms that can't run shell scripts, run the commands from setup.sh manually instead.)

It can take a while (typically 15-20 minutes) to fetch and build all dependencies - you could go for a coffee in the meantime :)

This will build a VM instance ready for you to SSH into:

    vagrant ssh

What you can do
---------------

Start up wagtaildemo:

    ./manage.py runserver 0.0.0.0:8000

and visit http://localhost:8000. The admin interface is at http://localhost:8000/admin/ - log in with admin / changeme

Run tests:

    cd ../wagtail
    ./runtests.py

Build front-end assets:

    cd ../wagtail
    npm run build

(or `npm run watch` to watch the source files for changes)

Build the docs:

    cd ../wagtail/docs
    make html

Switch to Python 2.7:

    source ~/.virtualenvs/wagtailpy2/bin/activate

And back to Python 3:

    source ~/.virtualenvs/wagtaildemo/bin/activate
