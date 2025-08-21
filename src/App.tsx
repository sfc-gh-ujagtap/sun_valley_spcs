import React, { useState, useEffect } from 'react';
import './App.css';
import { 
  connectAndListDatabases, 
  getSunValleyTables, 
  getTableData,
  getSunValleyStatusSummary,
  getSunValleyDetailedData,
  updateSunValleyStatus,
  TableInfo,
  ColumnInfo,
  StatusSummary
} from './snowflake';

function App() {
  const [databases, setDatabases] = useState<string[]>([]);
  const [tables, setTables] = useState<TableInfo[]>([]);
  const [selectedTable, setSelectedTable] = useState<string>('');
  const [tableData, setTableData] = useState<any[]>([]);
  const [tableColumns, setTableColumns] = useState<ColumnInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingTables, setLoadingTables] = useState(false);
  const [loadingData, setLoadingData] = useState(false);
  const [error, setError] = useState<string>('');
  const [message, setMessage] = useState<string>('');
  const [currentView, setCurrentView] = useState<'databases' | 'tables' | 'data' | 'sunvalley'>('databases');
  const [debugExpanded, setDebugExpanded] = useState(false);
  
  // Sun Valley specific state
  const [statusSummary, setStatusSummary] = useState<StatusSummary[]>([]);
  const [sunValleyData, setSunValleyData] = useState<any[]>([]);
  const [filteredData, setFilteredData] = useState<any[]>([]);
  const [statusFilters, setStatusFilters] = useState<string[]>([]);
  const [regexFilters, setRegexFilters] = useState<{ [key: string]: string }>({});
  const [uniqueStatuses, setUniqueStatuses] = useState<string[]>([]);
  const [loadingSunValley, setLoadingSunValley] = useState(false);
  const [updatingStatus, setUpdatingStatus] = useState<number | null>(null);

  const handleConnect = async () => {
    setLoading(true);
    setError('');
    setMessage('');
    
    try {
      const result = await connectAndListDatabases();
      
      if (result.success && result.databases) {
        setDatabases(result.databases);
        setMessage(result.message || 'Connected successfully!');
        setCurrentView('databases');
      } else {
        setError(result.error || 'Failed to connect to Snowflake');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const handleExploreSunValley = async () => {
    setLoadingTables(true);
    setError('');
    
    try {
      const result = await getSunValleyTables();
      
      if (result.success && result.tables) {
        setTables(result.tables);
        setCurrentView('tables');
      } else {
        setError(result.error || 'Failed to get Sun Valley tables');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoadingTables(false);
    }
  };

  const handleViewTableData = async (tableName: string) => {
    setLoadingData(true);
    setSelectedTable(tableName);
    setError('');
    
    try {
      const result = await getTableData(tableName, 20);
      
      if (result.success && result.data && result.columns) {
        setTableData(result.data);
        setTableColumns(result.columns);
        setCurrentView('data');
      } else {
        setError(result.error || 'Failed to get table data');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoadingData(false);
    }
  };

  const handleLoadSunValleyApp = async () => {
    setLoadingSunValley(true);
    setError('');
    
    try {
      // Load status summary
      const statusResult = await getSunValleyStatusSummary();
      if (statusResult.success && statusResult.statusSummary) {
        setStatusSummary(statusResult.statusSummary);
      }
      
      // Load detailed data
      const dataResult = await getSunValleyDetailedData();
      if (dataResult.success && dataResult.data) {
        setSunValleyData(dataResult.data);
        setFilteredData(dataResult.data);
        
        // Extract unique statuses
        const statuses = Array.from(new Set(
          dataResult.data.map(row => row.STATUS).filter(status => status != null)
        )).sort();
        setUniqueStatuses(statuses);
        setStatusFilters(statuses); // All selected by default
      }
      
      setCurrentView('sunvalley');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoadingSunValley(false);
    }
  };

  const handleStatusUpdate = async (recordId: number, newStatus: string, personName: string) => {
    setUpdatingStatus(recordId);
    try {
      const result = await updateSunValleyStatus(recordId, newStatus, personName);
      if (result.success) {
        // Update local state instead of refetching everything
        const updateDataArrays = (dataArray: any[]) => {
          return dataArray.map(row => 
            row.ID === recordId ? { ...row, STATUS: newStatus } : row
          );
        };

        // Update both data arrays
        setSunValleyData(prev => updateDataArrays(prev));
        setFilteredData(prev => updateDataArrays(prev));
        
        // Update status summary by recalculating from the updated data
        const updatedData = sunValleyData.map(row => 
          row.ID === recordId ? { ...row, STATUS: newStatus } : row
        );
        
        // Recalculate status summary
        const statusCounts = updatedData.reduce((acc: {[key: string]: number}, row) => {
          const status = row.STATUS || 'Unknown';
          acc[status] = (acc[status] || 0) + 1;
          return acc;
        }, {});
        
        const newStatusSummary = Object.entries(statusCounts)
          .map(([status, count]) => ({ STATUS: status, UNIQUE_NAMES: count }))
          .sort((a, b) => b.UNIQUE_NAMES - a.UNIQUE_NAMES);
        
        setStatusSummary(newStatusSummary);
        
        return true;
      } else {
        setError(result.error || 'Failed to update status');
        return false;
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
      return false;
    } finally {
      setUpdatingStatus(null);
    }
  };

  // Apply filters to Sun Valley data
  useEffect(() => {
    if (!sunValleyData.length) return;

    let filtered = [...sunValleyData];

    // Apply status filter
    if (statusFilters.length > 0 && statusFilters.length < uniqueStatuses.length) {
      filtered = filtered.filter(row => statusFilters.includes(row.STATUS));
    }

    // Apply regex filters
    Object.entries(regexFilters).forEach(([column, pattern]) => {
      if (pattern.trim()) {
        try {
          const regex = new RegExp(pattern, 'i');
          filtered = filtered.filter(row => {
            const value = row[column]?.toString() || '';
            return regex.test(value);
          });
        } catch (error) {
          // Invalid regex, skip this filter
        }
      }
    });

    setFilteredData(filtered);
  }, [sunValleyData, statusFilters, regexFilters, uniqueStatuses]);

  // Auto-connect and load Sun Valley app on component mount
  useEffect(() => {
    const initializeApp = async () => {
      await handleConnect();
      await handleLoadSunValleyApp();
    };
    initializeApp();
  }, []);

  return (
    <div className="App">
      <header className="App-header">        
        {(loading || loadingSunValley) ? (
          <div style={{ margin: '20px' }}>
            <div style={{ fontSize: '18px', marginBottom: '10px' }}>🔄 Loading Sun Valley Management System...</div>
            <p>Connecting to Snowflake and loading data...</p>
          </div>
        ) : error ? (
          <div style={{ maxWidth: '600px', margin: '20px' }}>
            <div style={{ color: 'red', marginBottom: '20px', fontSize: '18px' }}>
              ❌ Connection Error
            </div>
            <div style={{ color: 'red', marginBottom: '20px' }}>
              {error}
            </div>
            <button 
              onClick={() => {
                handleConnect().then(() => handleLoadSunValleyApp());
              }}
              style={{ padding: '10px 20px', fontSize: '16px', cursor: 'pointer' }}
            >
              🔄 Retry Connection
            </button>
          </div>
        ) : (
          <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '20px' }}>
            {/* Main Sun Valley App - Always Show */}
            <div>
              <h1 style={{ 
                color: 'white', 
                marginBottom: '30px',
                textShadow: '2px 2px 4px rgba(0,0,0,0.5)',
                fontSize: '32px',
                fontWeight: 'bold'
              }}>🏔️ Sun Valley 2025 Contact Management</h1>
                
                {/* Status Summary Section */}
                {statusSummary.length > 0 && (
                  <div style={{ marginBottom: '30px' }}>
                    {/* Status Breakdown Table */}
                    <div style={{ backgroundColor: 'white', borderRadius: '8px', padding: '20px', border: '2px solid #bdc3c7' }}>
                      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                          <tr style={{ backgroundColor: '#34495e', color: 'white' }}>
                            <th style={{ padding: '12px', textAlign: 'left', border: '1px solid #2c3e50' }}>Status</th>
                            <th style={{ padding: '12px', textAlign: 'left', border: '1px solid #2c3e50' }}>Unique Names</th>
                          </tr>
                        </thead>
                        <tbody>
                          {statusSummary.map((item, index) => (
                            <tr key={index} style={{ backgroundColor: index % 2 === 0 ? '#ecf0f1' : 'white' }}>
                              <td style={{ padding: '10px', border: '1px solid #bdc3c7', color: '#2c3e50', fontWeight: '500' }}>
                                <span style={{ 
                                  padding: '4px 8px', 
                                  borderRadius: '4px',
                                  backgroundColor: item.STATUS === 'Confirmed' ? '#2ecc71' : 
                                                  item.STATUS === 'Pending' ? '#f39c12' :
                                                  item.STATUS === 'n/a' ? '#95a5a6' : '#3498db',
                                  color: 'white',
                                  fontSize: '12px'
                                }}>
                                  {item.STATUS}
                                </span>
                              </td>
                              <td style={{ padding: '10px', border: '1px solid #bdc3c7', color: '#2c3e50', fontWeight: '500' }}>
                                {item.UNIQUE_NAMES.toLocaleString()}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                )}

                {/* Data Explorer Section */}
                {sunValleyData.length > 0 && (
                  <div>
                    {/* Filters */}
                    <div style={{ backgroundColor: 'white', borderRadius: '8px', padding: '20px', border: '2px solid #bdc3c7', marginBottom: '20px' }}>
                      
                      {/* Status Filter */}
                      <div style={{ marginBottom: '15px' }}>
                        <label style={{ display: 'block', marginBottom: '5px', color: '#2c3e50', fontWeight: '600' }}>
                          Status Filter:
                        </label>
                        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
                          {uniqueStatuses.map(status => (
                            <label key={status} style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                              <input
                                type="checkbox"
                                checked={statusFilters.includes(status)}
                                onChange={(e) => {
                                  if (e.target.checked) {
                                    setStatusFilters([...statusFilters, status]);
                                  } else {
                                    setStatusFilters(statusFilters.filter(s => s !== status));
                                  }
                                }}
                              />
                              <span style={{ color: '#2c3e50' }}>{status}</span>
                            </label>
                          ))}
                        </div>
                      </div>

                      {/* Regex Filters */}
                      <div>
                        <label style={{ display: 'block', marginBottom: '5px', color: '#2c3e50', fontWeight: '600' }}>
                          Column Filters (Regular Expressions):
                        </label>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '10px' }}>
                          {sunValleyData.length > 0 && Object.keys(sunValleyData[0])
                            .filter(col => !['STATUS', 'NEW'].includes(col))
                            .map(column => (
                            <input
                              key={column}
                              type="text"
                              placeholder={`Filter ${column}...`}
                              value={regexFilters[column] || ''}
                              onChange={(e) => setRegexFilters({
                                ...regexFilters,
                                [column]: e.target.value
                              })}
                              style={{
                                padding: '8px',
                                border: '1px solid #bdc3c7',
                                borderRadius: '4px',
                                fontSize: '14px'
                              }}
                            />
                          ))}
                        </div>
                      </div>

                      {/* Active Filters Summary */}
                      <div style={{ marginTop: '15px', fontSize: '14px', color: '#7f8c8d' }}>
                        Showing {filteredData.length.toLocaleString()} of {sunValleyData.length.toLocaleString()} records
                      </div>
                    </div>

                    {/* Editable Data Table */}
                    <div style={{ backgroundColor: 'white', borderRadius: '8px', padding: '20px', border: '2px solid #bdc3c7' }}>
                      
                      <div style={{ overflowX: 'auto' }}>
                        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
                          <thead>
                            <tr style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                              {filteredData.length > 0 && Object.keys(filteredData[0]).map(col => (
                                <th key={col} style={{ 
                                  padding: '12px', 
                                  border: '1px solid #34495e',
                                  textAlign: 'left',
                                  fontWeight: 'bold'
                                }}>
                                  {col}
                                </th>
                              ))}
                            </tr>
                          </thead>
                          <tbody>
                            {filteredData.slice(0, 50).map((row, rowIndex) => (
                              <tr key={rowIndex} style={{ 
                                backgroundColor: rowIndex % 2 === 0 ? '#ecf0f1' : 'white',
                                color: '#2c3e50'
                              }}>
                                {Object.entries(row).map(([col, value], colIndex) => (
                                  <td key={colIndex} style={{ 
                                    padding: '10px', 
                                    border: '1px solid #bdc3c7',
                                    maxWidth: '200px',
                                    overflow: 'hidden',
                                    textOverflow: 'ellipsis',
                                    whiteSpace: 'nowrap',
                                    color: '#2c3e50',
                                    fontWeight: '500'
                                  }}>
                                    {col === 'STATUS' ? (
                                      <select
                                        value={String(value || '')}
                                        disabled={updatingStatus === row.ID}
                                        onChange={async (e) => {
                                          const newValue = e.target.value;
                                          const success = await handleStatusUpdate(
                                            row.ID, 
                                            newValue, 
                                            row.NAME
                                          );
                                          if (!success) {
                                            // Reset to original value on failure - but this shouldn't be needed with React state
                                            console.error('Status update failed');
                                          }
                                        }}
                                        style={{
                                          padding: '4px 8px',
                                          border: '1px solid #bdc3c7',
                                          borderRadius: '4px',
                                          backgroundColor: updatingStatus === row.ID ? '#95a5a6' :
                                                          value === 'Confirmed' ? '#2ecc71' : 
                                                          value === 'Pending' ? '#f39c12' :
                                                          value === 'n/a' ? '#95a5a6' : '#3498db',
                                          color: 'white',
                                          fontWeight: 'bold',
                                          cursor: updatingStatus === row.ID ? 'wait' : 'pointer',
                                          opacity: updatingStatus === row.ID ? 0.7 : 1
                                        }}
                                      >
                                        <option value="n/a">n/a</option>
                                        <option value="Confirmed">Confirmed</option>
                                        <option value="Investor meeting">Investor meeting</option>
                                        <option value="Find at event">Find at event</option>
                                        <option value="Pending">Pending</option>
                                      </select>
                                    ) : (
                                      value !== null ? String(value) : (
                                        <span style={{ color: '#7f8c8d', fontStyle: 'italic' }}>NULL</span>
                                      )
                                    )}
                                  </td>
                                ))}
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                      
                      {filteredData.length > 50 && (
                        <div style={{ marginTop: '15px', textAlign: 'center', color: '#7f8c8d' }}>
                          Showing first 50 records. Use filters to narrow down results.
                        </div>
                      )}
                    </div>
                  </div>
                )}

                {/* Debug Information Section */}
                <div style={{ marginTop: '40px', borderTop: '2px solid #ecf0f1', paddingTop: '20px' }}>
                  <button
                    onClick={() => setDebugExpanded(!debugExpanded)}
                    style={{
                      backgroundColor: '#95a5a6',
                      color: 'white',
                      border: 'none',
                      padding: '8px 16px',
                      borderRadius: '4px',
                      cursor: 'pointer',
                      fontSize: '14px',
                      marginBottom: '15px'
                    }}
                  >
                    {debugExpanded ? '▼' : '▶'} Debug Information
                  </button>

                  {debugExpanded && (
                    <div style={{ backgroundColor: '#f8f9fa', borderRadius: '8px', padding: '20px', border: '1px solid #e9ecef' }}>
                      
                      {/* Database List */}
                      <div style={{ marginBottom: '20px' }}>
                        <h5 style={{ color: '#6c757d', fontSize: '12px', marginBottom: '10px' }}>Available Databases:</h5>
                        <div style={{ fontSize: '12px', color: '#6c757d', fontFamily: 'monospace' }}>
                          {databases.length > 0 ? (
                            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))', gap: '5px' }}>
                              {databases.map((db, index) => (
                                <span key={index} style={{ 
                                  padding: '2px 6px', 
                                  backgroundColor: db === 'SUN_VALLEY' ? '#28a745' : '#6c757d',
                                  color: 'white',
                                  borderRadius: '3px',
                                  fontSize: '11px'
                                }}>
                                  {db}
                                </span>
                              ))}
                            </div>
                          ) : (
                            'No databases loaded'
                          )}
                        </div>
                      </div>

                      {/* Tables List */}
                      <div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
                          <h5 style={{ color: '#6c757d', fontSize: '12px', margin: 0 }}>Sun Valley Tables:</h5>
                          <button
                            onClick={handleExploreSunValley}
                            disabled={loadingTables}
                            style={{
                              backgroundColor: loadingTables ? '#6c757d' : '#007bff',
                              color: 'white',
                              border: 'none',
                              padding: '4px 8px',
                              borderRadius: '3px',
                              cursor: loadingTables ? 'not-allowed' : 'pointer',
                              fontSize: '10px'
                            }}
                          >
                            {loadingTables ? 'Loading...' : 'Refresh'}
                          </button>
                        </div>
                        
                        <div style={{ fontSize: '12px', color: '#6c757d' }}>
                          {tables.length > 0 ? (
                            <div style={{ maxHeight: '150px', overflowY: 'auto' }}>
                              <table style={{ width: '100%', fontSize: '11px', borderCollapse: 'collapse' }}>
                                <thead>
                                  <tr style={{ backgroundColor: '#e9ecef' }}>
                                    <th style={{ padding: '4px 8px', textAlign: 'left', border: '1px solid #dee2e6' }}>Table</th>
                                    <th style={{ padding: '4px 8px', textAlign: 'left', border: '1px solid #dee2e6' }}>Type</th>
                                    <th style={{ padding: '4px 8px', textAlign: 'left', border: '1px solid #dee2e6' }}>Rows</th>
                                    <th style={{ padding: '4px 8px', textAlign: 'left', border: '1px solid #dee2e6' }}>Actions</th>
                                  </tr>
                                </thead>
                                <tbody>
                                  {tables.map((table, index) => (
                                    <tr key={index} style={{ backgroundColor: index % 2 === 0 ? '#f8f9fa' : 'white' }}>
                                      <td style={{ padding: '4px 8px', border: '1px solid #dee2e6', fontFamily: 'monospace' }}>
                                        {table.TABLE_NAME}
                                      </td>
                                      <td style={{ padding: '4px 8px', border: '1px solid #dee2e6' }}>{table.TABLE_TYPE}</td>
                                      <td style={{ padding: '4px 8px', border: '1px solid #dee2e6' }}>
                                        {table.ROW_COUNT ? table.ROW_COUNT.toLocaleString() : 'N/A'}
                                      </td>
                                      <td style={{ padding: '4px 8px', border: '1px solid #dee2e6' }}>
                                        <button
                                          onClick={() => handleViewTableData(table.TABLE_NAME)}
                                          style={{
                                            backgroundColor: '#28a745',
                                            color: 'white',
                                            border: 'none',
                                            padding: '2px 6px',
                                            borderRadius: '2px',
                                            cursor: 'pointer',
                                            fontSize: '10px'
                                          }}
                                        >
                                          Preview
                                        </button>
                                      </td>
                                    </tr>
                                  ))}
                                </tbody>
                              </table>
                            </div>
                          ) : (
                            'No tables loaded - click Refresh to load Sun Valley tables'
                          )}
                        </div>
                      </div>

                      {/* Table Data Preview */}
                      {selectedTable && tableData.length > 0 && (
                        <div style={{ marginTop: '20px' }}>
                          <h5 style={{ color: '#6c757d', fontSize: '12px', marginBottom: '10px' }}>
                            Preview: {selectedTable} ({tableData.length} rows)
                          </h5>
                          <div style={{ maxHeight: '200px', overflowY: 'auto', overflowX: 'auto' }}>
                            <table style={{ width: '100%', fontSize: '10px', borderCollapse: 'collapse' }}>
                              <thead>
                                <tr style={{ backgroundColor: '#e9ecef', position: 'sticky', top: 0 }}>
                                  {tableColumns.map((col, index) => (
                                    <th key={index} style={{ 
                                      padding: '4px 6px', 
                                      textAlign: 'left', 
                                      border: '1px solid #dee2e6',
                                      minWidth: '80px'
                                    }}>
                                      {col.COLUMN_NAME}
                                    </th>
                                  ))}
                                </tr>
                              </thead>
                              <tbody>
                                {tableData.slice(0, 10).map((row, rowIndex) => (
                                  <tr key={rowIndex} style={{ backgroundColor: rowIndex % 2 === 0 ? '#f8f9fa' : 'white' }}>
                                    {tableColumns.map((col, colIndex) => (
                                      <td key={colIndex} style={{ 
                                        padding: '4px 6px', 
                                        border: '1px solid #dee2e6',
                                        maxWidth: '150px',
                                        overflow: 'hidden',
                                        textOverflow: 'ellipsis',
                                        whiteSpace: 'nowrap'
                                      }}>
                                        {row[col.COLUMN_NAME] !== null ? String(row[col.COLUMN_NAME]) : (
                                          <span style={{ color: '#6c757d', fontStyle: 'italic' }}>NULL</span>
                                        )}
                                      </td>
                                    ))}
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          </div>
                        </div>
                      )}
                    </div>
                  )}
                </div>
            </div>
            
          </div>
        )}
      </header>
    </div>
  );
}

export default App;
