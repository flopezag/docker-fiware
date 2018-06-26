#!/bin/bash
# -*- encoding: utf-8 -*-
##
# Copyright 2017 FIWARE Foundation, e.V.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
##

usage() { 
    echo "Usage:	$0 COMMAND"
    echo
    echo "A setup script to configure the docker-fiware containers."
    echo
    echo "Management Commands:"
    echo "  init        Configure the services to work together."
    echo "  clean       Stop and delete all the information about the containers."
    echo "  pull        Update the docker images used in the project."
    echo
    exit 1;
}


post_data_for_token()
{
  cat <<EOF
  {
    "name": "$username",
    "password": "$password"
  }
EOF
}


post_data_for_application()
{ 
  cat <<EOF
  {
    "application": {
      "name": "Test_application 1",
      "description": "description",
      "redirect_uri": "http://127.0.0.1/complete/fiware/",
      "url": "http://127.0.0.1",
      "grant_type": [
        "authorization_code",
        "implicit",
        "password"
      ]
    }
  }
EOF
}


post_data_cygnus_subscription()
{
    cat <<EOF
    {
        "description": "Notify Cygnus of all context changes",
        "subject": {
            "entities": [
                {
                    "idPattern": ".*"
                }
            ]
        },
        "notification": {
            "http": {
                "url": "http://cygnus:5050/notify"
            },
            "attrsFormat": "legacy"
        },
        "throttling": 5
    }
EOF
}


post_data_new_role() 
{
    cat<<EOF
    {
        "role": {
            "name": "admin"
        } 
    }
EOF
}


initialize() {
    echo

    ####################################
    # Install jq if it is not installed
    ####################################
    command -v jq >/dev/null || { echo; echo "Need to install jq"; echo; apt-get install -y jq; }


    ##############################################
    # We need to wait until the IDM is Up & Ready
    ##############################################
    echo
    echo -n "Waiting to get Up & Ready the IdM service ... "

    curl http://127.0.0.1:3000 2>/dev/null >/dev/null

    result=$?

    while [ "$result" -eq "7" -o "$result" -eq "52" ]; do
        curl http://127.0.0.1:3000 2>/dev/null >/dev/null

        result=$?
    done

    tput setaf 2; echo "done"
    tput sgr0; echo
    
    #################################################
    # Configure IdM (config.js) and wait restart IdM
    #################################################
    docker-compose exec fiware-idm sh change-config-js.sh
    docker-compose restart fiware-idm

    echo
    echo -n "Waiting to get Up & Ready the IdM service ... "

    curl http://127.0.0.1:3000 2>/dev/null >/dev/null

    result=$?

    while [ "$result" -eq "7" -o "$result" -eq "52" ]; do
        curl http://127.0.0.1:3000 2>/dev/null >/dev/null

        result=$?
    done

    tput setaf 2; echo "done"
    tput sgr0; echo

    ###################
    # Get Auth Tokens
    ###################
    read -p "Username: " username
    echo -n "Password: "
    read -s password
    echo

    # Get a token
    token=$( curl -v \
        --silent \
        -X POST \
        -H 'Content-Type: application/json' \
        --data-binary "$(post_data_for_token)" \
        'http://127.0.0.1:3000/v1/auth/tokens' 2>&1 | awk '/X-Subject-Token: /{print substr($3,0,36)}' )

    echo
    echo "Token: " $token
    echo

    # Create an application
    result=$(curl -v \
        --silent \
        -X POST \
        -H "Content-Type: application/json" \
        -H "X-Auth-Token: $token" \
        --data-binary "$(post_data_for_application)" \
        'http://127.0.0.1:3000/v1/applications' 2>&1 > a.out)

    ClientID=$(cat a.out | jq .application.id | sed 's/\"//g')
    ClientSecret=$(cat a.out | jq .application.secret | sed 's/\"//g')

    echo "Client ID: " $ClientID
    echo "Client Secret: " $ClientSecret

    echo

    # Create the role "admin" in the application
    result=$(curl -v \
        --silent \
        -X POST \
        -H "Cache-Control: no-cache" \
        -H "Content-Type: application/json" \
        -H "X-Auth-Token: $token" \
        --data-binary "$(post_data_new_role)" \
        "http://127.0.0.1:3000/v1/applications/$ClientID/roles" 2>&1 > a.out)

    RoleID=$(cat a.out | jq .role.id | sed 's/\"//g')
    RoleName=$(cat a.out | jq .role.name | sed 's/\"//g')

    echo "Role ID: " $RoleID
    echo "Role Name: " $RoleName

    echo

    # Assign role "admin" to the user "admin" of the current Application
    result=$(curl -v \
       --silent \
        -X POST \
        -H "Content-Type: application/json" \
        -H "X-Auth-token: $token" \
        "http://127.0.0.1:3000/v1/applications/$ClientID/users/admin/roles/$RoleID" 2>&1 > a.out)

    RoleID=$(cat a.out | jq .role_user_assignments.role_id | sed 's/\"//g')
    UserID=$(cat a.out | jq .role_user_assignments.user_id | sed 's/\"//g')
    
    echo "Role ID: $RoleID assigned to the User ID: $UserID"

    echo

    ################################
    # Subscribe Cygnus to Orion CB
    ################################
    echo
    echo -n "Waiting to get Up & Ready the Orion service ... "

    curl http://127.0.0.1:1026 2>/dev/null >/dev/null

    result=$?

    while [ "$result" -eq "7" -o "$result" -eq "52" ]; do
        curl http://127.0.0.1:1026 2>/dev/null >/dev/null

        result=$?
    done

    tput setaf 2; echo "done"
    tput sgr0; echo

    result=$(curl -v \
        --silent \
        -X POST \
        -H "Content-Type: application/json" \
        --data-binary "$(post_data_cygnus_subscription)" \
        'http://127.0.0.1:1026/v2/subscriptions/' 2>&1 > a.out)

    rm a.out

    echo

    ######################
    # Configure Wirecloud
    ######################
    docker-compose exec wirecloud sh config-idm.sh $ClientID $ClientSecret


    #################################
    # Finish the configuration steps
    #################################
    docker-compose exec wirecloud manage.py migrate
    docker-compose exec wirecloud manage.py collectstatic
    
    echo
    
    docker-compose restart wirecloud

    echo
}

