CREATE WAREHOUSE IF NOT EXISTS SUN_VALLEY_WAREHOUSE
  WAREHOUSE_SIZE = XSMALL
  WAREHOUSE_TYPE = STANDARD
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE;

-- Create compute pool for the service
CREATE COMPUTE POOL IF NOT EXISTS SUN_VALLEY_POOL
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS
  AUTO_RESUME = TRUE
  AUTO_SUSPEND_SECS = 3600;

-- Grant usage on compute pool
GRANT USAGE, MONITOR ON COMPUTE POOL SUN_VALLEY_POOL TO ROLE ACCOUNTADMIN;

-- Drop service if it already exists to ensure clean creation
DROP SERVICE IF EXISTS SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;

-- Create the service using the service spec
CREATE SERVICE IF NOT EXISTS SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE
  IN COMPUTE POOL SUN_VALLEY_POOL
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
  - name: app
    port: 3002
    public: true
$$;

-- Grant privileges on the service
GRANT USAGE ON SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE TO ROLE ACCOUNTADMIN;

-- Show service status
SELECT SYSTEM$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');

-- Show service logs (uncomment to view when needed)
-- CALL SYSTEM$GET_SERVICE_LOGS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE', 'sun-valley-react');

-- Get service endpoint URL (run after service is ready)
SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;
