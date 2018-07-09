#!/usr/bin/env bash
set -e

base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $# -ne 1 ]]; then
    echo "You must set a version number"
    echo "./deploy.sh <ubuntu_ruby version>"
    exit 1
fi

version=$1
dockerfile_version=$(grep 'ENV RUBY_VERSION' ${base}/Dockerfile | cut -d' ' -f3)

if [[ $version != $dockerfile_version ]]; then
    echo "Version mismatch in 'Dockerfile'"
    echo "found ${dockerfile_version}, expected ${version}."
    echo "Make sure the versions are correct."
    exit 1
fi

echo "Building docker images for ubuntu_ruby ${version}..."
docker build -f "${base}/Dockerfile" -t ssplatt/ubuntu_ruby:${version} .
docker build -f "${base}/node/Dockerfile" -t ssplatt/ubuntu_ruby:${version}-node .
docker build -f "${base}/browsers/Dockerfile" -t ssplatt/ubuntu_ruby:${version}-browsers .
docker build -f "${base}/node-browsers/Dockerfile" -t ssplatt/ubuntu_ruby:${version}-node-browsers .
docker tag ssplatt/ubuntu_ruby:${version} ssplatt/ubuntu_ruby:latest

echo "Uploading docker images for ubuntu_ruby ${version}..."
docker push ssplatt/ubuntu_ruby:${version}
docker push ssplatt/ubuntu_ruby:latest
docker push ssplatt/ubuntu_ruby:${version}-node
docker push ssplatt/ubuntu_ruby:${version}-browsers
docker push ssplatt/ubuntu_ruby:${version}-node-browsers