clean_environment() {
    tput setaf 1; echo "WARNING!!! This operation will delete all the local data"
    tput sgr0; echo

    while true; do
        read -p "Do you really want to continue [y/N]? " yn
        yn=${yn:-no}
        case $yn in
            [Yy]* ) 
                echo

                echo "Removing dockers..."
                echo
                docker-compose kill
                echo
                docker-compose rm
                echo
                docker-compose down

                echo
                echo -n "Removing local content ... "
                rm -rf ./postgres-data
                rm -rf ./static
                rm -rf ./wirecloud_instance
                rm -rf ./mysql-idm
                rm -rf ./mongodb
                rm -rf ./mysql-cygnus

                tput setaf 2; echo "done"
                tput sgr0; echo

                echo

                exit
                ;;
            [Nn]* ) 
                echo
                exit
                ;;
            * ) 
                echo
                echo "Please answer yes or no."
                ;;
        esac
    done    
}

pull_environment()
{
    echo

    echo "Obtaining updated NGINX image (latest)"
	docker pull nginx:latest
    echo
	
    echo "Obtaining updated Wirecloud image (latest-composable)"
	docker pull fiware/wirecloud:latest-composable
    echo
	
    echo "Obtaining updated Cygnus image (latest)"
	docker pull fiware/cygnus-ngsi:latest
    echo
	
    echo "Obtaining updated IoT Agent UL image (develop)"
	docker pull fiware/iotagent-ul:develop
    echo
	
    echo "Obtaining updated IdM image"
	docker pull fiware/idm
    echo
	
    echo "Obtaining updated Orion image (latest)"
	docker pull fiware/orion:latest
    echo
	
    echo "Obtaining updated PostgreSQL image (latest)"
	docker pull postgres:latest
    echo
	
    echo "Obtaining updated MongoDB image (3.4)"
	docker pull mongo:3.4
    echo
	
    echo "Obtaining updated MySQL Server image (5.7.21)"
	docker pull mysql/mysql-server:5.7.21
    echo
	
    echo "Obtaining updated NGSI Proxy image (latest)"
	docker pull fiware/ngsiproxy:latest
    echo
	
    echo "Obtaining updated MySQL image (5.7)"
	docker pull mysql:5.7
    echo
}

echo

case "$1" in
    init)
        echo "Initialize process ..."
        initialize
        ;;
    clean)
        echo "Cleaning the dockers ..."
        clean_environment
        ;;
    pull)
        echo "Updating docker images ..."
        pull_environment
        ;;
    *)
        usage
        ;;
esac
