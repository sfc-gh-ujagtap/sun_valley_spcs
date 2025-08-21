#!/bin/bash

# Sun Valley React App Server Shutdown Script
# This script stops both the Express backend server and React frontend development server

echo "🛑 Stopping Sun Valley React App Servers"
echo "========================================"

# Function to kill processes on specific ports
kill_port() {
    local port=$1
    local name=$2
    
    local pids=$(lsof -ti:$port 2>/dev/null)
    
    if [ -n "$pids" ]; then
        echo "🔄 Stopping $name server on port $port..."
        echo "$pids" | xargs kill -9 2>/dev/null
        echo "   ✅ $name server stopped"
    else
        echo "   ℹ️  No $name server running on port $port"
    fi
}

# Stop backend server (port 3002)
kill_port 3002 "Backend"

# Stop frontend server (port 3000)  
kill_port 3000 "Frontend"

echo ""
echo "🎉 All servers stopped!"
echo "👋 Goodbye!"
