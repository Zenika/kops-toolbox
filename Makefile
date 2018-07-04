build:
	docker image build -t clevandowski/kops-cli-tools:1.0 --build-arg KOPS_USER=clevandowski-kops --build-arg AWS_REGION=eu-west-3 .
	#docker image build -t clevandowski/kops-cli-tools:1.0 --build-arg KOPS_USER=clevandowski-test-kops --build-arg AWS_REGION=eu-west-1 .

run: build
	docker container run --rm -ti --name kops-cli-tools -v $$PWD/run/.aws:/home/guest/.aws clevandowski/kops-cli-tools:1.0
