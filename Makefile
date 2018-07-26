export USER_ID := $(shell id -u)
export USER_NAME := $(shell whoami)
export GROUP_ID := $(shell id -g)
export GROUP_NAME := $(shell (groups | cut -f1 -d' '))

build:
	test -n "$(KOPS_USER)" || (echo "KOPS_USER is not defined. Aborting" && exit 1)
	test -n "$(AWS_REGION)" || (echo "AWS_REGION is not defined (ex: eu-west-1). Aborting" && exit 1)
	test -n "$(CLUSTER_NAME)" || (echo "CLUSTER_NAME is not defined (ex: my.kops.cluster.k8s.local). Aborting" && exit 1)

	test -L "run/.aws" || (echo "Directory ~/.aws must be linked on run/.aws (ex: ln -s ~/.aws run/.aws). Aborting" && exit 1)
	test -L "run/.kube" || (echo "Directory ~/.kube must be linked on run/.kube (ex: ln -s ~/.kube run/.kube). Aborting" && exit 1)
	test -L "run/.ssh" || (echo "Directory ~/.ssh must be linked on run/.ssh (ex: ln -s ~/.ssh run/.ssh). Aborting" && exit 1)

	echo "USER_NAME: $(USER_NAME)"
	echo "GROUP_NAME: $(GROUP_NAME)"
	docker image build \
	-t $$DOCKER_REPO/kops-toolbox:1.0 \
	--build-arg USER_ID=$$USER_ID \
	--build-arg USER_NAME=$$USER_NAME \
	--build-arg GROUP_ID=$$GROUP_ID \
	--build-arg GROUP_NAME=$$GROUP_NAME \
	--build-arg KOPS_USER=$$KOPS_USER \
	--build-arg AWS_REGION=$$AWS_REGION \
	--build-arg CLUSTER_NAME=$$CLUSTER_NAME \
	.

run: build
	test -n "$(DOCKER_REPO)" || (echo "DOCKER_REPO is not defined (ex: username). Aborting" && exit 1)

	docker container run --rm -ti \
	--name kops-toolbox-$$$$ \
	-v $$PWD/run/.aws:/home/$$USER_NAME/.aws \
	-v $$PWD/run/.kube:/home/$$USER_NAME/.kube \
	-v $$PWD/run/.ssh:/home/$$USER_NAME/.ssh:ro \
	-v $$PWD/res:/home/$$USER_NAME/res \
	-v $$PWD/bin:/home/$$USER_NAME/bin \
	$$DOCKER_REPO/kops-toolbox:1.0
