#!/bin/bash

# URL for login and upload
LOGIN_URL="http://localhost:8088/auth/login"
UPLOAD_URL="http://localhost:8088/definition/import"

# Your login credentials
USER_EMAIL="admin@email.com"
USER_PASSWORD="admin"

# Get session cookie by logging in
AUTH_RESULT=$(curl -s -X POST "$LOGIN_URL" \
  -H "Content-Type: application/json" \
  -d '{"tenant": "admin", "email": "'"$USER_EMAIL"'", "password": "'"$USER_PASSWORD"'"}' \
  -c - | grep 'sails.sid' | sed 's/^\(.*\)$/\1/')

if [ -z "$AUTH_RESULT" ]; then
    echo "Login failed or session cookie not found"
    exit 1
fi
cookie=$(echo $AUTH_RESULT | awk '{print $7}' | sed 's/^/sails.sid=/')
echo "Login successful. Session cookie received: $cookie"

# Loop through all .json files in the current directory and upload them
for file in *.json; do
    if [ -f "$file" ]; then
        echo "Uploading $file..."
        
        # Upload the file
        response=$(curl -s -X POST "$UPLOAD_URL" \
            -H "Cookie: $cookie" \
            -F "upload=@$file")

        # Check for success or error in response
        if [[ "$response" == *"status\":\"error"* ]]; then
            echo "Error uploading $file"
        else
            echo "File $file uploaded successfully"
        fi
    fi
done
