vagrant-wagtail-develop
=======================

A script to painlessly set up a Vagrant environment for development of Wagtail.

Features
--------
* An Ubuntu 17.10 (Artful Aardvark) base image
* Checkouts of Wagtail, bakerydemo, django-modelcluster and Willow ready to develop against
* Node.js / npm toolchain for front-end asset building
* Elasticsearch 5 installed (but disabled by default to make the VM less resource-heavy)
* Optional packages installed (PostgreSQL, Embedly, Sphinx...)
* Virtualenv for Python 3.6

Setup
-----

**Requirements:** [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/).

Open a terminal and follow those instructions:

```sh
# 1. Decide where to put the project. We use "~/Development" in our examples.
cd ~/Development
# 2. Clone the vagrant-wagtail-develop repository in a new "wagtail-dev" folder.
git clone git@github.com:wagtail/vagrant-wagtail-develop.git wagtail-dev
# 3. Move inside the new folder.
cd wagtail-dev/
# 4. Run the setup script. This will set up all required dependencies for you.
./setup.sh
```

> Note: On platforms that can't run shell scripts, run the commands from [`setup.sh`](setup.sh) manually instead.

It can take a while (typically 15-20 minutes) to fetch and build all dependencies - you could go for a coffee in the meantime :)

Here is the resulting folder structure:

```sh
.
├── libs          # Supporting libraries to develop Wagtail against.
├── vagrant       # Vagrant-related files.
├── wagtail       # Wagtail repository / codebase.
└── bakerydemo    # Wagtail Bakery project used for development.
```

Once setup is over,

```sh
# 5. ssh into your new Vagrant virtual machine.
vagrant ssh
# 6. Start up the bakerydemo development server.
./manage.py runserver 0.0.0.0:8000
# Success!
```

- Visit your site at http://localhost:8000
- The admin interface is at http://localhost:8000/admin/ - log in with `admin` / `changeme`.

What you can do
---------------

> Note: all of those commands are meant to be used **inside the Vagrant virtual machine**. To get there, go to your local Wagtail (`cd ~/Development/wagtail-dev`) set up and `vagrant up` then `vagrant ssh`.

Start the bakerydemo server:

```sh
./manage.py runserver 0.0.0.0:8000
# Then visit http://localhost:8000 in your browser.
```

Run the tests:

```sh
cd /vagrant/wagtail
# Python tests.
./runtests.py
# Node tests.
npm run test
```

Run the linting:

```sh
cd /vagrant/wagtail
# Python linting.
make lint
# JavaScript linting.
npm run lint
```

Build front-end assets:

```sh
cd /vagrant/wagtail
npm run build
```

Start front-end development tools and file watching:

```sh
cd /vagrant/wagtail
npm run start
```

Build the documentation:

```sh
cd /vagrant/wagtail/docs
make html
```

Getting ready to contribute
---------------------------

Here are other actions you will likely need to do to make your first contribution to the project.

Set up git remotes to Wagtail forks (run these lines outside of the Vagrant VM):

```sh
cd ~/Development/wagtail-dev/wagtail
# Change the default origin remote to point to your fork.
git remote set-url origin git@github.com:<USERNAME>/wagtail.git
# Add wagtail/wagtail as the "upstream" remote.
git remote add upstream git@github.com:wagtail/wagtail.git
# Add springload/wagtail as the "springload" remote.
git remote add springload git@github.com:springload/wagtail.git
# Add gasman/wagtail as the "gasman" remote.
git remote add gasman git@github.com:gasman/wagtail.git
# Pull latest changes from all remotes / forks.
git pull --all
```
