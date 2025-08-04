#!/bin/bash

# Build script for Lambda function
# This script packages the Lambda function code into a zip file

set -e

echo "Building Lambda function..."

# Check if we're building Node.js or Python version
if [ "$1" = "python" ]; then
    echo "Building Python version..."
    cd lambda
    pip install -r requirements.txt -t .
    zip -r ../lambda_function.zip .
    cd ..
    echo "Python Lambda function packaged as lambda_function.zip"
else
    echo "Building Node.js version..."
    cd lambda
    npm install
    zip -r ../lambda_function.zip .
    cd ..
    echo "Node.js Lambda function packaged as lambda_function.zip"
fi

echo "Build complete!"