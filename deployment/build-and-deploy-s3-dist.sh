#!/bin/bash
## Parameter definition block
DIST_OUTPUT_BUCKET="super-leaky-dod-secrets-bucket"
SOLUTION_NAME="compliant-framework-for-federal-and-dod-workloads-in-aws-govcloud-us"
VERSION="1.1.2"
ACCOUNT_ALIAS="dod-dla-te-test-com-central-kernel"

echo "Awsuming into role..."
awsume $ACCOUNT_ALIAS

cd ../source || echo "Invalid path"
echo "Changing permission on test file"
chmod +x ./run-all-tests.sh
echo "Running tests"
./run-all-tests.sh

echo "Doing build"
cd ../deployment || echo "Invalid path"
chmod +x ./build-s3-dist.sh
./build-s3-dist.sh $DIST_OUTPUT_BUCKET $SOLUTION_NAME $VERSION

echo "Uploading to S3..."
aws s3 cp ./global-s3-assets/ s3://$DIST_OUTPUT_BUCKET/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control
aws s3 cp ./regional-s3-assets/ s3://$DIST_OUTPUT_BUCKET/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control


echo "Finished Uploading"

echo "deploying using cloudformation"
aws cloudformation deploy --template ./regional-s3-assets/compliant-framework-govcloud-account-product-v1.0.0.yml \
  --parameter-overrides frameworkNotificationEmail=dla-aws-aliases+test-deploy-notifications@trek10.com \
  loggingAccountEmail=dla-aws-aliases+test-logging-account@trek10.com \
  managementServicesAccountEmail=dla-aws-aliases+test-management-services-account@trek10.com \
  environmentNotificationEmail=dla-aws-aliases+test-env-notifications@trek10.com \
  coreNotificationEmail=dla-aws-aliases+test-core-notifications@trek10.com \
  transitAccountEmail=dla-aws-aliases+test-transit-account@trek10.com
echo "Finished deploying cloudformation template"