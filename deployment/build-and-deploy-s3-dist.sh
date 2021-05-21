#!/bin/bash
echo "cleaning"
rm -rf ./global-s3-assets
rm -rf ./regional-s3-assets

echo "clean"

## Parameter definition block
export STACK_NAME="trek10-dla-deployment"
export DIST_OUTPUT_BUCKET="dod-framework-testing"
export REGION="us-east-1"
export SOLUTION_NAME="compliant-framework-for-federal-and-dod-workloads-in-aws-govcloud-us"
export VERSION="1.1.4"
export ACCOUNT_ALIAS="dod-dla-te-test-com-central-kernel"
export STACK_NAME="trek10-dla-deployment"

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
aws s3 cp ./global-s3-assets/ s3://$DIST_OUTPUT_BUCKET-$REGION/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control
aws s3 cp ./regional-s3-assets/ s3://$DIST_OUTPUT_BUCKET-$REGION/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control


echo "Finished Uploading"

echo "deploying using cloudformation"
aws cloudformation deploy --template ./regional-s3-assets/compliant-framework-govcloud-account-product-v1.0.0.yml \
  --parameter-overrides frameworkNotificationEmail=dla-aws-aliases+test-deploy-notifications@trek10.com \
  --capabilities CAPABILITY_IAM \
  --s3-bucket $DIST_OUTPUT_BUCKET-$REGION \
  --s3-prefix  $STACK_NAME \
  loggingAccountEmail=dla-aws-aliases+test-logging-account@trek10.com \
  managementServicesAccountEmail=dla-aws-aliases+test-management-services-account@trek10.com \
  environmentNotificationEmail=dla-aws-aliases+test-env-notifications@trek10.com \
  coreNotificationEmail=dla-aws-aliases+test-core-notifications@trek10.com \
  transitAccountEmail=dla-aws-aliases+test-transit-account@trek10.com \
  --stack-name=$STACK_NAME

echo "Finished deploying cloudformation template"