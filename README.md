# 🏔️ Sun Valley React App

A modern full-stack React TypeScript application for Sun Valley 2025 Contact Management, providing a professional web interface for connecting to Snowflake and managing contact data with real-time updates.

## 🚀 Quick Start

### Option 1: Use the Startup Script (Recommended)
```bash
./start-servers.sh
```

### Option 2: Manual Startup
```bash
# Terminal 1: Start backend server
node server.js

# Terminal 2: Start frontend server
npm start
```

Then open [http://localhost:3000](http://localhost:3000) in your browser.

## ⚙️ Environment Configuration

The application supports dynamic host configuration through environment variables:

### Backend (server.js)
- `HOST`: Server host (default: `localhost`)
- `PORT`: Backend server port (default: `3002`)

### Frontend (React app)
- `REACT_APP_API_URL`: Full API base URL (e.g., `http://myserver:3002`)
- `REACT_APP_API_PORT`: API port when constructing dynamic URLs (default: `3002`)

### Examples
```bash
# Development with custom host
HOST=0.0.0.0 PORT=8080 ./start-servers.sh

# Production build with custom API URL
REACT_APP_API_URL=https://api.mycompany.com npm run build

# Docker deployment
docker run -e HOST=0.0.0.0 -e PORT=3002 -p 3002:3002 sun-valley-app
```

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
- **Connection Configuration** in `~/.snowsql/config` (uses `my_conn` profile)
- **Database Access** to `sun_valley.y2025` schema

## 🛠️ Installation & Setup

1. **Navigate to the project directory:**
   ```bash
   cd sun-valley-react
   ```

2. **Install dependencies** (if not already installed):
   ```bash
   npm install
   ```

3. **Verify Snowflake configuration** in `~/.snowsql/config`:
   ```ini
   [connections.my_conn]
   accountname = your_account
   username = your_username
   password = your_password
   # OR for private key auth:
   # private_key_path = ~/.ssh/snowflake_key.p8
   ```

4. **Start the application:**
   ```bash
   ./start-servers.sh
   ```

## 📁 Project Architecture

```
sun-valley-react/
├── 📄 server.js                    # Express backend server with Snowflake integration
├── 📄 start-servers.sh             # Startup script for both servers
├── 📄 package.json                 # Dependencies and scripts
├── 📁 src/
│   ├── 📄 App.tsx                  # Main React application component
│   ├── 📄 snowflake.ts             # Snowflake API client functions
│   ├── 📄 index.tsx                # React app entry point
│   └── 📄 App.css                  # Application styles
├── 📁 public/
│   ├── 📄 index.html               # HTML template
│   └── 🖼️ favicon.ico              # App icon
└── 📁 node_modules/                # Dependencies
```

## 🔧 Available Scripts

### `./start-servers.sh`
**Recommended**: Starts both backend and frontend servers with proper cleanup

### `npm start`
Runs the React frontend in development mode at [http://localhost:3000](http://localhost:3000)

### `node server.js`
Runs the Express backend server at [http://localhost:3002](http://localhost:3002)

### `npm test`
Launches the test runner in interactive watch mode

### `npm run build`
Builds the React app for production to the `build` folder

### `npm run eject`
⚠️ **One-way operation**: Ejects from Create React App (not recommended)

## 🏗️ Application Components

### **Backend Server (server.js)**
- **Snowflake Connection Management**: Handles authentication and connection pooling
- **API Endpoints**: RESTful APIs for data operations
- **Configuration Loading**: Reads `~/.snowsql/config` automatically
- **Error Handling**: Comprehensive error logging and user feedback

### **Frontend App (App.tsx)**
- **Connection Interface**: Automatic Snowflake connection on startup
- **Status Dashboard**: Real-time status distribution and metrics
- **Data Management**: Interactive table with inline editing capabilities
- **Filtering System**: Advanced regex-based filtering across all columns
- **Responsive Design**: Mobile-friendly interface with Material-UI components

## 🔄 API Endpoints

The Express backend provides the following REST API endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/connect` | POST | Connect to Snowflake and list databases |
| `/api/sun-valley/tables` | GET | Get Sun Valley schema tables |
| `/api/sun-valley/status-summary` | GET | Get status distribution summary |
| `/api/sun-valley/detailed-data` | GET | Get detailed contact data |
| `/api/sun-valley/update-status` | POST | Update contact status |
| `/api/table-data/:tableName` | GET | Get data from specific table |

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

## 🆚 Comparison with Streamlit Version

| Feature | Streamlit App | React App | Advantage |
|---------|---------------|-----------|-----------|
| **Performance** | ⚡ Good | ⚡⚡ Excellent | React: Better responsiveness |
| **User Experience** | 📱 Desktop-focused | 📱💻 Multi-device | React: Mobile-friendly |
| **Real-time Updates** | 🔄 Page refresh | 🔄 Live updates | React: No page reloads |
| **Customization** | 🎨 Limited | 🎨🎨 Extensive | React: Full UI control |
| **Deployment** | 🚀 Simple | 🚀🚀 Flexible | React: Multiple options |
| **Data Export** | ❌ Not available | ✅ CSV export | React: Built-in export |
| **Offline Capability** | ❌ Server-dependent | ✅ Partial offline | React: Better resilience |

## 🚀 Deployment Options

### **Development**
```bash
./start-servers.sh  # Local development with hot reload
```

### **Production**
```bash
npm run build       # Build optimized React app
node server.js      # Run production server
```

### **Docker** (Optional)
```dockerfile
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3002
CMD ["node", "server.js"]
```

## 📚 Learn More

- **React Documentation**: [https://reactjs.org/](https://reactjs.org/)
- **Material-UI Components**: [https://mui.com/](https://mui.com/)
- **Snowflake Node.js SDK**: [https://docs.snowflake.com/en/user-guide/nodejs-driver](https://docs.snowflake.com/en/user-guide/nodejs-driver)
- **Express.js Guide**: [https://expressjs.com/](https://expressjs.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add feature-name'`
5. Push to the branch: `git push origin feature-name`
6. Submit a pull request

---

**Built with ❤️ for Sun Valley 2025 Contact Management**
