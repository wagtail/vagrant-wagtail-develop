#!/bin/bash

git clone https://github.com/wagtail/bakerydemo.git
git clone https://github.com/wagtail/wagtail.git
mkdir -p libs
git clone https://github.com/wagtail/django-modelcluster.git libs/django-modelcluster
git clone https://github.com/wagtail/Willow.git libs/Willow
vagrant up
