#!/bin/bash

usage() { 
    echo "Usage: $0 [init|clean]" 1>&2; 
    echo
    exit 1; 
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

initialize() {
    docker-compose exec wirecloud manage.py migrate

    docker-compose exec wirecloud manage.py createsuperuser

    docker-compose exec wirecloud manage.py collectstatic
}

