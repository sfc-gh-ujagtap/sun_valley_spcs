#!/bin/bash

echo "🚀 Building and deploying Sun Valley React to Snowflake SPCS..."

# Set up image repository
echo "📦 Setting up image repository..."
snow sql -f setup_image_repo.sql

# Build the Docker image
echo "🏗️  Building Docker image..."
cd ..
docker build --rm --platform linux/amd64 -t sun-valley-react:latest .   
cd snowflake

# Get the repository URL
echo "🔗 Getting repository URL..."
REPO_URL=$(snow spcs image-repository url SPCS_APP_DB.IMAGE_SCHEMA.IMAGE_REPO)

if [[ "$REPO_URL" == *"New version of Snowflake CLI available"* ]]; then
  echo "❌ Error: Please update Snowflake CLI."
  exit 1
fi

# Tag and push the image
echo "📤 Pushing image to Snowflake repository..."
docker tag "sun-valley-react:latest" "$REPO_URL/sun-valley-react:latest"    
snow spcs image-registry login  
docker push "$REPO_URL/sun-valley-react:latest"

echo "✅ Image pushed successfully!"
echo ""
echo "Next steps:"
echo "1. Run: snow sql -f create_service.sql"
echo "2. Check service status: snow sql -q \"SELECT SYSTEM\$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');\""
echo "3. Get endpoints: snow sql -q \"SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;\""
echo ""
echo "Or run the complete deployment: snow sql -f deploy.sql" 