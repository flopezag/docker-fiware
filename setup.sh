#!/bin/bash

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


    ###################
    # Get Auth Tokens
    ###################
    read -p "Username: " username
    echo -n "Password: "
    read -s password
    echo

    token=$( curl -v \
        --silent \
        -X POST \
        -H 'Content-Type: application/json' \
        --data-binary "$(post_data_for_token)" \
        'http://127.0.0.1:3000/v1/auth/tokens' 2>&1 | awk '/X-Subject-Token: /{print substr($3,0,36)}' )


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

    docker-compose exec wirecloud sh config-idm.sh $ClientID $ClientSecret
    docker-compose exec wirecloud manage.py migrate
    docker-compose exec wirecloud manage.py collectstatic
    docker-compose restart wirecloud
}

clean_environment() {
    echo "WARNING!!! This operation will delete all the local data"
    while true; do
        read -p "Do you really want to continue [y/N]? " yn
        yn=${yn:-no}
        case $yn in
            [Yy]* ) 
                echo

                echo "Removing dockers..."
                docker-compose kill
                docker-compose rm
                docker-compose down

                echo
                echo "    Removing local content..."
                rm -rf ./postgres-data
                rm -rf ./static
                rm -rf ./wirecloud_instance
                rm -rf ./mysql-idm
                rm -rf ./mongodb
                rm -rf ./mysql-cygnus

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
