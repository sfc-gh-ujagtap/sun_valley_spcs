-- Complete deployment script for Sun Valley React SPCS Service
-- NOTE: Run ./buildAndUpload.sh FIRST to build and push the Docker image
-- This script assumes the image repository is already set up and image is pushed

-- Create and start the service
SOURCE create_service.sql;

-- Step 3: Wait for service to be ready and show endpoints
SELECT 'Service deployment initiated. Check status with the commands below:' AS MESSAGE;
SELECT 'SELECT SYSTEM$GET_SERVICE_STATUS(''SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE'');' AS CHECK_STATUS_COMMAND;
SELECT 'SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;' AS GET_ENDPOINTS_COMMAND;
