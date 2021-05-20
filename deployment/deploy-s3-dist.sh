#!/bin/bash
## Parameter definition block
DIST_OUTPUT_BUCKET="super-leaky-dod-secrets-bucket"
SOLUTION_NAME="compliant-framework-for-federal-and-dod-workloads-in-aws-govcloud-us"
VERSION="1.1.0"


cd ../source || echo "Invalid path"
echo "Changing permission on test file"
chmod +x ./run-all-tests.sh
echo "Running tests"
./run-all-tests.sh


echo "Uploading to S3..."
aws s3 cp ./global-s3-assets/ s3://$DIST_OUTPUT_BUCKET/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control
aws s3 cp ./regional-s3-assets/ s3://$DIST_OUTPUT_BUCKET/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control


echo "Finished Uploading"