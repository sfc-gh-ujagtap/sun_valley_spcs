#!/bin/bash

# Sun Valley React App Startup Script
# This script starts both the Express backend server and React frontend development server

echo "🏔️  Starting Sun Valley React App Servers"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the sun-valley-react directory."
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Function to cleanup background processes on script exit
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        echo "   ✅ Backend server stopped"
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        echo "   ✅ Frontend server stopped"
    fi
    echo "👋 Goodbye!"
    exit 0
}

# Set up trap to cleanup on script exit
trap cleanup SIGINT SIGTERM EXIT

# Start the Express backend server
echo "🚀 Starting Express backend server on port 3002..."
node server.js &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Check if backend started successfully
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Failed to start backend server"
    exit 1
fi

echo "   ✅ Backend server started (PID: $BACKEND_PID)"

# Start the React development server
echo "🚀 Starting React development server on port 3000..."
npm start &
FRONTEND_PID=$!

# Wait a moment for frontend to start
sleep 3

# Check if frontend started successfully
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo "❌ Failed to start frontend server"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo "   ✅ Frontend server started (PID: $FRONTEND_PID)"
echo ""
echo "🎉 Both servers are running!"
echo "   📱 Frontend: http://localhost:3000"
echo "   🔧 Backend:  http://localhost:3002"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for user to stop the servers
wait
