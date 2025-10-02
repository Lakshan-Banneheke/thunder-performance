#!/bin/bash
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------
# Run VM Performance tests on AWS
# ----------------------------------------------------------------------------

RESOURCES_DIR=$WORKSPACE/resources
WORKSPACE_DIR=$WORKSPACE/workspace
cmd=""

echo "WORKSPACE Directory: $WORKSPACE"

echo ""
echo "Starting performance test with params:"
echo "    THUNDER_PACK_URL: $THUNDER_PACK_URL"
echo "    DEPLOYMENT: $DEPLOYMENT"
echo "    CPU_CORES: $CPU_CORES"
echo "    PERFORMANCE_REPO: $PERFORMANCE_REPO"
echo "    BRANCH: $BRANCH"
echo "=========================================================="
cd $WORKSPACE
rm -rf workspace
mkdir workspace
rm -rf resources
mkdir resources
cd workspace

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION=us-east-1

SHEET_NAME=$(date +%Y-%m-%d)-Performance
VERSION="latest"
echo ""
echo "Downloading Thunder Pack..."
echo "=========================================================="
wget -q -O "$WORKSPACE"/thunder.zip "$THUNDER_PACK_URL"


sudo rm -rf thunder-performance
echo ""
echo "Cloning thunder-performance repo..."
echo "=========================================================="
git clone $PERFORMANCE_REPO
cd thunder-performance
git checkout $BRANCH
cd perf-scripts

echo "Build Triggered By $BUILD_USER_EMAIL"

aws s3 cp s3://performance-is-resources/Key/is-perf-test.pem is-perf-test.pem

chmod 400 is-perf-test.pem

APACHE_JMETER="https://performance-is-packs.s3.amazonaws.com/productis/apache-jmeter-5.3.tgz"

wget -q -O apache-jmeter-5.3.tgz $APACHE_JMETER

mv apache-jmeter-5.3.tgz $RESOURCES_DIR
mv is-perf-test.pem $RESOURCES_DIR

# Temp script to resolve cpu cores
instance_type=""
if [ "$CPU_CORES" = "2" ]; then
	instance_type="c6i.large"
elif [ "$CPU_CORES" = "4" ]; then
	instance_type="c6i.xlarge"
elif [ "$CPU_CORES" = "8" ]; then
	instance_type="c6i.2xlarge"
else
	echo ""
	echo "Provided CPU cores [$CPU_CORES] is not supported with the deployment: $DEPLOYMENT."
	echo "Exiting..."
	exit 1
fi

cd single-node


echo "Build started by build cause: $BUILD_CAUSE"

echo ""
echo "Building project..."
echo "=========================================================="

CMD_MVN="mvn clean install"

$CMD_MVN

echo ""
echo "Starting test..."
echo "=========================================================="

cmd="./start-performance.sh -k $RESOURCES_DIR/is-perf-test.pem \
-c is-perf-cert -j $RESOURCES_DIR/apache-jmeter-5.3.tgz -n $WORKSPACE/thunder.zip -q $BUILD_USER_EMAIL -i $instance_type -m $DB_TYPE -r $CONCURRENCY -v $MODE -f $DEPLOYMENT -k $JWT_TOKEN_CLIENT_SECRET -o $JWT_TOKEN_USER_PASSWORD -z $USE_DELAYS "

if [[ ! -z $ADDITIONAL_PARAMS_TO_RUN_PERFORMANCE_SCRIPT ]]; then
	cmd+=" $ADDITIONAL_PARAMS_TO_RUN_PERFORMANCE_SCRIPT"
fi

echo "$cmd"

$cmd

cp -r results-* "$WORKSPACE_DIR"

aws s3 cp --recursive results-* s3://performance-is-resources/Thunder/Results/"$BUILD_NUMBER"
