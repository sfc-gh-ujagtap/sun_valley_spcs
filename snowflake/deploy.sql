-- Complete deployment script for Sun Valley React SPCS Service
-- Run this script to set up everything from scratch

-- Step 1: Set up the database, schema, and image repository
SOURCE setup_image_repo.sql;

-- Step 2: Create and start the service
SOURCE create_service.sql;

-- Step 3: Wait for service to be ready and show endpoints
SELECT 'Service deployment initiated. Check status with the commands below:' AS MESSAGE;
SELECT 'SELECT SYSTEM$GET_SERVICE_STATUS(''SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE'');' AS CHECK_STATUS_COMMAND;
SELECT 'SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;' AS GET_ENDPOINTS_COMMAND;
