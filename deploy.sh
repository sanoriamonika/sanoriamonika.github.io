#!/bin/bash

# Website Build and Deploy Script
# This script builds your website locally and deploys it to GitHub Pages

set -e  # Exit on any error

# Configuration - Update these paths according to your setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_DIR="$SCRIPT_DIR"  # Current directory (monikaWebsite-src)
PUBLIC_DIR="$SCRIPT_DIR/../06_Website/sanoriamonika.github.io"  # Sibling directory
BUILD_DIR="$SCRIPT_DIR/_site"  # Jekyll builds to _site
GITHUB_REPO="https://github.com/sanoriamonika/sanoriamonika.github.io.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required directories exist
check_directories() {
    print_status "Checking directories..."
    
    if [ ! -d "$PRIVATE_DIR" ]; then
        print_error "Private directory '$PRIVATE_DIR' not found!"
        exit 1
    fi
    
    # Only clone if the directory truly doesn't exist
    # If it exists but is empty, don't re-clone
    if [ ! -d "$PUBLIC_DIR" ]; then
        print_warning "Public directory '$PUBLIC_DIR' not found. Cloning repository..."
        git clone "$GITHUB_REPO" "$PUBLIC_DIR"
    elif [ ! -d "$PUBLIC_DIR/.git" ]; then
        print_warning "Public directory exists but is not a git repository. Initializing..."
        cd "$PUBLIC_DIR"
        git init
        git remote add origin "$GITHUB_REPO"
        cd "$PRIVATE_DIR"
    else
        print_status "Public directory found: $PUBLIC_DIR"
    fi
}

# Build the website
build_website() {
    print_status "Building website..."
    
    cd "$PRIVATE_DIR"
    
    # Check if it's a Jekyll project (look for _config.yml first)
    if [ -f "_config.yml" ] || [ -f "_config.yaml" ]; then
        print_status "Building Jekyll site..."
        
        # Check if bundler is available
        if command -v bundle &> /dev/null; then
            bundle install
            bundle exec jekyll build
        else
            jekyll build
        fi
        BUILD_DIR="$PRIVATE_DIR/_site"
        
        # Debug: Check if _site was created
        print_status "Checking if Jekyll created _site directory..."
        if [ -d "$BUILD_DIR" ]; then
            print_status "_site directory exists with $(ls -1 "$BUILD_DIR" | wc -l) items"
            print_status "BUILD_DIR is set to: $BUILD_DIR"
        else
            print_error "_site directory was not created at: $BUILD_DIR"
            print_status "Looking for alternative output directories..."
            # Check for common alternative output directories
            for alt_dir in "dist" "public" "_build" "build"; do
                if [ -d "$PRIVATE_DIR/$alt_dir" ]; then
                    print_status "Found alternative output directory: $alt_dir"
                    BUILD_DIR="$PRIVATE_DIR/$alt_dir"
                    break
                fi
            done
        fi
        
    # Check if package.json exists (Node.js project)
    elif [ -f "package.json" ]; then
        print_status "Installing dependencies..."
        npm install
        
        print_status "Building project..."
        npm run build
    
    # Check if it's a Python project (e.g., Flask, Django)
    elif [ -f "requirements.txt" ] || [ -f "Pipfile" ]; then
        print_status "Building Python project..."
        # Add your Python build commands here
        # Example for Flask:
        # python build.py
        
    # Check if it's a Hugo project
    elif [ -f "config.toml" ] || [ -f "config.yaml" ] || [ -f "config.yml" ]; then
        print_status "Building Hugo site..."
        hugo
        BUILD_DIR="$PRIVATE_DIR/public"
        
    else
        print_warning "No recognized build system found. Assuming static files..."
        BUILD_DIR="$PRIVATE_DIR"
    fi
    
    cd - > /dev/null
}

# Deploy to GitHub Pages
deploy_to_github() {
    print_status "Deploying to GitHub Pages..."
    
    # Check if build directory exists
    if [ ! -d "$BUILD_DIR" ]; then
        print_error "Build directory '$BUILD_DIR' not found!"
        exit 1
    fi
    
    cd "$PUBLIC_DIR"
    
    # Initialize git if it's not already a repo
    if [ ! -d ".git" ]; then
        print_status "Initializing git repository..."
        git init
        git remote add origin "$GITHUB_REPO"
        
        # Create initial commit if repo is empty
        echo "# sanoriamonika.github.io" > README.md
        git add README.md
        git commit -m "Initial commit"
        
        # Try to push to main, fallback to master
        git branch -M main
        git push -u origin main 2>/dev/null || {
            git branch -M master
            git push -u origin master
        }
    fi
    
    # Pull latest changes (handle empty repo case)
    print_status "Pulling latest changes from remote..."
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || {
        print_warning "Could not pull from remote (possibly empty repository)"
    }
    
    # Clear existing files (except .git and .github)
    print_status "Clearing existing files..."
    find . -maxdepth 1 ! -name '.' ! -name '..' ! -name '.git' ! -name '.github' ! -name 'CNAME' ! -name 'README.md' -exec rm -rf {} + 2>/dev/null || true
    
    # Copy new build files
    print_status "Copying new files..."
    print_status "Source: $BUILD_DIR"
    print_status "Target: $(pwd)"
    
    # Verify source directory exists and has content
    if [ ! -d "$BUILD_DIR" ]; then
        print_error "Source directory $BUILD_DIR does not exist!"
        return 1
    fi
    
    if [ ! "$(ls -A "$BUILD_DIR" 2>/dev/null)" ]; then
        print_error "Source directory $BUILD_DIR is empty!"
        return 1
    fi
    
    print_status "Files in source directory:"
    ls -la "$BUILD_DIR"
    
    # Copy all files from _site, excluding problematic files
    find "$BUILD_DIR" -mindepth 1 -maxdepth 1 ! -name "deploy.sh" ! -name "monikaWebsite-src" ! -name "sanoriamonika.github.io" -exec cp -r {} . \;
    
    print_status "Files copied. Current directory contents:"
    ls -la .
    
    # Add all changes
    git add .
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
        print_warning "No changes to deploy."
        cd - > /dev/null
        return
    fi
    
    # Commit changes
    COMMIT_MSG="Deploy: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    
    # Push to GitHub
    print_status "Pushing to GitHub..."
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    
    cd - > /dev/null
    print_status "Deployment complete!"
}

# Clean up function
cleanup() {
    print_status "Cleaning up..."
    # Add any cleanup tasks here if needed
}

# Main execution
main() {
    print_status "Starting build and deploy process..."
    
    check_directories
    build_website
    deploy_to_github
    cleanup
    
    print_status "Build and deploy completed successfully!"
    print_status "Your website should be available at: https://sanoriamonika.github.io"
}

# Handle script interruption
trap cleanup EXIT

# Run main function
main "$@"
