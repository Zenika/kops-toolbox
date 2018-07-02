build:
	docker image build -t clevandowski/kops-cli-tools:1.0 .

run: build
	docker container run --rm -ti --name kops-cli-tools -v $$PWD/run/.aws:/home/guest/.aws clevandowski/kops-cli-tools:1.0
