#!/bin/bash

# Configuration
GIT_REPO="<github-link>"
BUILD_DIR="build"
S3_BUCKET="<unique-name>"
AWS_REGION="<region-name>"

# Clone the repository
echo "Cloning repository..."
git clone $GIT_REPO
cd react-app

# Install dependencies
echo "Installing dependencies..."
npm install

# Create production build
echo "Creating build..."
npm run build

# Create S3 bucket
echo "Creating S3 bucket..."
aws s3 mb s3://$S3_BUCKET --region $AWS_REGION

# Modify public access block settings
echo "Updating public access block configuration..."
aws s3api put-public-access-block \
	--bucket $S3_BUCKET \
	--public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Configure bucket for static website hosting
echo "Configuring static website hosting..."
aws s3 website s3://$S3_BUCKET --index-document index.html --error-document index.html

# Set bucket policy for public access
echo "Setting bucket policy..."
cat > bucket-policy.json << EOF
{
	"Version": "2012-10-17",
	"Statement": [
    	{
        	"Sid": "PublicReadGetObject",
        	"Effect": "Allow",
        	"Principal": "*",
        	"Action": "s3:GetObject",
        	"Resource": "arn:aws:s3:::$S3_BUCKET/*"
    	}
	]
}
EOF
aws s3api put-bucket-policy --bucket $S3_BUCKET --policy file://bucket-policy.json

# Deploy to S3
echo "Deploying files to S3..."
aws s3 sync $BUILD_DIR/ s3://$S3_BUCKET --delete

# Clean up
echo "Cleaning up..."
rm -rf bucket-policy.json

echo "Deployment complete!"
echo "Access your site at: http://$S3_BUCKET.s3-website.$AWS_REGION.amazonaws.com"
