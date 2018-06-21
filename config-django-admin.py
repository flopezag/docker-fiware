#!/usr/bin/env python
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
# import the necessary packages
import argparse
import os
import subprocess
import sys
 
# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-u", "--user", required=True,
	help="name of the user")
ap.add_argument("-s", "--superuser", required=False,
    choices=["True", "False"], default="False",
	help="the user is a superuser [True|False] ")

args = vars(ap.parse_args())
 
os.environ["MY_USERNAME"] = args["user"]
os.environ["MY_SUPERUSER"] = args["superuser"]

subprocess.call('python manage.py shell < change-user-permissions.py', shell=True)
