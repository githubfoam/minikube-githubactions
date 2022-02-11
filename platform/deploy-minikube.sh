#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://www.digitalocean.com/community/tutorials/webinar-series-kubernetes-package-management-with-helm-and-ci-cd-with-jenkins-x
echo "=============================Install minikube started ============================================================="
sudo apt-get update -y
#make sure that your system’s package manager can access packages over HTTPS with apt-transport-https
sudo apt-get install -y apt-transport-https
# in order to ensure the kubectl download is valid, add the GPG key for the official Google repository
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

