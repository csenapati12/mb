#!/bin/bash

# stop the script on error

# set -e

# functions have to be defined before everything else

# read a given variable from a given file in
# usage: MY_VAR=$(read_var MY_VAR .env)

BUILD_MODE =$1
RELEASE_TAG=$2
echo $BUILD_MODE $RELEASE_TAG" 


# build the base image
# requires config_engine_tag and query_engine_tag global variables to be set
build_base () {
	echo 'NxLog - NxGen DSA Docker - Build **BASE** Image'

# get the Nexus Password (PWD) from .env
	PSWD=$(read_var NEXUS_PASSWORD .env)

	rm -rf ./nxgen_dglux
	mkdir ./nxgen_dglux

	# get dglux
	curl -ubuildbot:$PSWD -o ./nxgen_dglux/tempDglux.zip "http://nxgennexushost.westeurope.cloudapp.azure.com:8081/repository/nxGen-zips/dgluxServer/external/dglux_server.v1514.zip" || error_out "DGLux couldn't be retrieved from Nexus, did you supply the right tag and Password?";

	rm -rf ./nxgen_links
	mkdir ./nxgen_links
	mkdir ./nxgen_links/__c01_queryEngine
	mkdir ./nxgen_links/__c02_configEngine
	mkdir ./nxgen_links/__c03_launchService
	mkdir ./nxgen_links/__e01_system

	# get QE
	curl -ubuildbot:$PSWD -o QueryEngine.zip "http://nxgennexushost.westeurope.cloudapp.azure.com:8081/repository/nxGen-zips/dsLinks/core/queryEngine/nxgen_dsl_queryEngine-$query_engine_tag.zip" && \
	unzip QueryEngine.zip -d ./nxgen_links/__c01_queryEngine/ && \
	rm QueryEngine.zip || error_out "Query Engine couldn't be retrieved from Nexus, did you supply the right tag and Password?";

	# get CE
	curl -ubuildbot:$PSWD -o ConfigEngine.zip "http://nxgennexushost.westeurope.cloudapp.azure.com:8081/repository/nxGen-zips/dsLinks/core/configEngine/nxgen_dsl_configEngine-$config_engine_tag.zip" && \
	unzip ConfigEngine.zip -d ./nxgen_links/__c02_configEngine/ && \
	rm ConfigEngine.zip || error_out "Config Engine couldn't be retrieved from Nexus, did you supply the right tag and Password?";

	# get LS
	curl -ubuildbot:$PSWD -o LaunchService.zip "http://nxgennexushost.westeurope.cloudapp.azure.com:8081/repository/nxGen-zips/dsLinks/core/launchService/nxgen_dsl_launchService-$launch_service_tag.zip" && \
	unzip LaunchService.zip -d ./nxgen_links/__c03_launchService/ && \
	rm LaunchService.zip || error_out "Launch Service couldn't be retrieved from Nexus, did you supply the right tag and Password?";

	# get System
	curl -ubuildbot:$PSWD -o System.zip "http://nxgennexushost.westeurope.cloudapp.azure.com:8081/repository/nxGen-zips/dsLinks/core/external/system/dsl_system.v1.0.1-nxgen.zip" && \
	unzip System.zip -d ./nxgen_links/__e01_system/ && \
	rm System.zip || error_out "System couldn't be retrieved from Nexus, did you supply the right tag and Password?";

	#Pause to check zip file before removal
	#read -p "Press [Enter] key to continue... ..."
	#need to change here
	sudo docker build -t nxgen/nxgen_base:"$release_tag" --label "build.version=$release_tag" -f base-Dockerfile . || error_out "docker build on the base image failed!"
}

# build the server image
# requires nxgen_dglux_tag and release_tag global variable to be set
build_server () {
	echo "Building Server"

	# server_hash is used to decide if a server instance refreshes it's dglux data
	local server_hash=$(uuidgen)

	echo "Hash: $server_hash"

	rm -rf ./build-server/nxgen_dglux/
	mkdir ./build-server/nxgen_dglux/

	echo "Building NxGen Version $nxgen_dglux_tag"

	# get UI
	curl -ubuildbot:$PSWD -o UI.zip "http://nxgennexushost.westeurope.cloudapp.azure.com:8081/repository/nxGen-zips/ui/nxgen_ui-$nxgen_dglux_tag.zip" && \
	unzip UI.zip -d ./build-server/nxgen_dglux/ && \
	rm UI.zip || error_out "UI couldn't be retrieved from Nexus, did you supply the right tag and Password?";

	#Pause to check zip file before removal
	#read -p "Press [Enter] key to continue... ..."

	# server_version.json may be invalid if slashes/escape characters appear in the parameters
	echo "$server_hash" > ./build-server/version.nxgen
	echo -e "{\"NxGenVer\": \"$nxgen_dglux_tag\", \"BuildNo\": \"$server_hash\", \"ConfigEngine\": \"$config_engine_tag\", \"QueryEngine\": \"$query_engine_tag\", \"LaunchService\": \"$launch_service_tag\", \"ReleaseNo\": \"$release_tag\"}" > ./build-server/server_version.json

	# build context is in ./build-server
	sudo docker build -t nxgen.azurecr.io/"$build_mode":"$release_tag" --build-arg BASE_TAG=$release_tag --label "build.version=$release_tag" -f ./build-server/server-Dockerfile ./build-server || error_out "docker build for server image failed!"
}

# build the dev image
# requires release_tag global variable to be set
build_dev () {
	echo "Building Dev"

	# build context is in ./build-dev
	sudo docker build -t nxgen.azurecr.io/"$build_mode":"$release_tag" --build-arg BASE_TAG=$release_tag --label "build.version=$release_tag" -f ./build-dev/dev-Dockerfile ./build-dev || error_out "docker build for dev image failed!"
}

# wrap the dev/server build into the fluentbit enabled build
# requires release_tag global variable to be set
build_fluent () {
	echo "Building FluentBit version of Dev"

	# build context is in ./build-fb
	sudo docker build -t nxgen.azurecr.io/"$build_mode"-f:"$release_tag" --build-arg BASE_TAG=$release_tag --build-arg BUILD=$build_mode --label "build.version=$release_tag" -f ./build-fb/fb-Dockerfile ./build-fb || error_out "docker build for fb image failed!"
}


# script starts here ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# declare global variables for our settings
# pass in all the commandline parameters to parse_parameters
parse_parameters "$@"
check_params

build_base

if [ "$build_mode" == "server" ]
then
	build_server
elif [ "$build_mode" == "dev" ]
then
	build_dev
else
	error_out "Invalid build mode supplied."
fi

# Removing fluent from the build temporarily
#build_fluent

# Cleanup any files generated during the script
if [ -d "./nxgen_dglux" ]; then rm -rf ./nxgen_dglux; fi
if [ -d "./nxgen_links" ]; then rm -rf ./nxgen_links; fi
if [ -d "./build-server/nxgen_dglux" ]; then rm -rf ./build-server/nxgen_dglux; fi
if [ -f "./build-server/server_version.json" ]; then rm ./build-server/server_version.json; fi
if [ -f "./build-server/version.nxgen" ]; then rm ./build-server/version.nxgen; fi

#set +e
