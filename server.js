const express = require('express');
const cors = require('cors');
const snowflake = require('snowflake-sdk');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3002;
const HOST = process.env.HOST || 'localhost';

app.use(cors());
app.use(express.json());

function isRunningInSnowflakeContainer() {
  return fs.existsSync("/snowflake/session/token");
}

function getEnvConnectionOptions() {
  // Check if running inside Snowpark Container Services
  if (isRunningInSnowflakeContainer()) {
    return {
      accessUrl: "https://" + (process.env.SNOWFLAKE_HOST || ''),
      account: process.env.SNOWFLAKE_ACCOUNT || '',
      authenticator: 'OAUTH',
      token: fs.readFileSync('/snowflake/session/token', 'ascii'),
      warehouse: process.env.SNOWFLAKE_WAREHOUSE || 'SUN_VALLEY_WAREHOUSE',
      database: process.env.SNOWFLAKE_DATABASE,
      schema: process.env.SNOWFLAKE_SCHEMA,
      clientSessionKeepAlive: true,
    };
  } else {
    // Running locally - use environment variables for credentials
    return {
      account: process.env.SNOWFLAKE_ACCOUNT || '',
      username: process.env.SNOWFLAKE_USER,
      password: process.env.SNOWFLAKE_PASSWORD,
      warehouse: process.env.SNOWFLAKE_WAREHOUSE || 'SUN_VALLEY_WAREHOUSE',
      database: process.env.SNOWFLAKE_DATABASE,
      schema: process.env.SNOWFLAKE_SCHEMA,
      clientSessionKeepAlive: true,
    };
  }
}

async function connectToSnowflakeFromEnv() {
  const connection = snowflake.createConnection(getEnvConnectionOptions());
  await new Promise((resolve, reject) => {
    connection.connect((err, conn) => {
      if (err) {
        reject(err);
      } else {
        resolve(conn);
      }
    });
  });
  return connection;
}



// Function to read snowsql config (similar to Python version)
function readSnowsqlConfig(configPath = '~/.snowsql/config') {
  const expandedPath = configPath.replace('~', require('os').homedir());
  
  if (!fs.existsSync(expandedPath)) {
    throw new Error(`Config file not found at ${expandedPath}`);
  }
  
  const configContent = fs.readFileSync(expandedPath, 'utf8');
  return parseIniFile(configContent);
}

