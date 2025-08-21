#!/bin/bash

echo "🔗 Getting service endpoint URL for Sun Valley React..."
echo ""

# Get service endpoints
snow sql -q "SHOW ENDPOINTS IN SERVICE SPCS_APP_DB.IMAGE_SCHEMA.SUN_VALLEY_SERVICE;"

echo ""
echo "Note: The URL will be in the 'ingress_url' column of the output above."
echo "Make sure the service is in 'READY' state before accessing the URL."
