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

terraform init \
  -backend-config="resource_group_name=rg-thunder-perf-terraform" \
  -backend-config="storage_account_name=stthundertfstate" \
  -backend-config="container_name=terraform" \
  -backend-config="key=thunder-perf-terraform.tfstate"

terraform apply \
  -var-file="/Users/lakshanbanneheke/Repos/thunder-performance/kubernetes/terraform/conf/thunder.eastus2.conf.secrets.tfvars" \
  -var-file="/Users/lakshanbanneheke/Repos/thunder-performance/kubernetes/terraform/conf/thunder.eastus2.conf.tfvars"


