#!/usr/bin/env sh

helm init --client-only
helm fetch "stable/kiam" --untar --untardir /tmp --version "2.5.1"
helm template /tmp/kiam > /tmp/kiam.yaml
