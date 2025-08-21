// Helper function to get the API base URL
const getApiBaseUrl = (): string => {
  // Check for environment variable first (for build-time configuration)
  const envApiUrl = process.env.REACT_APP_API_URL;
  if (envApiUrl) {
    return envApiUrl;
  }

  // If running in development, use the configured ports
  if (process.env.NODE_ENV === 'development') {
    const host = window.location.hostname;
    const port = process.env.REACT_APP_API_PORT || '3002';
    return `http://${host}:${port}`;
  }

  // In production, assume API is served from the same host with a different port or path
  const host = window.location.hostname;
  const protocol = window.location.protocol;
  
  return `${protocol}//${host}`;
};

export interface ApiResponse {
  success: boolean;
  databases?: string[];
  message?: string;
  error?: string;
}

export interface TableInfo {
  TABLE_NAME: string;
  TABLE_TYPE: string;
  ROW_COUNT: number;
  BYTES: number;
  CREATED: string;
  LAST_ALTERED: string;
  COMMENT: string;
}

export interface TablesResponse {
  success: boolean;
  tables?: TableInfo[];
  message?: string;
  error?: string;
}

export interface ColumnInfo {
  COLUMN_NAME: string;
  DATA_TYPE: string;
  IS_NULLABLE: string;
}

export interface TableDataResponse {
  success: boolean;
  data?: any[];
  columns?: ColumnInfo[];
  tableName?: string;
  message?: string;
  error?: string;
}

export const connectAndListDatabases = async (): Promise<ApiResponse> => {
  try {
    console.log('Connecting to Snowflake using my_conn configuration...');
    
    const response = await fetch(`${getApiBaseUrl()}/api/connect`);
    const data: ApiResponse = await response.json();
    
    if (response.ok && data.success) {
      console.log('✅ Successfully connected to Snowflake!');
      console.log(`📊 Query: SELECT DATABASE_NAME FROM INFORMATION_SCHEMA.DATABASES`);
      console.log(`📋 Found ${data.databases?.length} databases`);
      return data;
    } else {
      console.error('❌ API Error:', data.error);
      return data;
    }
  } catch (error) {
    console.error('❌ Network error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Network error'
    };
  }
};

export const getSunValleyTables = async (): Promise<TablesResponse> => {
  try {
    console.log('Getting Sun Valley tables...');
    
    const response = await fetch(`${getApiBaseUrl()}/api/sun-valley/tables`);
    const data: TablesResponse = await response.json();
    
    if (response.ok && data.success) {
      console.log('✅ Successfully retrieved Sun Valley tables!');
      console.log(`📋 Found ${data.tables?.length} tables`);
      return data;
    } else {
      console.error('❌ API Error:', data.error);
      return data;
    }
  } catch (error) {
    console.error('❌ Network error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Network error'
    };
  }
};

export const getTableData = async (tableName: string, limit: number = 10): Promise<TableDataResponse> => {
  try {
    console.log(`Getting data for table ${tableName}...`);
    
    const response = await fetch(`${getApiBaseUrl()}/api/sun-valley/table/${tableName}?limit=${limit}`);
    const data: TableDataResponse = await response.json();
    
    if (response.ok && data.success) {
      console.log(`✅ Successfully retrieved data for ${tableName}!`);
      console.log(`📋 Found ${data.data?.length} rows and ${data.columns?.length} columns`);
      return data;
    } else {
      console.error('❌ API Error:', data.error);
      return data;
    }
  } catch (error) {
    console.error('❌ Network error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Network error'
    };
  }
};

// Sun Valley specific API functions
export interface StatusSummary {
  STATUS: string;
  UNIQUE_NAMES: number;
}

export interface StatusSummaryResponse {
  success: boolean;
  statusSummary?: StatusSummary[];
  message?: string;
  error?: string;
}

export interface DetailedDataResponse {
  success: boolean;
  data?: any[];
  message?: string;
  error?: string;
}

export interface UpdateStatusResponse {
  success: boolean;
  message?: string;
  error?: string;
}

export const getSunValleyStatusSummary = async (): Promise<StatusSummaryResponse> => {
  try {
    console.log('Getting Sun Valley status summary...');
    
    const response = await fetch(`${getApiBaseUrl()}/api/sun-valley/status-summary`);
    const data: StatusSummaryResponse = await response.json();
    
    if (response.ok && data.success) {
      console.log('✅ Successfully retrieved status summary!');
      console.log(`📊 Found ${data.statusSummary?.length} different statuses`);
      return data;
    } else {
      console.error('❌ API Error:', data.error);
      return data;
    }
  } catch (error) {
    console.error('❌ Network error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Network error'
    };
  }
};

export const getSunValleyDetailedData = async (): Promise<DetailedDataResponse> => {
  try {
    console.log('Getting Sun Valley detailed data...');
    
    const response = await fetch(`${getApiBaseUrl()}/api/sun-valley/detailed-data`);
    const data: DetailedDataResponse = await response.json();
    
    if (response.ok && data.success) {
      console.log('✅ Successfully retrieved detailed data!');
      console.log(`📋 Found ${data.data?.length} records`);
      return data;
    } else {
      console.error('❌ API Error:', data.error);
      return data;
    }
  } catch (error) {
    console.error('❌ Network error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Network error'
    };
  }
};

export const updateSunValleyStatus = async (
  recordId: number, 
  newStatus: string, 
  personName: string
): Promise<UpdateStatusResponse> => {
  try {
    console.log(`Updating status for ${personName} to ${newStatus}...`);
    
    const response = await fetch(`${getApiBaseUrl()}/api/sun-valley/update-status`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        recordId,
        newStatus,
        personName
      })
    });
    
    const data: UpdateStatusResponse = await response.json();
    
    if (response.ok && data.success) {
      console.log(`✅ Successfully updated status for ${personName}!`);
      return data;
    } else {
      console.error('❌ API Error:', data.error);
      return data;
    }
  } catch (error) {
    console.error('❌ Network error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Network error'
    };
  }
};