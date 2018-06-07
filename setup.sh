#!/bin/bash

usage() { 
    echo "Usage: $0 [init|clean]" 1>&2; 
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


initialize() {
    echo

    ####################################
    # Install jq if it is not installed
    ####################################
    command -v jq >/dev/null || { echo; echo "Need to install jq"; echo; apt-get install -y jq; }

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
    *)
        usage
        ;;
esac
