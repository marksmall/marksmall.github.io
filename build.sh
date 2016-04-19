#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage : $0 setup|serve"
    exit
fi

case "$1" in

setup)
    echo "Installing necessary GEMs locally"
    bundle install --path vendor/bundle
    ;;
serve)
    echo  "Starting Development Server"
    bundle exec jekyll serve
    ;;
*)
    echo "Action: $1 is not valid, use setup|serve"
    ;;
esac
