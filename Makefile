build-and-deploy:
	./deployment/build-and-deploy-s3-dist.sh

build:
	./deployment/build-s3-dist.sh

clean:
	rm -rf deployment/global-s3-assets
	rm -rf deployment/regional-s3-assets
	rm -rf .aws-sam

