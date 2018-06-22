# docker-fiware

[![License badge](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

Sample docker-compose and configuration files to deploy almost a complete FIWARE architecture example.

## Install

You have two possibilites to deploy this component, locally in your environment or in a virtual machine.

### Install locally

In order to install locally this component you have to keep in mind that you should have installed previously
docker and docker-compose. Please follow the tutorial [Install Docker CE](https://docs.docker.com/install/) in
order to install docker engine and then follow the documentation [Install Docker Compose](https://docs.docker.com/compose/install/).

The next step is simple clone the repository in your local folder:

```bash
git clone https://github.com/flopezag/docker-fiware
```

After this step you can launch your services just executing:

```bash
docker-compose up -d
```

Now it is time to get the different images that it is needed in our compose file. Keep in mind that
it is something that you need to do from time to time to get the updated version of the docker images.
Just execute:

```bash
./setup.sh pull
```

Last but not leasr, to configure your wirecloud instance just execute the configuration script:

```bash
./setup.sh init
```

It will request you the user name and password of the [IdM](http://127.0.0.1:3000) instance that you have allocated.
Please use the default administration user of the IdM. In order to access the wirecloud just go to the link
[Wirecloud](http://127.0.0.1).

### Install remotelly

In order to install and configure the deployment of this dockers, you can take a look to the documentation provided in
deploy folder, [How to deploy it in a specific machine](deploy/README.md)

## Django user management

In case that you want to assign superuser roles to a user or simple user in the Django admin panel just execute the command:

```bash
docker-compose exec wirecloud python config-django-admin.py -u <username> -s <True|False>
````

where -u parameter is the username of the user that has to be registered previously in the IdM and loged in Wirecloud
and -s is the parameter to indicate if the user is superuser (True) or just a simple user (False).

## License

These scripts are licensed under Apache License 2.0.
