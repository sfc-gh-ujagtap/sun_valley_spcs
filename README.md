# 🏔️ Sun Valley React App

A modern full-stack React TypeScript application for Sun Valley 2025 Contact Management, providing a professional web interface for connecting to Snowflake and managing contact data with real-time updates.

## 📋 Table of Contents

- [🚀 Local Development](#-local-development)
- [☁️ Snowflake SPCS Deployment](#️-snowflake-spcs-deployment)
- [✨ Features](#-features)
- [📊 Database Setup](#-database-setup)
- [🔧 API Reference](#-api-reference)
- [🛠️ Troubleshooting](#️-troubleshooting)

## 🚀 Local Development

### Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Node.js 18+** and npm
- **Snowflake Access** with appropriate permissions
- **Snowflake CLI** (for database setup)
- **Connection Configuration** in `~/.snowsql/config` or environment variables

### Quick Start

#### Option 1: Automated Setup (Recommended)
```bash
# Clone the repository
git clone <repository-url>
cd sun-valley-react

# Install dependencies
npm install

# Start both backend and frontend servers
./start-servers.sh
```

#### Option 2: Manual Setup
```bash
# Install dependencies
npm install

# Terminal 1: Start backend server
node server.js

# Terminal 2: Start frontend server  
npm start
```

The application will be available at [http://localhost:3000](http://localhost:3000).

### Environment Configuration

The application supports flexible configuration through environment variables:

#### Backend Configuration (server.js)
- `HOST`: Server host (default: `localhost`)
- `PORT`: Backend server port (default: `3002`)
- `SNOWFLAKE_ACCOUNT`: Your Snowflake account identifier
- `SNOWFLAKE_USERNAME`: Your Snowflake username
- `SNOWFLAKE_PASSWORD`: Your Snowflake password (or use config file)

#### Frontend Configuration (React app)
- `REACT_APP_API_URL`: Full API base URL (e.g., `http://myserver:3002`)
- `REACT_APP_API_PORT`: API port when constructing dynamic URLs (default: `3002`)

#### Example Configurations
```bash
# Development with custom host
HOST=0.0.0.0 PORT=8080 ./start-servers.sh

# Production build with custom API URL
REACT_APP_API_URL=https://api.mycompany.com npm run build

# Using environment variables for Snowflake connection
SNOWFLAKE_ACCOUNT=your-account \
SNOWFLAKE_USERNAME=your-username \
SNOWFLAKE_PASSWORD=your-password \
npm run server
```

### Snowflake Configuration

Create or update your `~/.snowsql/config` file:

```ini
[connections.default]
accountname = your_account
username = your_username
password = your_password
# OR for private key authentication:
# private_key_path = ~/.ssh/snowflake_key.p8
```

## ☁️ Snowflake SPCS Deployment

Deploy your application as a Snowflake Platform Container Service for production use.

### Prerequisites

- **Snowflake CLI** installed and configured
- **Docker** installed and running
- **Snowflake Account** with SPCS capabilities
- **ACCOUNTADMIN** role or appropriate privileges

### Step-by-Step Deployment

#### 1. Setup Database and Tables

First, set up the required database objects:

```bash
# Navigate to scripts directory
cd scripts

# Run the database setup script
snowsql -f setup_sun_valley_tables.sql

# Validate the setup
snowsql -f validate_setup.sql
```

#### 2. Build and Deploy Container

```bash
# Navigate to snowflake directory
cd snowflake

# Make the build script executable
chmod +x buildAndUpload.sh

# Build and push the Docker image to Snowflake
# This script sets up the image repository, builds the Docker image, and pushes it
./buildAndUpload.sh
```

#### 3. Create SPCS Service

```bash
# Create the service (image repository already set up in step 2)
snowsql -f deploy.sql

# Alternative: Create service directly
# snowsql -f create_service.sql
```

### ⚡ Deployment Options

You have two clean deployment workflows:

#### Option 1: Complete Automation (Recommended)
```bash
./buildAndUpload.sh  # Sets up repo + builds + uploads
snowsql -f deploy.sql  # Creates service
```

#### Option 2: Step-by-Step Control
```bash
snowsql -f setup_image_repo.sql  # Setup repository first
# Build and push manually, then:
snowsql -f create_service.sql  # Create service only
```

**Note**: `buildAndUpload.sh` and `deploy.sql` both handle repository setup, so running both creates redundancy but is safe due to `IF NOT EXISTS` clauses.

#### 4. Monitor Deployment

```bash
# Check service status
snowsql -q "SELECT SYSTEM\$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');"

# Get the service endpoint URL
snowsql -q "SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;"

# View service logs
snowsql -f manage_service.sql
```

### SPCS Service Configuration

The service is deployed with the following configuration:

- **Container Image**: `sun-valley-react:latest`
- **Port**: `3002`
- **Health Check**: `/api/health`
- **Compute Pool**: `SUN_VALLEY_POOL` (CPU_X64_XS)
- **Auto-suspend**: 1 hour of inactivity
- **Public Endpoint**: Yes (accessible via Snowflake-generated URL)

### Managing Your SPCS Service

```bash
# Suspend service (cost optimization)
snowsql -q "ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE SUSPEND;"

# Resume service
snowsql -q "ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE RESUME;"

# View service logs
snowsql -q "CALL SYSTEM\$GET_SERVICE_LOGS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE', 'sun-valley-react', 10);"

# Update service with new image
snowsql -q "ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE FROM SPECIFICATION \$\$$(cat service_spec.yaml)\$\$;"
```

## 📊 Database Setup

The application requires specific database tables and data to function properly. The `scripts/` directory contains all necessary SQL scripts for database setup.

### Available Scripts

| Script | Purpose | Use Case |
|--------|---------|----------|
| `setup_sun_valley_tables.sql` | **Main Setup** - Complete database with 60+ realistic contacts | Production/Demo |
| `minimal_setup.sql` | **Quick Start** - Essential tables with 5 test contacts | Development/Testing |
| `add_more_data.sql` | **Data Expansion** - Adds 30+ additional diverse contacts | Enhanced Demo |
| `validate_setup.sql` | **Validation** - Verifies database setup and data integrity | Troubleshooting |
| `sample_analytics.sql` | **Analytics** - Example queries for insights and reporting | Analytics/Reports |
| `cleanup.sql` | **Cleanup** - Removes all created objects | Reset/Cleanup |

### Quick Database Setup

#### For Development
```bash
cd scripts
snowsql -f minimal_setup.sql
```

#### For Production/Demo
```bash
cd scripts
snowsql -f setup_sun_valley_tables.sql
snowsql -f validate_setup.sql
```

### Database Structure

The application uses the following Snowflake objects:

- **Database**: `SUN_VALLEY`
- **Schema**: `Y2025`
- **Main Table**: `SUNVALLEY_2025LIST_HYBRID`
- **Views**: `SUN_VALLEY_STATUS_SUMMARY`, `SUN_VALLEY_COMPANY_BREAKDOWN`

#### Main Table Schema

| Column | Type | Description |
|--------|------|-------------|
| `ID` | NUMBER (AUTOINCREMENT) | Primary key, auto-generated |
| `NAME` | VARCHAR | Contact's full name |
| `COMPANY` | VARCHAR | Company/organization name |
| `TITLE` | VARCHAR | Job title/position |
| `NEW` | VARCHAR | Additional notes/information |
| `STATUS` | VARCHAR | Contact status (see status values below) |

#### Status Values

- `Confirmed` - Confirmed attendee
- `Pending` - Pending confirmation  
- `Investor meeting` - Scheduled for investor meetings
- `Find at event` - To be contacted at the event
- `n/a` - Not applicable/not attending

## ✨ Features

### 🏔️ **Sun Valley Contact Management**
- **Real-time Status Updates**: Edit contact statuses directly in the data table
- **Advanced Filtering**: Use regex patterns to filter data across all columns
- **Status Summary Dashboard**: View contact distribution by status with interactive metrics
- **Bulk Operations**: Efficiently manage large contact datasets
- **Data Export**: Export filtered data as CSV for external use

### 🔗 **Snowflake Integration**
- **Flexible Authentication**: Supports both password and private key authentication
- **Auto-Configuration**: Uses existing `~/.snowsql/config` connection settings
- **Database Context**: Automatically connects to `sun_valley.y2025` schema
- **Optimized Queries**: Efficient data loading and real-time updates
- **Connection Management**: Robust error handling and reconnection logic

### 🎨 **Modern UI/UX**
- **Material-UI Components**: Professional, accessible interface design
- **Responsive Layout**: Works seamlessly on desktop, tablet, and mobile
- **Real-time Updates**: Live data synchronization without page refreshes
- **Interactive Tables**: Sortable, filterable data grids with inline editing
- **Status Indicators**: Color-coded status badges for quick visual identification

## 📋 Prerequisites

- **Node.js 16+** and npm
- **Snowflake Access** with appropriate permissions
- **Connection Configuration** in `~/.snowsql/config` (uses `default` profile)
- **Database Access** to `sun_valley.y2025` schema

## 🔧 API Reference

The Express backend provides the following REST API endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/connect` | POST | Connect to Snowflake and list databases |
| `/api/sun-valley/tables` | GET | Get Sun Valley schema tables |
| `/api/sun-valley/status-summary` | GET | Get status distribution summary |
| `/api/sun-valley/detailed-data` | GET | Get detailed contact data |
| `/api/sun-valley/update-status` | POST | Update contact status |
| `/api/table-data/:tableName` | GET | Get data from specific table |
| `/api/health` | GET | Health check endpoint for monitoring |

## 🛠️ Troubleshooting

### Local Development Issues

#### Common Connection Problems

**Problem**: Application cannot connect to Snowflake
```bash
# Solution 1: Verify your connection configuration
cat ~/.snowsql/config

# Solution 2: Test connection directly with SnowSQL
snowsql -c default

# Solution 3: Check environment variables
echo $SNOWFLAKE_ACCOUNT
echo $SNOWFLAKE_USERNAME
```

**Problem**: "Port 3002 already in use"
```bash
# Find and kill the process using port 3002
lsof -ti:3002 | xargs kill -9

# Or use a different port
PORT=3003 ./start-servers.sh
```

**Problem**: React app shows "Network Error" when calling API
```bash
# Check if backend is running
curl http://localhost:3002/api/health

# Verify CORS configuration in server.js
# Check REACT_APP_API_URL environment variable
```

#### Database Issues

**Problem**: "Table does not exist" error
```bash
# Run database setup scripts
cd scripts
snowsql -f setup_sun_valley_tables.sql

# Validate setup
snowsql -f validate_setup.sql
```

**Problem**: "Schema not found" error
```bash
# Verify database and schema exist
snowsql -q "SHOW DATABASES LIKE 'SUN_VALLEY';"
snowsql -q "SHOW SCHEMAS IN DATABASE SUN_VALLEY;"
```

### SPCS Deployment Issues

#### Service Deployment Problems

**Problem**: Image build fails
```bash
# Check Docker is running
docker info

# Verify Dockerfile syntax
docker build -t test-image .

# Check build logs
./buildAndUpload.sh 2>&1 | tee build.log
```

**Problem**: Service creation fails
```bash
# Check if you have required privileges
snowsql -q "SHOW GRANTS TO ROLE ACCOUNTADMIN;"

# Verify compute pool exists
snowsql -q "SHOW COMPUTE POOLS;"

# Check service specification
snowsql -q "DESCRIBE SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;"
```

**Problem**: Service health check fails
```bash
# Check service logs
snowsql -q "CALL SYSTEM\$GET_SERVICE_LOGS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE', 'sun-valley-react', 50);"

# Verify health endpoint
# Ensure your app responds at /api/health on port 3002

# Check container status
snowsql -q "SELECT SYSTEM\$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');"
```

#### Service Access Issues

**Problem**: Cannot access service endpoint
```bash
# Get the correct endpoint URL
snowsql -q "SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;"

# Check if service is running
snowsql -q "SELECT SYSTEM\$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');"

# Resume service if suspended
snowsql -q "ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE RESUME;"
```

**Problem**: Service suspended due to inactivity
```bash
# Resume the service
snowsql -q "ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE RESUME;"

# Adjust auto-suspend timeout (optional)
# Edit create_service.sql and redeploy
```

#### Cost Management

**Problem**: Unexpected SPCS costs
```bash
# Suspend service when not in use
snowsql -q "ALTER SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE SUSPEND;"

# Check service status regularly
snowsql -q "SELECT SYSTEM\$GET_SERVICE_STATUS('SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE');"

# Monitor compute pool usage
snowsql -q "SHOW COMPUTE POOLS;"
```

### General Debugging Tips

1. **Check logs first**: Always examine application and service logs
2. **Verify connections**: Test Snowflake connectivity independently
3. **Check permissions**: Ensure proper roles and privileges
4. **Test incrementally**: Start with minimal setup, then add complexity
5. **Monitor resources**: Check CPU, memory, and network usage

### Getting Help

- **Logs Location**: 
  - Local: `snowflake.log` in project root
  - SPCS: Use `SYSTEM$GET_SERVICE_LOGS` function
- **Documentation**: 
  - [Snowflake SPCS Documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
  - [React Documentation](https://reactjs.org/)
- **Community**: Snowflake Community Forum and Stack Overflow

## 📊 Data Management Features

### **Status Management**
- **Real-time Updates**: Changes are immediately reflected in the UI
- **Status Options**: `n/a`, `Confirmed`, `Investor meeting`, `Find at event`, `Pending`
- **Bulk Operations**: Filter and update multiple records efficiently
- **Audit Trail**: All changes are logged for tracking

### **Advanced Filtering**
- **Regex Support**: Use regular expressions for complex pattern matching
- **Multi-column Filtering**: Apply different filters to each column simultaneously
- **Real-time Results**: Filters update the display instantly
- **Filter Persistence**: Filters remain active during status updates

### **Data Export**
- **CSV Export**: Export filtered data for external analysis
- **Custom Formatting**: Maintains data types and formatting
- **Large Dataset Support**: Efficiently handles thousands of records

## 🔒 Security & Best Practices

- **🔐 Secure Authentication**: Credentials never stored in browser storage
- **🛡️ Input Validation**: All user inputs are validated and sanitized
- **⏱️ Connection Management**: Automatic timeout and cleanup of database connections
- **🔄 Error Handling**: Comprehensive error logging and user-friendly error messages
- **🚫 SQL Injection Protection**: Parameterized queries prevent injection attacks

## 🚀 Available Scripts

| Script | Command | Description |
|--------|---------|-------------|
| **Start Development** | `./start-servers.sh` | Starts both backend and frontend with hot reload |
| **Frontend Only** | `npm start` | Runs React app at http://localhost:3000 |
| **Backend Only** | `npm run server` | Runs Express server at http://localhost:3002 |
| **Build Production** | `npm run build` | Creates optimized production build |
| **Run Tests** | `npm test` | Launches test runner |
| **Production Mode** | `npm run production` | Builds and serves production app |

## 📁 Project Architecture

```
ujagtap_sun_valley_spcs/
├── 📄 server.js                    # Express backend with Snowflake integration
├── 📄 Dockerfile                   # Multi-stage Docker build configuration
├── 📄 package.json                 # Dependencies and scripts
├── 📁 src/                         # React frontend source code
│   ├── 📄 App.tsx                  # Main React application
│   ├── 📄 snowflake.ts             # Snowflake API client
│   └── 📄 index.tsx                # React entry point
├── 📁 scripts/                     # Database setup SQL scripts
│   ├── 📄 setup_sun_valley_tables.sql
│   ├── 📄 minimal_setup.sql
│   └── 📄 validate_setup.sql
├── 📁 snowflake/                   # SPCS deployment files
│   ├── 📄 service_spec.yaml        # Service specification
│   ├── 📄 deploy.sql               # Complete deployment script
│   └── 📄 buildAndUpload.sh        # Docker build and push script
└── 📁 public/                      # Static assets
```

## 🔒 Security & Best Practices

- **🔐 Secure Authentication**: Credentials never stored in browser storage
- **🛡️ Input Validation**: All user inputs are validated and sanitized
- **⏱️ Connection Management**: Automatic timeout and cleanup of database connections
- **🔄 Error Handling**: Comprehensive error logging and user-friendly error messages
- **🚫 SQL Injection Protection**: Parameterized queries prevent injection attacks

## 📚 Additional Resources

- **[Snowflake SPCS Documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)**: Complete guide to Snowpark Container Services
- **[React Documentation](https://reactjs.org/)**: Official React documentation
- **[Material-UI Components](https://mui.com/)**: UI component library
- **[Snowflake Node.js SDK](https://docs.snowflake.com/en/user-guide/nodejs-driver)**: Node.js driver documentation
- **[Express.js Guide](https://expressjs.com/)**: Backend framework documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add feature-name'`
5. Push to the branch: `git push origin feature-name`
6. Submit a pull request

---

## 🎯 Quick Deployment Summary

### For Local Development:
```bash
npm install && ./start-servers.sh
```

### For Production SPCS Deployment:
```bash
# Step 1: Setup database
cd scripts && snowsql -f setup_sun_valley_tables.sql

# Step 2: Build and upload image (sets up repo + builds + pushes)
cd ../snowflake && ./buildAndUpload.sh

# Step 3: Create service
snowsql -f deploy.sql
```

**Built with ❤️ for Sun Valley 2025 Contact Management**
