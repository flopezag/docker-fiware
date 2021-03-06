# How to deploy it in a specific machine

This content describes how to deploy this example of FIWARE services using an
[ansible](http://www.ansible.com) playbook. It has been tested on the
[FIWARE Lab](https://cloud.lab.fiware.org) cloud.

It will install the service and the different configurations file in order
to make a prrof of concept of the integration of the different GEs (Orion,
IdM - Keyrock, Wirecloud, IoT-Agent UL, Cygnus, PEP Proxy - Wilma and NGSI Proxy.

Additionally, it autoconfigures the wirecloud instance in order to use the
IdM - Keyrock local instance deployed in the docker-compose.

## How to start it

* Create virtualenv and activate it:

      virtualenv -p python2.7 $NAME_VIRTUAL_ENV
      source $NAME_VIRTUAL_ENV/bin/activate

* Install the requirements:

      pip install -r requirements.txt

* Go into the vars/main.yml and assign the IP of the virtual machine to the variable
  ip_address.

* Go into inventory.yml and put the IP of the virtual machine and the user that will
  be used in order to access to the machine using SSH.

* Execute the ansible playbook to deploy and configure the services:

      ansible-playbook -vvvv -i inventory.yml \
      --private-key=(Key pair to access to the instance) \
      deploy_fiware.yml

* Once that the command finish, the last step is going into the virtual machine and
  execute the command:

      sudo ./setup.sh init

  Which automatically configure the Wirecloud to connect to the local instance of IdM.

Keep in mind that the deployment and configuration of all the steps could expend some
time. One of our execution expends arround 13 minutes to finish it.
