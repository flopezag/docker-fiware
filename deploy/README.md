# Setting up a stand-alone FIWARE Lab User Create service

This content describes how to deploy this example of FIWARE services using an
[ansible](http://www.ansible.com) playbook. It has been tested on the
[FIWARE Lab](https://cloud.lab.fiware.org) cloud.

It will install the service and the different configurations file in order
to make a prrof of concept of the integration of the different GEs (Orion,
IdM - Keyrock, Wirecloud, IoT-Agent UL, Cygnus, PEP Proxy - Wilma and NGSI 
Proxy.

Additionally, it autoconfigures the wirecloud instance in order to use the
IdM - Keyrock local instance deployed in the docker-compose.

## How to start it

* Create virtualenv and activate it:

      virtualenv -p python2.7 $NAME_VIRTUAL_ENV
      source $NAME_VIRTUAL_ENV/bin/activate

* Install the requirements:

      pip install -r requirements.txt

* One all the variables are in place you should be able to deploy and
  configure the service. Just run the following command:

      ansible-playbook -vvvv -i inventory.yml \
      --private-key=(Key pair to access to the instance) \
      deploy_fiware.yml
