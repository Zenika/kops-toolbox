build:
	test -n "$(KOPS_USER)" || (echo "KOPS_USER is not defined. Aborting" && exit 1)
	test -n "$(AWS_REGION)" || (echo "AWS_REGION is not defined (ex: eu-west-1). Aborting" && exit 1)
	docker image build -t clevandowski/kops-toolbox:1.0 --build-arg KOPS_USER=$$KOPS_USER --build-arg AWS_REGION=$$AWS_REGION .

run: build
	docker container run --rm -ti --name kops-toolbox -v $$PWD/run/.aws:/home/guest/.aws clevandowski/kops-toolbox:1.0
