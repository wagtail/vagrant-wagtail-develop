#!/bin/bash

git clone https://github.com/torchbox/wagtaildemo.git
git clone https://github.com/torchbox/wagtail.git
mkdir -p libs
git clone https://github.com/torchbox/django-modelcluster.git libs/django-modelcluster
git clone https://github.com/torchbox/Willow.git libs/Willow
vagrant up
