build-and-deploy:
	cd deployment
	./build-and-deploy-s3-dist.sh

build:
	./deployment/build-s3-dist.sh
verify:
	cfn-lint source/repositories/**/*.yaml
	cfn-lint source/lib/account-vending-machine/templates/*.yml --debug
clean:
	rm -rf deployment/global-s3-assets
	rm -rf deployment/regional-s3-assets
	rm -rf .aws-sam

