#!/bin/bash

#
#  Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
#
#  WSO2 LLC. licenses this file to you under the Apache License,
#  Version 2.0 (the "License"); you may not use this file except
#  in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied. See the License for the
#  specific language governing permissions and limitations
#  under the License.
#

echo "Connected to VM successfully"

# Update package list
echo "Updating package lists..."
sudo apt-get update

# Install necessary packages if needed
echo "Installing required packages..."
sudo apt-get install -y curl jq

# Create necessary directories
echo "Creating directories..."
mkdir -p ~/deployment

# Check Kubernetes status
echo "Checking Kubernetes status..."
kubectl get nodes

# Execute additional commands as needed
echo "Current directory: $(pwd)"
echo "Running additional custom commands..."
# Add your additional commands here

echo "All commands executed successfully"
