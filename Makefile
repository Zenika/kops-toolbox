export USER_ID := $(shell id -u)
export GROUP_ID := $(shell id -g)

build:
	test -n "$(KOPS_USER)" || (echo "KOPS_USER is not defined. Aborting" && exit 1)
	test -n "$(AWS_REGION)" || (echo "AWS_REGION is not defined (ex: eu-west-1). Aborting" && exit 1)
	test -n "$(CLUSTER_NAME)" || (echo "CLUSTER_NAME is not defined (ex: my.kops.cluster.k8s.local). Aborting" && exit 1)

	test -L "run/.aws" || (echo "Directory ~/.aws must be linked on run/.aws (ex: ln -s ~/.aws run/.aws). Aborting" && exit 1)
	test -L "run/.kube" || (echo "Directory ~/.kube must be linked on run/.kube (ex: ln -s ~/.kube run/.kube). Aborting" && exit 1)
	test -L "run/.ssh" || (echo "Directory ~/.ssh must be linked on run/.ssh (ex: ln -s ~/.ssh run/.ssh). Aborting" && exit 1)

	docker image build \
	-t $$DOCKER_REPO/kops-toolbox:1.0 \
	--build-arg USER_ID=$$USER_ID \
	--build-arg GROUP_ID=$$GROUP_ID \
	--build-arg KOPS_USER=$$KOPS_USER \
	--build-arg AWS_REGION=$$AWS_REGION \
	--build-arg CLUSTER_NAME=$$CLUSTER_NAME \
	.

run: build
	test -n "$(DOCKER_REPO)" || (echo "DOCKER_REPO is not defined (ex: username). Aborting" && exit 1)

	docker container run --rm -ti \
	--name kops-toolbox \
	-v $$PWD/run/.aws:/home/guest/.aws \
	-v $$PWD/run/.kube:/home/guest/.kube \
	-v $$PWD/run/.ssh:/home/guest/.ssh:ro \
	-v $$PWD/res:/home/guest/res \
	$$DOCKER_REPO/kops-toolbox:1.0
