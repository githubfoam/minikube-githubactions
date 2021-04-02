MAKEFILE_PATH := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECT_ROOT := $(abspath $(MAKEFILE_PATH)/../)
NAMESPACE = argo
LATEST_ARGO_WF = $(shell bash -c  "argo list -n $(NAMESPACE) --no-headers -o name | head -n1")


# Setup

install_k3d:
	curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v3.0.0 bash

install_kubectl:
	curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
	chmod a+x /usr/local/bin/kubectl

delete_cluster:
	k3d cluster delete test-cluster || echo

create_cluster:
	# Mounts local data directory to /data-fixtures in all nodes (for testing)"
	k3d cluster create \
		--wait \
		--verbose \
		--port 5000:80@loadbalancer \
		--volume $(PROJECT_ROOT)/data:/data-fixtures@all \
		test-cluster

switch_context:
	kubectl config use-context k3d-test-cluster

install_argo:
	curl -sLO https://github.com/argoproj/argo/releases/download/v2.10.0-rc3/argo-linux-amd64
	# Make binary executable
	chmod +x argo-linux-amd64
	# Move binary to path
	mkdir $(HOME)/bin/
	mv ./argo-linux-amd64 $(HOME)/bin/argo

create_namespace:
	kubectl create ns $(NAMESPACE)

setup_argo_controller:
	kubectl apply -n $(NAMESPACE) --wait -f https://raw.githubusercontent.com/argoproj/argo/master/manifests/install.yaml
	# Modify the containerRuntimeExecutor
	kubectl -n $(NAMESPACE) apply --wait -f workflow-controller-configmap.yaml
	kubectl create clusterrolebinding serviceaccounts-cluster-admin \
	  --clusterrole=cluster-admin \
	  --group=system:serviceaccounts
	# Create a custom service account
	kubectl apply -n $(NAMESPACE) --wait -f service-account.yaml
