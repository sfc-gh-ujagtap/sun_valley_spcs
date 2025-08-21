# Sun Valley React - Snowflake SPCS Deployment

This directory contains all the necessary files to deploy your React application as a Snowflake Platform Container Service (SPCS).

## Files Overview

- **`service_spec.yaml`** - Service specification defining the container configuration
- **`setup_image_repo.sql`** - Creates the database, schema, and image repository
- **`create_service.sql`** - Creates the compute pool and SPCS service
- **`manage_service.sql`** - Service management commands (start, stop, logs, etc.)
- **`deploy.sql`** - Complete deployment script
- **`buildAndUpload.sh`** - Script to build and push Docker image

## Quick Start

1. **Build and push the Docker image:**
   ```bash
   chmod +x buildAndUpload.sh
   ./buildAndUpload.sh
   ```

2. **Deploy the service:**
   ```bash
   snow sql -f deploy.sql
   ```

3. **Check service status:**
   ```bash
   snow sql -q "SELECT SYSTEM\$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');"
   ```

4. **Get the service endpoint URL:**
   ```bash
   snow sql -q "SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;"
   ```

## Step-by-Step Deployment

### 1. Prerequisites
- Snowflake CLI installed and configured
- Docker installed
- Appropriate Snowflake privileges (ACCOUNTADMIN recommended)

### 2. Build and Upload Image
```bash
./buildAndUpload.sh
```

### 3. Create Service
```bash
snow sql -f create_service.sql
```

### 4. Monitor Deployment
The service will take a few minutes to start. Monitor with:
```bash
snow sql -f manage_service.sql
```

## Service Configuration

The service is configured with:
- **Container Name**: `sun-valley-react`
- **Port**: `3002`
- **Health Check**: `/api/health`
- **Compute Pool**: `SUN_VALLEY_POOL` (CPU_X64_XS)
- **Auto-suspend**: 1 hour of inactivity

## Management Commands

All management commands are in `manage_service.sql`:

- **Resume service**: `ALTER SERVICE ... RESUME;`
- **Suspend service**: `ALTER SERVICE ... SUSPEND;`
- **View logs**: `CALL SYSTEM$GET_SERVICE_LOGS(...);`
- **Check status**: `SELECT SYSTEM$GET_SERVICE_STATUS(...);`
- **Update service**: `ALTER SERVICE ... FROM SPECIFICATION ...`

## Cost Optimization

- The compute pool auto-suspends after 1 hour of inactivity
- Use `ALTER SERVICE ... SUSPEND;` to manually suspend when not needed
- Monitor usage with `SELECT SYSTEM$GET_SERVICE_STATUS(...);`

## Troubleshooting

1. **Service not starting**: Check logs with `CALL SYSTEM$GET_SERVICE_LOGS(...);`
2. **Image not found**: Verify image was pushed with `./buildAndUpload.sh`
3. **Health check failing**: Ensure your app responds at `/api/health` on port 3002
4. **Permission issues**: Ensure you have ACCOUNTADMIN role or appropriate privileges

## Architecture

The deployment creates:
- Database: `SPCS_APP_DB`
- Schema: `SPCS_APP_DB.IMAGE_SCHEMA`
- Image Repository: `SPCS_APP_DB.IMAGE_SCHEMA.IMAGE_REPO`
- Compute Pool: `SUN_VALLEY_POOL`
- Service: `SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE`
