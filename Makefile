build:
	test -n "$(KOPS_USER)" || (echo "KOPS_USER is not defined. Aborting" && exit 1)
	test -n "$(AWS_REGION)" || (echo "AWS_REGION is not defined (ex: eu-west-1). Aborting" && exit 1)
	test -n "$(CLUSTER_NAME)" || (echo "CLUSTER_NAME is not defined (ex: my.kops.cluster.k8s.local). Aborting" && exit 1)
	test -f "run/.aws/credentials" || (echo "Directory ~/.aws must be link on run/.aws (ex: ln -s ~/.aws run/.aws). Aborting" && exit 1)
	docker image build \
	-t clevandowski/kops-toolbox:1.0 \
	--build-arg KOPS_USER=$$KOPS_USER \
	--build-arg AWS_REGION=$$AWS_REGION \
	--build-arg CLUSTER_NAME=$$CLUSTER_NAME \
	.

run: build
	docker container run --rm -ti --name kops-toolbox -v $$PWD/run/.aws:/home/guest/.aws -v $$PWD/run/.kube:/home/guest/.kube clevandowski/kops-toolbox:1.0