// Simple INI file parser
function parseIniFile(content) {
  const config = {};
  let currentSection = null;
  
  content.split('\n').forEach(line => {
    line = line.trim();
    if (line.startsWith('[') && line.endsWith(']')) {
      currentSection = line.slice(1, -1);
      config[currentSection] = {};
    } else if (line.includes('=') && currentSection) {
      const [key, value] = line.split('=').map(s => s.trim());
      config[currentSection][key] = value.replace(/['"]/g, ''); // Remove quotes
    }
  });
  
  return config;
}

// Function to load private key (Node.js Snowflake SDK expects PEM string)
function loadPrivateKey(privateKeyPath) {
  try {
    const keyPath = privateKeyPath.replace('~', require('os').homedir());
    
    console.log(`Loading private key from: ${keyPath}`);
    const keyContent = fs.readFileSync(keyPath, 'utf8');
    
    // The Node.js Snowflake SDK expects the private key as a PEM string
    console.log('Successfully loaded private key as PEM string');
    return keyContent;
  } catch (error) {
    console.error('Error loading private key:', error);
    return null;
  }
}

// Connect to Snowflake using my_conn configuration
async function connectToSnowflakeFromConfig(connectionName = 'my_conn') {
  try {
    console.log(`Connecting to Snowflake using ${connectionName}...`);
    
    // Read configuration
    const config = readSnowsqlConfig();
    
    // Try to get connection parameters from the specified connection
    let sectionName = `connections.${connectionName}`;
    if (!config[sectionName]) {
      // Fall back to direct section name
      const availableSections = Object.keys(config).filter(s => !s.startsWith('connections.'));
      if (availableSections.length > 0) {
        sectionName = availableSections[0];
        console.log(`Connection '${connectionName}' not found, using '${sectionName}'`);
      } else {
        throw new Error('No valid connection configuration found');
      }
    }
    
    const section = config[sectionName];
    console.log('Found config section:', sectionName);
    
    // Extract connection parameters
    const account = section.accountname || section.account;
    const username = section.username || section.user;
    const privateKeyPath = section.private_key_path;
    const password = section.password;
    
    if (!account || !username) {
      throw new Error('Missing required connection parameters (account, username)');
    }
    
    if (!privateKeyPath && !password) {
      throw new Error('Missing authentication method (private_key_path or password)');
    }
    
    console.log(`Account: ${account}`);
    console.log(`Username: ${username}`);
    
    // Create connection parameters
    const connectionParams = {
      account: account,
      username: username
    };
    
    // Add authentication method
    if (privateKeyPath) {
      console.log('Using private key authentication');
      const privateKey = loadPrivateKey(privateKeyPath);
      if (!privateKey) {
        throw new Error('Failed to load private key');
      }
      connectionParams.privateKey = privateKey;
      connectionParams.authenticator = 'SNOWFLAKE_JWT';
    } else {
      console.log('Using password authentication');
      connectionParams.password = password;
    }
    
    // Create and connect
    const connection = snowflake.createConnection(connectionParams);
    
    await new Promise((resolve, reject) => {
      connection.connect((err, conn) => {
        if (err) {
          reject(err);
        } else {
          resolve(conn);
        }
      });
    });
    
    console.log('✅ Successfully connected to Snowflake!');
    return connection;
    
  } catch (error) {
    console.error('❌ Error connecting to Snowflake:', error);
    throw error;
  }
}


async function connectToSnowflake(connectionName = 'my_conn') {
  if (isRunningInSnowflakeContainer()) {
    return await connectToSnowflakeFromEnv();
  } else {
    return await connectToSnowflakeFromConfig(connectionName);
  }
}

// Execute SQL query
async function executeQuery(connection, query) {
  return new Promise((resolve, reject) => {
    connection.execute({
      sqlText: query,
      complete: (err, stmt, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows);
        }
      }
    });
  });
}

