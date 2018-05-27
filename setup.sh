#!/bin/bash

usage() { echo "Usage: $0 [init|clean]" 1>&2; exit 1; }

clean_environment() {
    docker-compose kill
    docker-compose rm
    docker-compose down

    rm -rf ./postgres-data
    rm -rf ./static
    rm -rf ./wirecloud_instance
    rm -rf ./mysql-idm
}

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

