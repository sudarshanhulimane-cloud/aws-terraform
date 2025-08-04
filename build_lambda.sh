#!/bin/bash

# Build script for Lambda deployment package
# Usage: ./build_lambda.sh [nodejs|python]

LANGUAGE=${1:-nodejs}
LAMBDA_DIR="lambda"
BUILD_DIR="build"

echo "Building Lambda deployment package for $LANGUAGE..."

# Create build directory
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

if [ "$LANGUAGE" = "nodejs" ]; then
    echo "Building Node.js Lambda package..."
    
    # Copy Lambda function files
    cp $LAMBDA_DIR/index.js $BUILD_DIR/
    cp $LAMBDA_DIR/package.json $BUILD_DIR/
    
    # Install dependencies
    cd $BUILD_DIR
    npm install --production
    cd ..
    
    # Create deployment package
    cd $BUILD_DIR
    zip -r ../lambda_function.zip .
    cd ..
    
    echo "Node.js Lambda package created: lambda_function.zip"
    
elif [ "$LANGUAGE" = "python" ]; then
    echo "Building Python Lambda package..."
    
    # Copy Lambda function files
    cp $LAMBDA_DIR/lambda_function.py $BUILD_DIR/
    cp $LAMBDA_DIR/requirements.txt $BUILD_DIR/
    
    # Install dependencies
    cd $BUILD_DIR
    pip install -r requirements.txt -t .
    cd ..
    
    # Create deployment package
    cd $BUILD_DIR
    zip -r ../lambda_function.zip .
    cd ..
    
    echo "Python Lambda package created: lambda_function.zip"
    
else
    echo "Error: Invalid language specified. Use 'nodejs' or 'python'"
    exit 1
fi

# Clean up build directory
rm -rf $BUILD_DIR

echo "Build completed successfully!"