// API endpoint to connect and list databases
app.get('/api/connect', async (req, res) => {
  try {
    console.log('API: Connecting to Snowflake...');
    const connection = await connectToSnowflake('my_conn');
    
    console.log('API: Listing databases using SELECT query...');
    // Use SELECT from INFORMATION_SCHEMA with fully qualified name
    const query = `
      SELECT DATABASE_NAME 
      FROM SNOWFLAKE.INFORMATION_SCHEMA.DATABASES 
      ORDER BY DATABASE_NAME
    `;
    
    const rows = await executeQuery(connection, query);
    const databases = rows.map(row => row.DATABASE_NAME);
    
    console.log(`API: Found ${databases.length} databases:`, databases);
    
    // Close connection
    connection.destroy();
    
    res.json({
      success: true,
      databases: databases,
      message: `Connected successfully! Found ${databases.length} databases.`
    });
    
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// API endpoint to explore Sun Valley database
app.get('/api/sun-valley/tables', async (req, res) => {
  try {
    console.log('API: Exploring Sun Valley database...');
    const connection = await connectToSnowflake('my_conn');
    
    console.log('API: Listing tables in sun_valley.y2025 schema...');
    const query = `
      SELECT 
        TABLE_NAME,
        TABLE_TYPE,
        ROW_COUNT,
        BYTES,
        CREATED,
        LAST_ALTERED,
        COMMENT
      FROM SUN_VALLEY.INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_SCHEMA = 'Y2025'
      ORDER BY TABLE_NAME
    `;
    
    const rows = await executeQuery(connection, query);
    console.log(`API: Found ${rows.length} tables in sun_valley.y2025`);
    
    // Close connection
    connection.destroy();
    
    res.json({
      success: true,
      tables: rows,
      message: `Found ${rows.length} tables in sun_valley.y2025 schema`
    });
    
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// API endpoint to preview table data
app.get('/api/sun-valley/table/:tableName', async (req, res) => {
  try {
    const tableName = req.params.tableName;
    const limit = req.query.limit || 10;
    
    console.log(`API: Getting preview of table ${tableName}...`);
    const connection = await connectToSnowflake('my_conn');
    
    const query = `SELECT * FROM SUN_VALLEY.Y2025.${tableName} LIMIT ${limit}`;
    const rows = await executeQuery(connection, query);
    
    // Get column information
    const columnQuery = `
      SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
      FROM SUN_VALLEY.INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = 'Y2025' AND TABLE_NAME = '${tableName}'
      ORDER BY ORDINAL_POSITION
    `;
    const columns = await executeQuery(connection, columnQuery);
    
    console.log(`API: Retrieved ${rows.length} rows and ${columns.length} columns for ${tableName}`);
    
    // Close connection
    connection.destroy();
    
    res.json({
      success: true,
      data: rows,
      columns: columns,
      tableName: tableName,
      message: `Retrieved ${rows.length} rows from ${tableName}`
    });
    
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// API endpoint for Sun Valley status summary (like the Streamlit app)
app.get('/api/sun-valley/status-summary', async (req, res) => {
  try {
    console.log('API: Getting Sun Valley status summary...');
    const connection = await connectToSnowflake('my_conn');
    
    const query = `
      SELECT 
        status,
        COUNT(DISTINCT name) as unique_names
      FROM SUN_VALLEY.Y2025.SUNVALLEY_2025LIST_HYBRID
      GROUP BY status
      ORDER BY unique_names DESC
    `;
    
    const rows = await executeQuery(connection, query);
    console.log(`API: Found status summary with ${rows.length} different statuses`);
    
    // Close connection
    connection.destroy();
    
    res.json({
      success: true,
      statusSummary: rows,
      message: `Status analysis complete. Found ${rows.length} different statuses.`
    });
    
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// API endpoint to get detailed data with filtering
app.get('/api/sun-valley/detailed-data', async (req, res) => {
  try {
    console.log('API: Getting detailed Sun Valley data...');
    const connection = await connectToSnowflake('my_conn');
    
    const query = `
      SELECT * FROM SUN_VALLEY.Y2025.SUNVALLEY_2025LIST_HYBRID
      ORDER BY name
    `;
    
    const rows = await executeQuery(connection, query);
    console.log(`API: Retrieved ${rows.length} detailed records`);
    
    // Close connection
    connection.destroy();
    
    res.json({
      success: true,
      data: rows,
      message: `Retrieved ${rows.length} records from SUNVALLEY_2025LIST_HYBRID`
    });
    
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// API endpoint to update status (like the Streamlit app)
app.post('/api/sun-valley/update-status', async (req, res) => {
  try {
    const { recordId, newStatus, personName } = req.body;
    
    console.log(`API: Updating status for ${personName} (ID: ${recordId}) to '${newStatus}'`);
    const connection = await connectToSnowflake('my_conn');
    
    const query = `
      UPDATE SUN_VALLEY.Y2025.SUNVALLEY_2025LIST_HYBRID
      SET STATUS = ?
      WHERE ID = ?
    `;
    
    await new Promise((resolve, reject) => {
      connection.execute({
        sqlText: query,
        binds: [newStatus, recordId],
        complete: (err, stmt, rows) => {
          if (err) {
            reject(err);
          } else {
            resolve(stmt);
          }
        }
      });
    });
    
    console.log(`API: Successfully updated status for ${personName}`);
    
    // Close connection
    connection.destroy();
    
    res.json({
      success: true,
      message: `Successfully updated status for ${personName} to '${newStatus}'`
    });
    
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});


const frontendDistPath = path.join(__dirname, 'build');
console.log(frontendDistPath);
// Serve static files from the React app build directory
app.use(express.static(frontendDistPath));

// Catch all handler: send back React's index.html file for client-side routing
app.get('*', (req, res) => {
   // Don't serve index.html for API routes
   if (req.path.startsWith('/api')) {
     return res.status(404).json({ error: 'API endpoint not found' });
   }
   
   res.sendFile(path.join(frontendDistPath, 'index.html'));
 });

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://${HOST}:${PORT}`);
  console.log(`📡 API available at http://${HOST}:${PORT}/api/connect`);
});