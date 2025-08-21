-- Service Management Commands for Sun Valley React SPCS Service

-- Start the service (if it's suspended)
ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE RESUME;

-- Suspend the service (to save costs when not in use)
ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE SUSPEND;

-- Check service status
SELECT SYSTEM$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');

-- View service logs
CALL SYSTEM$GET_SERVICE_LOGS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE', 'sun-valley-react');

-- View service logs with filters (last 100 lines)
CALL SYSTEM$GET_SERVICE_LOGS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE', 'sun-valley-react', 100);

-- Get service endpoints
SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;

-- Describe the service
DESCRIBE SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;

-- List all services
SHOW SERVICES IN SCHEMA SPCS_APP_DB.IMAGE_SCHEMA;

-- Update service with new image (after rebuilding and pushing)
ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE 
FROM SPECIFICATION $$
spec:
  container:
  - name: sun-valley-react
    image: /SPCS_APP_DB/IMAGE_SCHEMA/IMAGE_REPO/sun-valley-react:latest
    env:
      SERVER_PORT: 3002
    readinessProbe:
      port: 3002
      path: /api/health
  endpoint:
  - name: frontend
    port: 3002
    public: true
$$;

-- Drop the service (WARNING: This will permanently delete the service)
-- DROP SERVICE IF EXISTS SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;

-- Drop the compute pool (WARNING: Only do this if no services are using it)
-- DROP COMPUTE POOL IF EXISTS SUN_VALLEY_POOL;
