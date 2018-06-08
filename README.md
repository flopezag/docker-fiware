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

## License

These scripts are licensed under Apache License 2.0.
